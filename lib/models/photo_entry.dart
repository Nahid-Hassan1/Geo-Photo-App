class PhotoEntry {
  PhotoEntry({
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  final String imagePath;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  String get title =>
      'Photo ${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

  String get subtitle =>
      'Lat ${latitude.toStringAsFixed(6)}, Lng ${longitude.toStringAsFixed(6)}';

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PhotoEntry.fromJson(Map<String, dynamic> json) {
    return PhotoEntry(
      imagePath: json['imagePath'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
