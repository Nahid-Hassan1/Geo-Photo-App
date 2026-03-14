import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/camera/camera_screen.dart';
import 'screens/gallery/gallery_screen.dart';
import 'screens/gallery/photo_detail_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/preview/preview_screen.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const GeoPhotoApp());
}

class GeoPhotoApp extends StatelessWidget {
  const GeoPhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geo Photo App',
      theme: AppTheme.darkTheme,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        CameraScreen.routeName: (_) => const CameraScreen(),
        PreviewScreen.routeName: (_) => const PreviewScreen(),
        GalleryScreen.routeName: (_) => const GalleryScreen(),
        PhotoDetailScreen.routeName: (_) => const PhotoDetailScreen(),
      },
    );
  }
}
