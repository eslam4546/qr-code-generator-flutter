import 'dart:io';
import 'dart:typed_data';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';

abstract class QrLocalDataSource {
  /// Checks and requests necessary storage or photo permissions from the OS.
  Future<bool> checkAndRequestStoragePermission();

  /// Saves the given image bytes directly into the system's gallery.
  Future<String> saveImageToGallery({
    required Uint8List imageBytes,
    required String fileName,
  });

  /// Saves bytes temporarily and triggers the native OS share sheet.
  Future<void> shareImage({
    required Uint8List imageBytes,
    required String fileName,
    String? subject,
    String? text,
  });
}

class QrLocalDataSourceImpl implements QrLocalDataSource {
  const QrLocalDataSourceImpl();

  @override
  Future<bool> checkAndRequestStoragePermission() async {
    // Web or desktop platforms do not require mobile runtime permissions
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    if (Platform.isAndroid) {
      // Check standard storage permission (Android <= 12)
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) return true;

      // Check photos permission (Android 13+ / API 33+)
      final photosStatus = await Permission.photos.status;
      if (photosStatus.isGranted) return true;

      // Request storage permission first
      final storageReq = await Permission.storage.request();
      if (storageReq.isGranted) return true;

      // Fallback request photos permission
      final photosReq = await Permission.photos.request();
      if (photosReq.isGranted) return true;

      if (storageReq.isPermanentlyDenied || photosReq.isPermanentlyDenied) {
        throw const StoragePermissionException(
          AppStrings.permissionPermanentlyDeniedError,
          isPermanentlyDenied: true,
        );
      }

      throw const StoragePermissionException(AppStrings.permissionDeniedError);
    }

    if (Platform.isIOS) {
      final photosStatus = await Permission.photos.status;
      if (photosStatus.isGranted || photosStatus.isLimited) return true;

      final req = await Permission.photos.request();
      if (req.isGranted || req.isLimited) return true;

      if (req.isPermanentlyDenied) {
        throw const StoragePermissionException(
          AppStrings.permissionPermanentlyDeniedError,
          isPermanentlyDenied: true,
        );
      }

      throw const StoragePermissionException(AppStrings.permissionDeniedError);
    }

    return true;
  }

  @override
  Future<String> saveImageToGallery({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final dynamic result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: fileName,
      );

      if (result is Map) {
        final bool isSuccess = result['isSuccess'] == true;
        if (isSuccess) {
          final String? filePath = result['filePath']?.toString();
          return filePath ?? fileName;
        } else {
          final String error =
              result['errorMessage']?.toString() ?? AppStrings.saveFailedError;
          throw ImageSaveException(error);
        }
      }

      if (result != null) {
        return result.toString();
      }

      throw const ImageSaveException(AppStrings.saveFailedError);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ImageSaveException('${AppStrings.saveFailedError}: $e');
    }
  }

  @override
  Future<void> shareImage({
    required Uint8List imageBytes,
    required String fileName,
    String? subject,
    String? text,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final sanitizedName = fileName.endsWith('.png')
          ? fileName
          : '$fileName.png';
      final file = File('${tempDir.path}/$sanitizedName');

      await file.writeAsBytes(imageBytes, flush: true);

      final shareParams = ShareParams(
        files: [XFile(file.path, mimeType: 'image/png', name: sanitizedName)],
        subject: subject ?? AppStrings.appTitle,
        text: text,
      );

      await SharePlus.instance.share(shareParams);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ImageShareException('${AppStrings.shareFailedError}: $e');
    }
  }
}
