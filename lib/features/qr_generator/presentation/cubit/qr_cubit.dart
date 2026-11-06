import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/qr_image_capturer.dart';
import '../../domain/repositories/qr_repository.dart';
import 'qr_state.dart';

class QrCubit extends Cubit<QrState> {
  final QrRepository qrRepository;
  final QrImageCapturer qrImageCapturer;

  QrCubit({
    required this.qrRepository,
    this.qrImageCapturer = const QrImageCapturer(),
  }) : super(const QrInitial());

  /// Helper to extract currently displayed QR data across states.
  String? get currentQrData {
    final s = state;
    if (s is QrGeneratedSuccess) return s.qrData;
    if (s is QrFeedbackSuccess) return s.qrData;
    if (s is QrError) return s.qrData;
    return null;
  }

  /// Generates a new QR code from user input or triggers validation error.
  void generateQr(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      final existing = currentQrData;
      emit(QrError(message: AppStrings.emptyInputError, qrData: existing));
      if (existing != null) {
        emit(QrGeneratedSuccess(qrData: existing));
      }
      return;
    }

    emit(QrGeneratedSuccess(qrData: trimmed));
  }

  /// Captures the QR widget from [boundaryKey] and saves it to the gallery.
  Future<void> saveQrToGallery(GlobalKey boundaryKey) async {
    final qrData = currentQrData;
    if (qrData == null) return;

    final currentState = state;
    if (currentState is QrGeneratedSuccess && currentState.isSaving) return;

    emit(
      QrGeneratedSuccess(
        qrData: qrData,
        isSaving: true,
        isSharing: currentState is QrGeneratedSuccess
            ? currentState.isSharing
            : false,
      ),
    );

    try {
      final Uint8List imageBytes = await qrImageCapturer.capturePng(
        boundaryKey,
      );
      final fileName = 'qr_${DateTime.now().millisecondsSinceEpoch}';

      final result = await qrRepository.saveQrCodeToGallery(
        imageBytes: imageBytes,
        fileName: fileName,
      );

      result.when(
        onSuccess: (_) {
          emit(
            QrFeedbackSuccess(message: AppStrings.saveSuccess, qrData: qrData),
          );
          emit(QrGeneratedSuccess(qrData: qrData));
        },
        onFailure: (failure) {
          emit(QrError(message: failure.message, qrData: qrData));
          emit(QrGeneratedSuccess(qrData: qrData));
        },
      );
    } on ImageCaptureException catch (e) {
      emit(QrError(message: e.message, qrData: qrData));
      emit(QrGeneratedSuccess(qrData: qrData));
    } catch (e) {
      emit(
        QrError(message: '${AppStrings.saveFailedError}: $e', qrData: qrData),
      );
      emit(QrGeneratedSuccess(qrData: qrData));
    }
  }

  /// Captures the QR widget from [boundaryKey] and shares it via native share sheet.
  Future<void> shareQrCode(GlobalKey boundaryKey) async {
    final qrData = currentQrData;
    if (qrData == null) return;

    final currentState = state;
    if (currentState is QrGeneratedSuccess && currentState.isSharing) return;

    emit(
      QrGeneratedSuccess(
        qrData: qrData,
        isSaving: currentState is QrGeneratedSuccess
            ? currentState.isSaving
            : false,
        isSharing: true,
      ),
    );

    try {
      final Uint8List imageBytes = await qrImageCapturer.capturePng(
        boundaryKey,
      );
      final fileName = 'qr_share_${DateTime.now().millisecondsSinceEpoch}';

      final result = await qrRepository.shareQrCode(
        imageBytes: imageBytes,
        fileName: fileName,
        text: qrData,
      );

      result.when(
        onSuccess: (_) {
          emit(
            QrFeedbackSuccess(message: AppStrings.shareSuccess, qrData: qrData),
          );
          emit(QrGeneratedSuccess(qrData: qrData));
        },
        onFailure: (failure) {
          emit(QrError(message: failure.message, qrData: qrData));
          emit(QrGeneratedSuccess(qrData: qrData));
        },
      );
    } on ImageCaptureException catch (e) {
      emit(QrError(message: e.message, qrData: qrData));
      emit(QrGeneratedSuccess(qrData: qrData));
    } catch (e) {
      emit(
        QrError(message: '${AppStrings.shareFailedError}: $e', qrData: qrData),
      );
      emit(QrGeneratedSuccess(qrData: qrData));
    }
  }

  /// Resets back to the initial blank state.
  void reset() {
    emit(const QrInitial());
  }
}
