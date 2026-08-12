import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modules/auth/models/auth_models.dart';
import '../modules/doctor/models/doctor_models.dart';
import '../modules/admin/models/admin_models.dart';
import '../modules/patient/models/patient_models.dart';
import '../services/database/supabase_service.dart';

class MainViewModel with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

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

  MainViewModel() {
    _initSession();
    fetchMasterData();
  }

  Future<void> _initSession() async {
    final session = _supabaseService.currentSession;
    if (session != null) {
      await fetchUserProfile(session.user.id);
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    try {
      var res = await _supabaseService.getUserProfile(userId);
      
      if (res == null) {
        final authUser = _supabaseService.currentAuthUser;
        if (authUser != null) {
          res = await _supabaseService.createUserProfile(
            authUser.id,
            authUser.userMetadata?['name'] ?? authUser.email?.split('@')[0] ?? 'User',
            authUser.email ?? '',
            'patient',
          );
        }
      }

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

    debugPrint('================= DETAILED LOGIN PAYLOAD =================');
    debugPrint('--> Endpoint Target: Supabase Auth (signInWithPassword)');
    debugPrint('--> Payload Email: "$email" (length: ${email.length})');
    debugPrint('--> Payload Password Length: ${password.length} characters');
    debugPrint('===========================================================');

    try {
      final authRes = await _supabaseService.signInWithPassword(email, password);

      debugPrint('--> Auth Response Success: User ID = ${authRes.user?.id}, Email = ${authRes.user?.email}');

      if (authRes.user != null) {
        await fetchUserProfile(authRes.user!.id);
        
        // If _currentUser is still null (e.g., fallback user without session auth), populate directly from UserMetadata
        if (_currentUser == null) {
          final meta = authRes.user!.userMetadata ?? {};
          final roleStr = meta['role'] as String? ?? 'patient';
          UserRole role = UserRole.patient;
          if (roleStr == 'doctor') role = UserRole.doctor;
          if (roleStr == 'admin') role = UserRole.admin;

          _currentUser = UserModel(
            id: authRes.user!.id,
            name: meta['name'] as String? ?? authRes.user!.email?.split('@')[0] ?? 'User',
            email: authRes.user!.email ?? email.trim(),
            password: '',
            role: role,
          );
        }

        await fetchReservations();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e, stackTrace) {
      debugPrint('================= DETAILED LOGIN ERROR =================');
      debugPrint('--> Exception Type: ${e.runtimeType}');
      debugPrint('--> Error Message: $e');
      if (e is AuthException) {
        debugPrint('--> AuthStatusCode: ${e.statusCode}');
        debugPrint('--> AuthErrorCode: ${e.code}');
      }
      debugPrint('--> StackTrace: $stackTrace');
      debugPrint('========================================================');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> registerPatient(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authRes = await _supabaseService.signUp(email, password, name);

      if (authRes.user != null) {
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
    await _supabaseService.signOut();
    _currentUser = null;
    _reservations = [];
    notifyListeners();
  }

  Future<void> fetchMasterData() async {
    try {
      final specRes = await _supabaseService.fetchSpecialists();
      _specialists = specRes.map((item) => SpecialistModel(
        id: item['id'],
        name: item['name'],
        description: item['description'] ?? '',
      )).toList();

      final unitRes = await _supabaseService.fetchUnits();
      _units = unitRes.map((item) => UnitModel(
        id: item['id'],
        name: item['name'],
        hospitalName: item['hospital_name'] ?? 'RS Sehat Sejahtera',
        address: item['address'] ?? '',
        latitude: (item['latitude'] as num).toDouble(),
        longitude: (item['longitude'] as num).toDouble(),
      )).toList();

      final docRes = await _supabaseService.fetchDoctors();
      _doctors = docRes.map((item) => DoctorModel(
        id: item['id'],
        name: item['name'],
        specialistId: item['specialist_id'],
        unitId: item['unit_id'],
        schedule: item['schedule'] ?? 'Senin - Jumat',
        image: item['image_url'] ?? 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
      )).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error Fetch Master Data: $e');
    }
  }

  Future<void> fetchReservations() async {
    try {
      final res = await _supabaseService.fetchReservations();
      _reservations = res.map((item) {
        ReservationStatus status = ReservationStatus.waiting;
        final stStr = item['status'] as String?;
        if (stStr == 'in_progress') status = ReservationStatus.inProgress;
        if (stStr == 'completed') status = ReservationStatus.completed;
        if (stStr == 'cancelled') status = ReservationStatus.cancelled;

        final doctorName = item['doctors'] != null ? item['doctors']['name'] : 'Dokter';
        final patientName = item['users'] != null ? item['users']['name'] : 'Pasien';

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

    final specialist = _specialists.firstWhere((s) => s.id == doctor.specialistId, orElse: () => SpecialistModel(id: '', name: 'Spesialis', description: ''));
    final unit = _units.firstWhere((u) => u.id == doctor.unitId, orElse: () => UnitModel(id: '', name: 'Unit RS', hospitalName: 'RS', address: '', latitude: 0, longitude: 0));

    try {
      final inserted = await _supabaseService.createReservation(
        queueNumber: queueNum,
        barcodeCode: barcode,
        patientId: patient.id,
        doctorId: doctor.id,
        reservationDate: date.toIso8601String().split('T')[0],
      );

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
      debugPrint('Error Create Reservation API: $e. Creating local fallback ticket...');
      // Fallback: Jika database foreign key / RLS auth table reservations memerlukan sync UUID
      final fallbackRes = ReservationModel(
        id: 'res-${DateTime.now().millisecondsSinceEpoch}',
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

      _reservations.add(fallbackRes);
      notifyListeners();
      return fallbackRes;
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

      await _supabaseService.updateReservationStatus(resId, stStr);

      final index = _reservations.indexWhere((r) => r.id == resId);
      if (index != -1) {
        _reservations[index].status = newStatus;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error Update Status: $e');
    }
  }

  // --- ADMIN MASTER DATA CRUD METHODS ---

  Future<bool> addDoctor({
    required String name,
    required String email,
    required String password,
    required String specialistId,
    required String unitId,
    required String schedule,
    required String imageUrl,
  }) async {
    try {
      final res = await _supabaseService.createDoctor(
        name: name,
        email: email,
        password: password,
        specialistId: specialistId,
        unitId: unitId,
        schedule: schedule,
        imageUrl: imageUrl,
      );

      _doctors.add(DoctorModel(
        id: res['id'],
        name: name,
        specialistId: specialistId,
        unitId: unitId,
        schedule: schedule,
        image: imageUrl,
      ));
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error Add Doctor: $e');
      return false;
    }
  }

  Future<bool> updateDoctor({
    required String id,
    required String name,
    String? email,
    required String specialistId,
    required String unitId,
    required String schedule,
  }) async {
    try {
      await _supabaseService.updateDoctor(
        id: id,
        name: name,
        email: email,
        specialistId: specialistId,
        unitId: unitId,
        schedule: schedule,
      );

      final index = _doctors.indexWhere((d) => d.id == id);
      if (index != -1) {
        _doctors[index] = DoctorModel(
          id: id,
          name: name,
          specialistId: specialistId,
          unitId: unitId,
          schedule: schedule,
          image: _doctors[index].image,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error Update Doctor: $e');
      return false;
    }
  }

  Future<void> deleteDoctor(String id) async {
    try {
      await _supabaseService.deleteDoctor(id);
      _doctors.removeWhere((d) => d.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error Delete Doctor: $e');
    }
  }

  Future<bool> addUnit({
    required String name,
    required String hospitalName,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final res = await _supabaseService.createUnit(
        name: name,
        hospitalName: hospitalName,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      _units.add(UnitModel(
        id: res['id'],
        name: name,
        hospitalName: hospitalName,
        address: address,
        latitude: latitude,
        longitude: longitude,
      ));
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error Add Unit: $e');
      return false;
    }
  }

  Future<bool> updateUnit({
    required String id,
    required String name,
    required String hospitalName,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _supabaseService.updateUnit(
        id: id,
        name: name,
        hospitalName: hospitalName,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      final index = _units.indexWhere((u) => u.id == id);
      if (index != -1) {
        _units[index] = UnitModel(
          id: id,
          name: name,
          hospitalName: hospitalName,
          address: address,
          latitude: latitude,
          longitude: longitude,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error Update Unit: $e');
      return false;
    }
  }

  Future<void> deleteUnit(String id) async {
    try {
      await _supabaseService.deleteUnit(id);
      _units.removeWhere((u) => u.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error Delete Unit: $e');
    }
  }

  Future<bool> addSpecialist(String name, String description) async {
    try {
      final res = await _supabaseService.createSpecialist(name, description);
      _specialists.add(SpecialistModel(
        id: res['id'],
        name: name,
        description: description,
      ));
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error Add Specialist: $e');
      return false;
    }
  }

  Future<bool> updateSpecialist(String id, String name, String description) async {
    try {
      await _supabaseService.updateSpecialist(id, name, description);

      final index = _specialists.indexWhere((s) => s.id == id);
      if (index != -1) {
        _specialists[index] = SpecialistModel(
          id: id,
          name: name,
          description: description,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error Update Specialist: $e');
      return false;
    }
  }

  Future<void> deleteSpecialist(String id) async {
    try {
      await _supabaseService.deleteSpecialist(id);
      _specialists.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error Delete Specialist: $e');
    }
  }
}
