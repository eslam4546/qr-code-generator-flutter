import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class QrDisplayCard extends StatelessWidget {
  final GlobalKey boundaryKey;
  final String qrData;

  const QrDisplayCard({
    super.key,
    required this.boundaryKey,
    required this.qrData,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RepaintBoundary(
        key: boundaryKey,
        child: Container(
          width: AppDimensions.qrDisplaySize + 60,
          padding: const EdgeInsets.all(AppDimensions.qrCardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.cardBorder, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000), // Very subtle shadow
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: AppDimensions.qrDisplaySize,
                gapless: true,
                backgroundColor: AppColors.qrBackground,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.qrForeground,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.qrForeground,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                qrData,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
