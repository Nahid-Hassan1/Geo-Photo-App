import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/colors.dart';
import '../../widgets/camera_button.dart';
import '../preview/preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  static const routeName = '/camera';

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeCameraFuture;
  String? _errorMessage;
  bool _isCapturing = false;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCameraFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No camera was found on this device.';
        });
        return;
      }

      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.description ?? error.code;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      await _initializeCameraFuture;
      final image = await controller.takePicture();
      final bytes = await image.readAsBytes();
      final position = await _determinePosition();

      _capturedImagePath = image.path;

      if (!mounted) {
        return;
      }

      await Navigator.of(context).pushNamed(
        PreviewScreen.routeName,
        arguments: PreviewScreenArgs(
          imagePath: image.path,
          imageBytes: bytes,
          latitude: position?.latitude,
          longitude: position?.longitude,
        ),
      );
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.description ?? 'Failed to capture photo.'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to capture photo.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<Position?> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location services are disabled.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                Geolocator.openLocationSettings();
              },
            ),
          ),
        );
      }
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission was denied.'),
          ),
        );
      }
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Location permission is permanently denied.',
            ),
            action: SnackBarAction(
              label: 'App Settings',
              onPressed: () {
                Geolocator.openAppSettings();
              },
            ),
          ),
        );
      }
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to retrieve the current location.'),
          ),
        );
      }
      return null;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF181C1B),
                          Color(0xFF222826),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_cameraController != null &&
                            _cameraController!.value.isInitialized)
                          CameraPreview(_cameraController!),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.10),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.12),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        if (_cameraController == null ||
                            !_cameraController!.value.isInitialized)
                          _CameraPlaceholder(
                            errorMessage: _errorMessage,
                            lastCapturedImagePath: _capturedImagePath,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CameraButton(
                onPressed: _capturePhoto,
              ),
              if (_isCapturing) ...[
                const SizedBox(height: 12),
                Text(
                  'Capturing photo...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder({
    required this.errorMessage,
    required this.lastCapturedImagePath,
  });

  final String? errorMessage;
  final String? lastCapturedImagePath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Icon(
                errorMessage == null
                    ? Icons.photo_camera_back_rounded
                    : Icons.warning_amber_rounded,
                size: 56,
                color: AppColors.primaryAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              errorMessage == null ? 'Opening camera...' : 'Camera unavailable',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ??
                  'Preparing the live camera preview for this screen.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (lastCapturedImagePath != null) ...[
              const SizedBox(height: 12),
              Text(
                'Last capture stored.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryAccent,
                    ),
              ),
            ],
            if (errorMessage == null) ...[
              const SizedBox(height: 16),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
