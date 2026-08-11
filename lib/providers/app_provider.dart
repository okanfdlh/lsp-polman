import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AppProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  List<SpecialistModel> _specialists = [];
  List<UnitModel> _units = [];
  List<DoctorModel> _doctors = [];
  List<ReservationModel> _reservations = [];

  List<SpecialistModel> get specialists => _specialists;
  List<UnitModel> get units => _units;
  List<DoctorModel> get doctors => _doctors;
  List<ReservationModel> get reservations => _reservations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AppProvider() {
    _initSession();
    fetchMasterData();
  }

  // --- INITIALIZE & AUTH ---

  Future<void> _initSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await fetchUserProfile(session.user.id);
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    try {
      final res = await _supabase.from('profiles').select().eq('id', userId).maybeSingle();
      if (res != null) {
        UserRole role = UserRole.patient;
        final roleStr = res['role'] as String?;
        if (roleStr == 'doctor') role = UserRole.doctor;
        if (roleStr == 'admin') role = UserRole.admin;

        _currentUser = UserModel(
          id: res['id'],
          name: res['name'] ?? 'User',
          email: res['email'] ?? '',
          password: '',
          role: role,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetch profile: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authRes = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (authRes.user != null) {
        await fetchUserProfile(authRes.user!.id);
        await fetchReservations();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error Supabase Login: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> registerPatient(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Supabase Auth Sign Up
      final authRes = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name},
      );

      if (authRes.user != null) {
        // 2. Insert Profile Data into public.profiles
        await _supabase.from('profiles').insert({
          'id': authRes.user!.id,
          'name': name,
          'email': email.trim(),
          'role': 'patient',
        });

        _currentUser = UserModel(
          id: authRes.user!.id,
          name: name,
          email: email.trim(),
          password: '',
          role: UserRole.patient,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error Register: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    _reservations = [];
    notifyListeners();
  }

  // --- FETCH MASTER DATA (READ) ---

  Future<void> fetchMasterData() async {
    try {
      // Fetch Specialists
      final specRes = await _supabase.from('specialists').select();
      _specialists = (specRes as List).map((item) {
        return SpecialistModel(
          id: item['id'],
          name: item['name'],
          description: item['description'] ?? '',
        );
      }).toList();

      // Fetch Units
      final unitRes = await _supabase.from('units').select();
      _units = (unitRes as List).map((item) {
        return UnitModel(
          id: item['id'],
          name: item['name'],
          hospitalName: item['hospital_name'] ?? 'RS Sehat Sejahtera',
          address: item['address'] ?? '',
          latitude: (item['latitude'] as num).toDouble(),
          longitude: (item['longitude'] as num).toDouble(),
        );
      }).toList();

      // Fetch Doctors
      final docRes = await _supabase.from('doctors').select();
      _doctors = (docRes as List).map((item) {
        return DoctorModel(
          id: item['id'],
          name: item['name'],
          specialistId: item['specialist_id'],
          unitId: item['unit_id'],
          schedule: item['schedule'] ?? 'Senin - Jumat',
          image: item['image_url'] ?? 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error Fetch Master Data: $e');
    }
  }

  // --- RESERVATIONS CRUD ---

  Future<void> fetchReservations() async {
    try {
      final res = await _supabase.from('reservations').select('*, doctors(name, specialist_id, unit_id), profiles(name)');
      _reservations = (res as List).map((item) {
        ReservationStatus status = ReservationStatus.waiting;
        final stStr = item['status'] as String?;
        if (stStr == 'in_progress') status = ReservationStatus.inProgress;
        if (stStr == 'completed') status = ReservationStatus.completed;
        if (stStr == 'cancelled') status = ReservationStatus.cancelled;

        final doctorName = item['doctors'] != null ? item['doctors']['name'] : 'Dokter';
        final patientName = item['profiles'] != null ? item['profiles']['name'] : 'Pasien';

        return ReservationModel(
          id: item['id'],
          queueNumber: item['queue_number'],
          barcodeCode: item['barcode_code'],
          patientId: item['patient_id'],
          patientName: patientName,
          doctorId: item['doctor_id'],
          doctorName: doctorName,
          unitName: 'Poliklinik RS',
          specialistName: 'Spesialis Medis',
          date: DateTime.parse(item['reservation_date']),
          status: status,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error Fetch Reservations: $e');
    }
  }

  Future<ReservationModel?> createReservation(DoctorModel doctor, DateTime date) async {
    if (_currentUser == null) return null;

    final patient = _currentUser!;
    final doctorResCount = _reservations.where((r) => r.doctorId == doctor.id).length + 1;
    final queueNum = 'A-${doctorResCount.toString().padLeft(3, '0')}';
    final barcode = 'RES-${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    try {
      final inserted = await _supabase.from('reservations').insert({
        'queue_number': queueNum,
        'barcode_code': barcode,
        'patient_id': patient.id,
        'doctor_id': doctor.id,
        'reservation_date': date.toIso8601String().split('T')[0],
        'status': 'waiting',
      }).select().single();

      final specialist = _specialists.firstWhere((s) => s.id == doctor.specialistId, orElse: () => SpecialistModel(id: '', name: 'Spesialis', description: ''));
      final unit = _units.firstWhere((u) => u.id == doctor.unitId, orElse: () => UnitModel(id: '', name: 'Unit RS', hospitalName: 'RS', address: '', latitude: 0, longitude: 0));

      final newRes = ReservationModel(
        id: inserted['id'],
        queueNumber: queueNum,
        barcodeCode: barcode,
        patientId: patient.id,
        patientName: patient.name,
        doctorId: doctor.id,
        doctorName: doctor.name,
        unitName: unit.name,
        specialistName: specialist.name,
        date: date,
      );

      _reservations.add(newRes);
      notifyListeners();
      return newRes;
    } catch (e) {
      debugPrint('Error Create Reservation: $e');
      return null;
    }
  }

  ReservationModel? findReservationByBarcode(String barcode) {
    try {
      return _reservations.firstWhere((r) => r.barcodeCode == barcode);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateReservationStatus(String resId, ReservationStatus newStatus) async {
    try {
      String stStr = 'waiting';
      if (newStatus == ReservationStatus.inProgress) stStr = 'in_progress';
      if (newStatus == ReservationStatus.completed) stStr = 'completed';
      if (newStatus == ReservationStatus.cancelled) stStr = 'cancelled';

      await _supabase.from('reservations').update({'status': stStr}).eq('id', resId);

      final index = _reservations.indexWhere((r) => r.id == resId);
      if (index != -1) {
        _reservations[index].status = newStatus;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error Update Status: $e');
    }
  }

  // --- ADMIN MASTER DATA CRUD ---

  Future<void> addDoctor(DoctorModel doctor) async {
    try {
      final res = await _supabase.from('doctors').insert({
        'name': doctor.name,
        'specialist_id': doctor.specialistId,
        'unit_id': doctor.unitId,
        'schedule': doctor.schedule,
        'image_url': doctor.image,
      }).select().single();

      _doctors.add(DoctorModel(
        id: res['id'],
        name: doctor.name,
        specialistId: doctor.specialistId,
        unitId: doctor.unitId,
        schedule: doctor.schedule,
        image: doctor.image,
      ));
      notifyListeners();
    } catch (e) {
      debugPrint('Error Add Doctor: $e');
    }
  }

  Future<void> addUnit(UnitModel unit) async {
    try {
      final res = await _supabase.from('units').insert({
        'name': unit.name,
        'hospital_name': unit.hospitalName,
        'address': unit.address,
        'latitude': unit.latitude,
        'longitude': unit.longitude,
      }).select().single();

      _units.add(UnitModel(
        id: res['id'],
        name: unit.name,
        hospitalName: unit.hospitalName,
        address: unit.address,
        latitude: unit.latitude,
        longitude: unit.longitude,
      ));
      notifyListeners();
    } catch (e) {
      debugPrint('Error Add Unit: $e');
    }
  }

  Future<void> addSpecialist(SpecialistModel specialist) async {
    try {
      final res = await _supabase.from('specialists').insert({
        'name': specialist.name,
        'description': specialist.description,
      }).select().single();

      _specialists.add(SpecialistModel(
        id: res['id'],
        name: specialist.name,
        description: specialist.description,
      ));
      notifyListeners();
    } catch (e) {
      debugPrint('Error Add Specialist: $e');
    }
  }
}
