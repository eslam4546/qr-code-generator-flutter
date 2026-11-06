import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
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
    // Non-mobile platforms (Desktop, Web) do not need mobile runtime permissions
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    if (Platform.isAndroid) {
      // In Android 10+ (API 29+), writing into MediaStore does not require runtime permissions.
      // However, on Android 9 and lower (API <= 28), WRITE_EXTERNAL_STORAGE is strictly required.
      final isLegacy = _isLegacyAndroid();

      if (isLegacy) {
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isGranted) return true;

        final storageReq = await Permission.storage.request();
        if (storageReq.isGranted) return true;

        if (storageReq.isPermanentlyDenied) {
          throw const StoragePermissionException(
            AppStrings.permissionPermanentlyDeniedError,
            isPermanentlyDenied: true,
          );
        }

        throw const StoragePermissionException(
          AppStrings.permissionDeniedError,
        );
      }

      // Modern Android (API 29+) uses scoped MediaStore insertion
      return true;
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

  bool _isLegacyAndroid() {
    try {
      final versionStr = Platform.operatingSystemVersion;
      // Extract API level e.g. "API 34" or Android version e.g. "Android 14"
      final apiMatch = RegExp(r'API\s+(\d+)').firstMatch(versionStr);
      if (apiMatch != null) {
        final api = int.tryParse(apiMatch.group(1) ?? '');
        if (api != null) return api < 29;
      }

      final androidMatch = RegExp(r'Android\s+(\d+)').firstMatch(versionStr);
      if (androidMatch != null) {
        final ver = int.tryParse(androidMatch.group(1) ?? '');
        if (ver != null) return ver < 10;
      }
    } catch (_) {}
    return false;
  }

  @override
  Future<String> saveImageToGallery({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final dynamic result = await ImageGallerySaverPlus.saveImage(
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
      final sanitizedName =
          fileName.endsWith('.png') ? fileName : '$fileName.png';
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
