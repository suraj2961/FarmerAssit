import 'package:flutter/material.dart';
import '../config/negilu_tokens.dart';

/// Reusable FarmerAssist Brand Logo Badge
class FarmerLogoBadge extends StatelessWidget {
  final double size;
  final bool withBackground;
  final VoidCallback? onTap;

  const FarmerLogoBadge({
    super.key,
    this.size = 38,
    this.withBackground = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Padding(
      padding: EdgeInsets.all(size * 0.08),
      child: Image.asset(
        'assets/images/app_logo_icon.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.agriculture_rounded,
          color: NegiluColors.brandGreenDark,
          size: size * 0.65,
        ),
      ),
    );

    if (withBackground) {
      image = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE8DFC8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipOval(child: image),
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        child: image,
      );
    }

    return image;
  }
}

/// Full Brand Logo with Symbol and Text
class FarmerLogoFull extends StatelessWidget {
  final double height;

  const FarmerLogoFull({
    super.key,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: NegiluRadii.borderLg,
        border: Border.all(color: const Color(0xFFE8DFC8)),
        boxShadow: NegiluShadows.sm,
      ),
      child: Image.asset(
        'assets/images/app_logo.png',
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.agriculture_rounded, color: NegiluColors.brandGreenDark, size: 32),
            const SizedBox(width: 8),
            Text(
              'FARMMER ASSIST',
              style: NegiluTypography.heading(color: NegiluColors.brandGreenDark, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
