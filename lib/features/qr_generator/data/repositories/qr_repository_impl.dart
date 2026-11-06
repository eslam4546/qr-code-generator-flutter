import 'dart:typed_data';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/qr_repository.dart';
import '../datasources/qr_local_data_source.dart';

class QrRepositoryImpl implements QrRepository {
  final QrLocalDataSource localDataSource;

  const QrRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<String>> saveQrCodeToGallery({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      // 1. Check and request storage permissions first
      final hasPermission = await localDataSource
          .checkAndRequestStoragePermission();
      if (!hasPermission) {
        return Result.failure(
          const PermissionFailure(AppStrings.permissionDeniedError),
        );
      }

      // 2. Save image to gallery
      final savedPath = await localDataSource.saveImageToGallery(
        imageBytes: imageBytes,
        fileName: fileName,
      );

      return Result.success(savedPath);
    } on StoragePermissionException catch (e) {
      return Result.failure(
        PermissionFailure(
          e.message,
          isPermanentlyDenied: e.isPermanentlyDenied,
        ),
      );
    } on ImageSaveException catch (e) {
      return Result.failure(SaveFailure(e.message));
    } catch (e) {
      return Result.failure(SaveFailure('${AppStrings.saveFailedError}: $e'));
    }
  }

  @override
  Future<Result<void>> shareQrCode({
    required Uint8List imageBytes,
    required String fileName,
    String? text,
  }) async {
    try {
      await localDataSource.shareImage(
        imageBytes: imageBytes,
        fileName: fileName,
        subject: AppStrings.appTitle,
        text: text,
      );
      return Result.success(null);
    } on ImageShareException catch (e) {
      return Result.failure(ShareFailure(e.message));
    } catch (e) {
      return Result.failure(ShareFailure('${AppStrings.shareFailedError}: $e'));
    }
  }
}
