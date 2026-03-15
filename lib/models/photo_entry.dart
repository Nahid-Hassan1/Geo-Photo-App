class PhotoEntry {
  PhotoEntry({
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.category,
    this.locationName,
    this.note,
  });

  final String imagePath;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String category;
  final String? locationName;
  final String? note;

  String get title =>
      'Photo ${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

  String get subtitle =>
      'Lat ${latitude.toStringAsFixed(6)}, Lng ${longitude.toStringAsFixed(6)}';

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': createdAt.toIso8601String(),
        'category': category,
        'locationName': locationName,
        'note': note,
      };

  factory PhotoEntry.fromJson(Map<String, dynamic> json) {
    return PhotoEntry(
      imagePath: json['imagePath'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: (json['category'] as String?) ?? 'Uncategorized',
      locationName: json['locationName'] as String?,
      note: json['note'] as String?,
    );
  }
}
