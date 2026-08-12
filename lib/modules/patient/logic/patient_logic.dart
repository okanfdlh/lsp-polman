import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class PatientLogic {
  static Future<void> openMap(double targetLat, double targetLng, {BuildContext? context}) async {
    Position? userPos;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        userPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
      }
    } catch (_) {
      // Jika GPS gagal, tetap lanjut dengan titik tujuan saja
    }

    Uri mapUrl;
    if (userPos != null) {
      // URL Google Maps Direction (Rute dari posisi user ke titik unit poli)
      mapUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${userPos.latitude},${userPos.longitude}&destination=$targetLat,$targetLng&travelmode=driving',
      );
    } else {
      // Fallback: Jika izin GPS ditolak/tidak aktif, buka pin lokasi tujuan di Google Maps
      mapUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$targetLat,$targetLng');
    }

    try {
      if (!await launchUrl(mapUrl, mode: LaunchMode.platformDefault)) {
        await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(mapUrl);
      } catch (_) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuka aplikasi Peta.')),
          );
        }
      }
    }
  }
}
