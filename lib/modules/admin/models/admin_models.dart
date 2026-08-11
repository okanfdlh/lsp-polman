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

class AdminStatModel {
  final int totalDoctors;
  final int totalUnits;
  final int totalSpecialists;
  final int totalReservations;

  AdminStatModel({
    required this.totalDoctors,
    required this.totalUnits,
    required this.totalSpecialists,
    required this.totalReservations,
  });
}
