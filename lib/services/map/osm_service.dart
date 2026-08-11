import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class OSMService {
  // Real-time Reverse Geocoding dari OpenStreetMap
  static Future<String?> reverseGeocode(LatLng location) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'HealthCareFlutterApp/1.0 (contact@hospital.com)',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['display_name'] != null) {
          return data['display_name'] as String;
        }
      }
    } catch (e) {
      debugPrint('OSM Reverse Geocode Error: $e');
    }
    return null;
  }

  // Real-time Search Geocoding se-Indonesia dari OpenStreetMap
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.trim().length < 3) return [];

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&countrycodes=id&limit=8&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'HealthCareFlutterApp/1.0 (contact@hospital.com)',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((item) {
          return {
            'display_name': item['display_name'] ?? '',
            'lat': double.parse(item['lat']),
            'lon': double.parse(item['lon']),
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('OSM Search Error: $e');
    }
    return [];
  }
}
