import 'dart:typed_data';

import '../../../../core/utils/result.dart';

/// Contract for QR code persistence and distribution operations.
abstract class QrRepository {
  /// Saves the rendered QR image to the device gallery.
  /// Returns the file path or identifier upon success, or a [Failure] on error.
  Future<Result<String>> saveQrCodeToGallery({
    required Uint8List imageBytes,
    required String fileName,
  });

  /// Shares the rendered QR image using the platform's native share sheet.
  /// Returns success or a [Failure] on error.
  Future<Result<void>> shareQrCode({
    required Uint8List imageBytes,
    required String fileName,
    String? text,
  });
}
