enum UserRole { patient, doctor, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}

class SpecialistModel {
  final String id;
  final String name;
  final String description;

  SpecialistModel({
    required this.id,
    required this.name,
    required this.description,
  });
}

class UnitModel {
  final String id;
  final String name;
  final String hospitalName;
  final String address;
  final double latitude;
  final double longitude;

  UnitModel({
    required this.id,
    required this.name,
    required this.hospitalName,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class DoctorModel {
  final String id;
  final String name;
  final String specialistId;
  final String unitId;
  final String schedule;
  final String image;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialistId,
    required this.unitId,
    required this.schedule,
    required this.image,
  });
}

enum ReservationStatus { waiting, inProgress, completed, cancelled }

class ReservationModel {
  final String id;
  final String queueNumber;
  final String barcodeCode;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String unitName;
  final String specialistName;
  final DateTime date;
  ReservationStatus status;

  ReservationModel({
    required this.id,
    required this.queueNumber,
    required this.barcodeCode,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.unitName,
    required this.specialistName,
    required this.date,
    this.status = ReservationStatus.waiting,
  });
}
