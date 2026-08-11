import 'package:flutter/material.dart';
import '../models/models.dart';

class AppProvider with ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Initial Mock Data
  final List<UserModel> _users = [
    UserModel(id: 'u1', name: 'Budi Pasien', email: 'pasien@mail.com', password: '123', role: UserRole.patient),
    UserModel(id: 'd1', name: 'Dr. Andi Sp.PD', email: 'dokter@mail.com', password: '123', role: UserRole.doctor),
    UserModel(id: 'a1', name: 'Super Admin', email: 'admin@mail.com', password: '123', role: UserRole.admin),
  ];

  final List<SpecialistModel> _specialists = [
    SpecialistModel(id: 's1', name: 'Spesialis Penyakit Dalam', description: 'Menangani organ dalam dewasa'),
    SpecialistModel(id: 's2', name: 'Spesialis Anak', description: 'Kesehatan dan tumbuh kembang anak'),
    SpecialistModel(id: 's3', name: 'Spesialis Jantung', description: 'Kardiovaskular dan kesehatan jantung'),
  ];

  final List<UnitModel> _units = [
    UnitModel(
      id: 'un1',
      name: 'Poliklinik Penyakit Dalam (Gedung A, Lt 2)',
      hospitalName: 'RS Sehat Sejahtera',
      address: 'Jl. Sudirman No. 45, Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
    ),
    UnitModel(
      id: 'un2',
      name: 'Poliklinik Anak (Gedung B, Lt 1)',
      hospitalName: 'RS Sehat Sejahtera',
      address: 'Jl. Sudirman No. 45, Jakarta',
      latitude: -6.2090,
      longitude: 106.8460,
    ),
  ];

  late List<DoctorModel> _doctors;
  final List<ReservationModel> _reservations = [];

  AppProvider() {
    _doctors = [
      DoctorModel(
        id: 'doc1',
        name: 'Dr. Andi Sp.PD',
        specialistId: 's1',
        unitId: 'un1',
        schedule: 'Senin - Jumat (08:00 - 12:00)',
        image: 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
      ),
      DoctorModel(
        id: 'doc2',
        name: 'Dr. Rina Sp.A',
        specialistId: 's2',
        unitId: 'un2',
        schedule: 'Senin - Sabtu (13:00 - 17:00)',
        image: 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
      ),
    ];

    // Dummy initial reservation
    _reservations.add(
      ReservationModel(
        id: 'res-101',
        queueNumber: 'A-001',
        barcodeCode: 'RES-20260811-001',
        patientId: 'u1',
        patientName: 'Budi Pasien',
        doctorId: 'doc1',
        doctorName: 'Dr. Andi Sp.PD',
        unitName: 'Poliklinik Penyakit Dalam (Gedung A, Lt 2)',
        specialistName: 'Spesialis Penyakit Dalam',
        date: DateTime.now(),
        status: ReservationStatus.waiting,
      ),
    );
  }

  List<SpecialistModel> get specialists => _specialists;
  List<UnitModel> get units => _units;
  List<DoctorModel> get doctors => _doctors;
  List<ReservationModel> get reservations => _reservations;

  // Auth Methods
  bool login(String email, String password) {
    try {
      final user = _users.firstWhere(
        (u) => u.email.trim().toLowerCase() == email.trim().toLowerCase() && u.password == password,
      );
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  bool registerPatient(String name, String email, String password) {
    if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      return false;
    }
    final newUser = UserModel(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      password: password,
      role: UserRole.patient,
    );
    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Reservation Methods
  ReservationModel createReservation(DoctorModel doctor, DateTime date) {
    final patient = _currentUser!;
    final specialist = _specialists.firstWhere((s) => s.id == doctor.specialistId);
    final unit = _units.firstWhere((u) => u.id == doctor.unitId);

    final doctorResCount = _reservations.where((r) => r.doctorId == doctor.id).length + 1;
    final queueNum = 'A-${doctorResCount.toString().padLeft(3, '0')}';
    final barcode = 'RES-${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}-${doctorResCount.toString().padLeft(3, '0')}';

    final newRes = ReservationModel(
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

    _reservations.add(newRes);
    notifyListeners();
    return newRes;
  }

  ReservationModel? findReservationByBarcode(String barcode) {
    try {
      return _reservations.firstWhere((r) => r.barcodeCode == barcode);
    } catch (_) {
      return null;
    }
  }

  void updateReservationStatus(String resId, ReservationStatus newStatus) {
    final index = _reservations.indexWhere((r) => r.id == resId);
    if (index != -1) {
      _reservations[index].status = newStatus;
      notifyListeners();
    }
  }

  // Admin Master Data Methods
  void addDoctor(DoctorModel doctor) {
    _doctors.add(doctor);
    notifyListeners();
  }

  void addUnit(UnitModel unit) {
    _units.add(unit);
    notifyListeners();
  }

  void addSpecialist(SpecialistModel specialist) {
    _specialists.add(specialist);
    notifyListeners();
  }
}
