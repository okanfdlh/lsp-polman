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

class PatientFilterModel {
  String? selectedSpecialistId;
  String? searchQuery;

  PatientFilterModel({this.selectedSpecialistId, this.searchQuery});
}
