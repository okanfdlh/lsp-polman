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

class DoctorScanModel {
  String barcodeQuery;
  DoctorScanModel({this.barcodeQuery = ''});
}
