/// Base class for all data-level exceptions.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when device storage permission is denied.
class StoragePermissionException extends AppException {
  final bool isPermanentlyDenied;
  const StoragePermissionException(
    super.message, {
    this.isPermanentlyDenied = false,
  });
}

/// Thrown when image saving fails.
class ImageSaveException extends AppException {
  const ImageSaveException(super.message);
}

/// Thrown when image sharing fails.
class ImageShareException extends AppException {
  const ImageShareException(super.message);
}

/// Thrown when RepaintBoundary rendering to image fails.
class ImageCaptureException extends AppException {
  const ImageCaptureException(super.message);
}
