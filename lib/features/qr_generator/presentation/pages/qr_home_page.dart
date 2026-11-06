import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../cubit/qr_cubit.dart';
import '../cubit/qr_state.dart';
import '../widgets/qr_action_buttons.dart';
import '../widgets/qr_display_card.dart';
import '../widgets/qr_input_section.dart';

class QrHomePage extends StatefulWidget {
  const QrHomePage({super.key});

  @override
  State<QrHomePage> createState() => _QrHomePageState();
}

class _QrHomePageState extends State<QrHomePage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  void _showSnackBar({
    required BuildContext context,
    required String message,
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        margin: const EdgeInsets.all(AppDimensions.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 26),
            SizedBox(width: AppDimensions.sm),
            Text(AppStrings.appTitle),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<QrCubit, QrState>(
          listener: (context, state) {
            if (state is QrError) {
              _showSnackBar(
                context: context,
                message: state.message,
                isError: true,
              );
            } else if (state is QrFeedbackSuccess) {
              _showSnackBar(
                context: context,
                message: state.message,
                isError: false,
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<QrCubit>();
            final qrData = cubit.currentQrData;
            final isSuccessState = state is QrGeneratedSuccess;
            final isSaving = isSuccessState ? state.isSaving : false;
            final isSharing = isSuccessState ? state.isSharing : false;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg,
                vertical: AppDimensions.md,
              ),
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Tagline / Subtitle
                  const Center(
                    child: Text(
                      AppStrings.appSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // Input Section
                  QrInputSection(onGenerate: (text) => cubit.generateQr(text)),

                  // Dynamic QR Display and Action Area
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: qrData != null
                        ? Column(
                            key: const ValueKey('qr_content_visible'),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: AppDimensions.xl),
                              QrDisplayCard(
                                boundaryKey: _repaintBoundaryKey,
                                qrData: qrData,
                              ),
                              const SizedBox(height: AppDimensions.xl),
                              QrActionButtons(
                                onSave: () =>
                                    cubit.saveQrToGallery(_repaintBoundaryKey),
                                onShare: () =>
                                    cubit.shareQrCode(_repaintBoundaryKey),
                                isSaving: isSaving,
                                isSharing: isSharing,
                              ),
                            ],
                          )
                        : Container(
                            key: const ValueKey('qr_placeholder'),
                            padding: const EdgeInsets.only(
                              top: AppDimensions.xxl,
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(
                                    AppDimensions.lg,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.md),
                                const Text(
                                  'Your QR code will appear here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
