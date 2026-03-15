import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String defaultUploadUrl = String.fromEnvironment(
    'PHOTO_UPLOAD_URL',
    defaultValue: 'https://tianna-toothed-insusceptibly.ngrok-free.dev/api/upload-photo/',
  );

  ApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<UploadPhotoResponse> uploadPhoto(
    String imagePath,
    double latitude,
    double longitude,
    String category, {
    String? locationName,
    String? note,
  }) async {
    final uri = Uri.parse(baseUrl);

    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['latitude'] = latitude.toString()
        ..fields['longitude'] = longitude.toString()
        ..fields['category'] = category;

      if (locationName != null && locationName.trim().isNotEmpty) {
        request.fields['location_name'] = locationName.trim();
      }

      if (note != null && note.trim().isNotEmpty) {
        request.fields['note'] = note.trim();
      }

      request.files.add(
        await http.MultipartFile.fromPath('image', imagePath),
      );

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      return UploadPhotoResponse(
        success: isSuccess,
        statusCode: response.statusCode,
        message: isSuccess ? 'Upload successful.' : 'Upload failed.',
        body: _tryDecodeBody(response.body),
      );
    } catch (error) {
      return UploadPhotoResponse(
        success: false,
        statusCode: null,
        message: error.toString(),
      );
    }
  }

  Object? _tryDecodeBody(String body) {
    if (body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  void dispose() {
    _client.close();
  }
}

class UploadPhotoResponse {
  const UploadPhotoResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.body,
  });

  final bool success;
  final int? statusCode;
  final String message;
  final Object? body;
}
