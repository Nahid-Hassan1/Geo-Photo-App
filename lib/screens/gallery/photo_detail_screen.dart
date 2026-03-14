import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/photo_entry.dart';

class PhotoDetailScreen extends StatelessWidget {
  const PhotoDetailScreen({super.key});

  static const routeName = '/photo-detail';

  @override
  Widget build(BuildContext context) {
    final entry = ModalRoute.of(context)?.settings.arguments as PhotoEntry?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Details'),
      ),
      body: entry == null
          ? const Center(child: Text('No photo found.'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(entry.imagePath),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    entry.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Latitude: ${entry.latitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Longitude: ${entry.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Captured: ${entry.createdAt}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
    );
  }
}
