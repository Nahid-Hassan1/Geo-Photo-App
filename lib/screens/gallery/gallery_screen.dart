import 'package:flutter/material.dart';

import '../../models/photo_entry.dart';
import '../../services/local_gallery_service.dart';
import '../../widgets/photo_card.dart';
import 'photo_detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  static const routeName = '/gallery';

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late final LocalGalleryService _galleryService;
  late Future<List<PhotoEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _galleryService = LocalGalleryService();
    _entriesFuture = _galleryService.fetchEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<PhotoEntry>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load photos: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            final entries = snapshot.data ?? [];
            if (entries.isEmpty) {
              return const Center(
                child: Text('No photos saved yet.'),
              );
            }

            return GridView.builder(
              itemCount: entries.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return PhotoCard(
                  title: entry.title,
                  subtitle: entry.subtitle,
                  imagePath: entry.imagePath,
                  overlayText: entry.subtitle,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      PhotoDetailScreen.routeName,
                      arguments: entry,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
