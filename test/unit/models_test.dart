import 'package:flutter_test/flutter_test.dart';
import 'package:lsp/modules/auth/models/auth_models.dart';
import 'package:lsp/modules/patient/models/patient_models.dart';
import 'package:lsp/modules/doctor/models/doctor_models.dart';
import 'package:lsp/modules/admin/models/admin_models.dart';

void main() {
  group('Auth Models Unit Tests', () {
    test('LoginFormModel validation test', () {
      final formValid = LoginFormModel(email: 'test@mail.com', password: '123');
      expect(formValid.isValid, isTrue);

      final formInvalid = LoginFormModel(email: '   ', password: '');
      expect(formInvalid.isValid, isFalse);
    });

    test('RegisterFormModel validation test', () {
      final formValid = RegisterFormModel(name: 'Pasien Test', email: 'test@mail.com', password: '123');
      expect(formValid.isValid, isTrue);

      final formInvalid = RegisterFormModel(name: '', email: 'test@mail.com', password: '');
      expect(formInvalid.isValid, isFalse);
    });

    test('UserModel instantiation test', () {
      final user = UserModel(
        id: 'usr-123',
        name: 'Super Admin',
        email: 'admin@gmail.com',
        password: '123',
        role: UserRole.admin,
      );

      expect(user.id, equals('usr-123'));
      expect(user.role, equals(UserRole.admin));
    });
  });

  group('Patient & Reservation Models Unit Tests', () {
    test('ReservationModel status default test', () {
      final res = ReservationModel(
        id: 'res-1',
        queueNumber: 'A-001',
        barcodeCode: 'RES-20260811-001',
        patientId: 'p-1',
        patientName: 'Budi Pasien',
        doctorId: 'd-1',
        doctorName: 'Dr. Ahmad',
        unitName: 'Poli Mata',
        specialistName: 'Spesialis Mata',
        date: DateTime(2026, 8, 11),
      );

      expect(res.queueNumber, equals('A-001'));
      expect(res.status, equals(ReservationStatus.waiting));
    });
  });

  group('Doctor & Admin Models Unit Tests', () {
    test('DoctorModel instantiation test', () {
      final doc = DoctorModel(
        id: 'doc-1',
        name: 'Dr. Sarah Sp.A',
        specialistId: 'spec-1',
        unitId: 'unit-1',
        schedule: 'Senin - Jumat',
        image: 'http://image.png',
      );

      expect(doc.name, equals('Dr. Sarah Sp.A'));
      expect(doc.specialistId, equals('spec-1'));
    });

    test('AdminStatModel test', () {
      final stats = AdminStatModel(
        totalDoctors: 5,
        totalUnits: 3,
        totalSpecialists: 4,
        totalReservations: 12,
      );

      expect(stats.totalDoctors, equals(5));
      expect(stats.totalReservations, equals(12));
    });
  });
}
