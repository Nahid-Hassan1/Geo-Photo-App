class PhotoEntry {
  PhotoEntry({
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.note,
    required this.createdAt,
  });

  final String imagePath;
  final double latitude;
  final double longitude;
  final String? locationName;
  final String? note;
  final DateTime createdAt;

  String get title =>
      'Photo ${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

  String get coordinatesLabel =>
      'Lat ${latitude.toStringAsFixed(6)}, Lng ${longitude.toStringAsFixed(6)}';

  String get subtitle {
    final name = locationName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return coordinatesLabel;
  }

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PhotoEntry.fromJson(Map<String, dynamic> json) {
    return PhotoEntry(
      imagePath: json['imagePath'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationName: json['locationName'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
