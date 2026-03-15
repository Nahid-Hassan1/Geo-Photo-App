import 'dart:convert';

import 'package:http/http.dart' as http;

class NominatimService {
  NominatimService({
    http.Client? client,
    this.baseUrl = 'https://nominatim.openstreetmap.org',
    this.referer = 'https://era-explorer.climate.copernicus.eu/',
    this.userAgent = 'GeoPhotoApp/1.0 (flutter)',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String referer;
  final String userAgent;

  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
    int zoom = 12,
  }) async {
    final uri = Uri.parse('$baseUrl/reverse').replace(queryParameters: {
      'format': 'geocodejson',
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'addressdetails': '1',
      'zoom': zoom.toString(),
    });

    final response = await _client.get(
      uri,
      headers: {
        'User-Agent': userAgent,
        'Referer': referer,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final features = decoded['features'];
      if (features is! List || features.isEmpty) {
        return null;
      }

      final first = features.first;
      if (first is! Map<String, dynamic>) {
        return null;
      }

      final properties = first['properties'];
      if (properties is! Map<String, dynamic>) {
        return null;
      }

      final geocoding = properties['geocoding'];
      if (geocoding is Map<String, dynamic>) {
        final label = geocoding['label'];
        if (label is String && label.trim().isNotEmpty) {
          return label.trim();
        }

        final name = geocoding['name'];
        if (name is String && name.trim().isNotEmpty) {
          return name.trim();
        }

        final city = geocoding['city'];
        final state = geocoding['state'];
        final country = geocoding['country'];
        final parts = [
          if (city is String && city.trim().isNotEmpty) city.trim(),
          if (state is String && state.trim().isNotEmpty) state.trim(),
          if (country is String && country.trim().isNotEmpty) country.trim(),
        ];
        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  void dispose() {
    _client.close();
  }
}
