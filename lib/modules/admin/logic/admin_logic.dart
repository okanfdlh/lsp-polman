import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/main_viewmodel.dart';
import '../../../services/map/osm_service.dart';
import '../models/admin_models.dart';

class AdminLogic {
  static AdminStatModel getDashboardStats(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context, listen: false);
    return AdminStatModel(
      totalDoctors: viewModel.doctors.length,
      totalUnits: viewModel.units.length,
      totalSpecialists: viewModel.specialists.length,
      totalReservations: viewModel.reservations.length,
    );
  }

  static Future<String?> reverseGeocode(LatLng location) async {
    return await OSMService.reverseGeocode(location);
  }

  static Future<List<Map<String, dynamic>>> searchOSMPlaces(String query) async {
    return await OSMService.searchPlaces(query);
  }
}
