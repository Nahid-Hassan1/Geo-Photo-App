import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/photo_entry.dart';

class LocalGalleryService {
  static const String _storageKey = 'photo_entries';

  Future<List<PhotoEntry>> fetchEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final entries = decoded
        .map((item) => PhotoEntry.fromJson(item as Map<String, dynamic>))
        .toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<PhotoEntry> saveEntry({
    required String sourcePath,
    required double latitude,
    required double longitude,
  }) async {
    final documents = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(documents.path, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final extension = path.extension(sourcePath);
    final safeExtension = extension.isNotEmpty ? extension : '.jpg';
    final filename =
        'CAP_${DateTime.now().millisecondsSinceEpoch}$safeExtension';
    final destination = path.join(photosDir.path, filename);

    final sourceFile = File(sourcePath);
    final savedFile = await sourceFile.copy(destination);

    final entry = PhotoEntry(
      imagePath: savedFile.path,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
    );

    final entries = await fetchEntries();
    entries.insert(0, entry);
    await _persistEntries(entries);

    return entry;
  }

  Future<void> _persistEntries(List<PhotoEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
