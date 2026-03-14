import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../services/api_service.dart';
import '../../services/local_gallery_service.dart';
import '../../widgets/primary_button.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  static const routeName = '/preview';

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late final ApiService _apiService;
  late final LocalGalleryService _galleryService;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(baseUrl: ApiService.defaultUploadUrl);
    _galleryService = LocalGalleryService();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _savePhoto(PreviewScreenArgs? args) async {
    if (args == null) {
      _showMessage('No captured photo is available.');
      return;
    }

    if (!args.hasCoordinates) {
      _showMessage('Latitude and longitude are required before upload.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await _galleryService.saveEntry(
        sourcePath: args.imagePath,
        latitude: args.latitude!,
        longitude: args.longitude!,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isUploading = false;
      });
      _showMessage('Failed to save photo locally: $error');
      return;
    }

    final response = await _apiService.uploadPhoto(
      args.imagePath,
      args.latitude!,
      args.longitude!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isUploading = false;
    });

    if (!response.success) {
      _showMessage(
        'Saved locally, but upload failed. ${response.message}',
      );
      return;
    }

    _showMessage('Photo saved locally and uploaded successfully.');
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as PreviewScreenArgs?;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B0D0D),
                  Color(0xFF121615),
                  Color(0xFF171C1A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 120,
                  left: -60,
                  child: _AmbientGlow(
                    size: 220,
                    color: Color(0x226E7F6A),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _TopAction(
                              icon: Icons.arrow_back_rounded,
                              onTap: _isUploading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                            ),
                            const Expanded(
                              child: Text(
                                'Preview',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const _TopAction(icon: Icons.more_horiz_rounded),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: Colors.white.withValues(alpha: 0.03),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 360,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF242A27),
                                            Color(0xFF171C1A),
                                            Color(0xFF0E1211),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.06,
                                          ),
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                gradient: RadialGradient(
                                                  center: const Alignment(
                                                    0,
                                                    -0.1,
                                                  ),
                                                  radius: 1.05,
                                                  colors: [
                                                    AppColors.primaryAccent
                                                        .withValues(alpha: 0.2),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (args?.imageBytes
                                              case final bytes?)
                                            Positioned.fill(
                                              child: Image.memory(
                                                bytes,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          else
                                            Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            22),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white
                                                          .withValues(
                                                        alpha: 0.06,
                                                      ),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withValues(
                                                          alpha: 0.08,
                                                        ),
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.image_rounded,
                                                      size: 58,
                                                      color: AppColors
                                                          .primaryAccent,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 18),
                                                  Text(
                                                    'Captured Photo',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge
                                                        ?.copyWith(
                                                            fontSize: 26),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    'Your final image preview will appear here before saving with coordinate details.',
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                            height: 1.55),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          Positioned.fill(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.black.withValues(
                                                      alpha: 0.06,
                                                    ),
                                                    Colors.transparent,
                                                    Colors.black.withValues(
                                                      alpha: 0.16,
                                                    ),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Positioned(
                                      top: 16,
                                      left: 16,
                                      child: _PreviewTag(
                                        icon:
                                            Icons.check_circle_outline_rounded,
                                        label: 'Ready to save',
                                      ),
                                    ),
                                    const Positioned(
                                      top: 16,
                                      right: 16,
                                      child: _PreviewTag(
                                        icon: Icons.location_on_outlined,
                                        label: 'GPS metadata',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Expanded(
                                    child: _StatCard(
                                      label: 'Capture Quality',
                                      value: 'High',
                                      icon: Icons.auto_awesome_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _StatCard(
                                      label: 'Status',
                                      value: args?.hasCoordinates == true
                                          ? 'Tagged'
                                          : 'Missing',
                                      icon: Icons.gps_fixed_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _CoordinateCard(
                                label: 'Latitude',
                                value: args?.latitudeLabel ?? '--',
                                icon: Icons.north_rounded,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _CoordinateCard(
                                label: 'Longitude',
                                value: args?.longitudeLabel ?? '--',
                                icon: Icons.east_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: Colors.white.withValues(alpha: 0.03),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Column(
                            children: [
                              PrimaryButton(
                                label: _isUploading
                                    ? 'Uploading...'
                                    : 'Save Photo',
                                icon: _isUploading
                                    ? Icons.cloud_upload_rounded
                                    : Icons.save_rounded,
                                onPressed: _isUploading
                                    ? () {}
                                    : () => _savePhoto(args),
                              ),
                              const SizedBox(height: 12),
                              PrimaryButton(
                                label: 'Retake',
                                icon: Icons.refresh_rounded,
                                isOutlined: true,
                                onPressed: _isUploading
                                    ? () {}
                                    : () {
                                        Navigator.of(context).pop();
                                      },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isUploading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Uploading photo...',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _TopAction extends StatelessWidget {
  const _TopAction({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}

class _PreviewTag extends StatelessWidget {
  const _PreviewTag({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryAccent),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryAccent, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _CoordinateCard extends StatelessWidget {
  const _CoordinateCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 26,
                ),
          ),
        ],
      ),
    );
  }
}

class PreviewScreenArgs {
  const PreviewScreenArgs({
    required this.imagePath,
    required this.imageBytes,
    required this.latitude,
    required this.longitude,
  });

  final String imagePath;
  final Uint8List imageBytes;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  String get latitudeLabel => latitude?.toStringAsFixed(6) ?? '--';

  String get longitudeLabel => longitude?.toStringAsFixed(6) ?? '--';
}
