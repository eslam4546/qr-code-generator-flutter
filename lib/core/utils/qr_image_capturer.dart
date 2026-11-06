import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../constants/app_strings.dart';
import '../errors/exceptions.dart';

/// Helper utility to capture any widget tree marked with [RepaintBoundary]
/// into a high-resolution PNG byte buffer.
class QrImageCapturer {
  const QrImageCapturer();

  /// Captures the boundary identified by [repaintBoundaryKey] and returns its PNG bytes.
  Future<Uint8List> capturePng(
    GlobalKey repaintBoundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    try {
      final context = repaintBoundaryKey.currentContext;
      if (context == null) {
        throw const ImageCaptureException(AppStrings.captureFailedError);
      }

      final boundary = context.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw const ImageCaptureException(AppStrings.captureFailedError);
      }

      // Render boundary to image
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw const ImageCaptureException(AppStrings.captureFailedError);
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      if (e is ImageCaptureException) rethrow;
      throw ImageCaptureException('${AppStrings.captureFailedError}: $e');
    }
  }
}
