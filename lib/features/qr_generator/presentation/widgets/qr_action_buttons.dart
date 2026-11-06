import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

class QrActionButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onShare;
  final bool isSaving;
  final bool isSharing;

  const QrActionButtons({
    super.key,
    required this.onSave,
    required this.onShare,
    this.isSaving = false,
    this.isSharing = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBusy = isSaving || isSharing;

    return Row(
      children: [
        // Save to Gallery Button
        Expanded(
          child: ElevatedButton(
            onPressed: isBusy ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
              disabledForegroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
            ),
            child: isSaving
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.sm),
                      Text(AppStrings.saving),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_alt_rounded, size: 20),
                      SizedBox(width: AppDimensions.sm),
                      Text(AppStrings.saveButton),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        // Share Button
        Expanded(
          child: OutlinedButton(
            onPressed: isBusy ? null : onShare,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
            ),
            child: isSharing
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.sm),
                      Text(AppStrings.sharing),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share_rounded, size: 20),
                      SizedBox(width: AppDimensions.sm),
                      Text(AppStrings.shareButton),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
