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
        'User-Agent': 'FlutterApp/1.0 (com.example.lsp)',
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

  // Real-time Search Geocoding se-Indonesia dari OpenStreetMap Nominatim & Photon Geocoder Fallback
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    final cleanQuery = query.trim();

    // Try Primary 1: Nominatim OpenStreetMap API
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(cleanQuery)}&limit=10&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'FlutterApp/1.0 (com.example.lsp)',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data.map((item) {
            return {
              'display_name': item['display_name'] ?? '',
              'lat': double.parse(item['lat']),
              'lon': double.parse(item['lon']),
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('OSM Nominatim Search Error: $e');
    }

    // Fallback 2: Photon Komoot OpenStreetMap Geocoder (Toleran Typo / Kata Kunci seperti "puskesmas sungailiat")
    try {
      final url = Uri.parse(
        'https://photon.komoot.io/api/?q=${Uri.encodeComponent(cleanQuery)}&limit=10',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List features = data['features'] ?? [];
        if (features.isNotEmpty) {
          return features.map((item) {
            final props = item['properties'] ?? {};
            final geometry = item['geometry'] ?? {};
            final List coords = geometry['coordinates'] ?? [106.8456, -6.2088];
            
            final name = props['name'] ?? '';
            final city = props['city'] ?? props['county'] ?? props['state'] ?? '';
            final country = props['country'] ?? '';
            final displayName = [name, city, country].where((s) => s.toString().isNotEmpty).join(', ');

            return {
              'display_name': displayName.isNotEmpty ? displayName : name,
              'lat': (coords[1] as num).toDouble(),
              'lon': (coords[0] as num).toDouble(),
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Photon Geocoder Search Error: $e');
    }

    return [];
  }
}
