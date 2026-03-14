import 'package:flutter/material.dart';

import '../core/constants/colors.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({super.key, required this.onPressed, this.size = 92});

  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.primaryAccent, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x406E7F6A),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
            color: AppColors.surface,
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 36,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
