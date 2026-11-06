import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator_app/core/constants/app_strings.dart';
import 'package:qr_generator_app/core/errors/exceptions.dart';
import 'package:qr_generator_app/core/errors/failures.dart';
import 'package:qr_generator_app/features/qr_generator/data/datasources/qr_local_data_source.dart';
import 'package:qr_generator_app/features/qr_generator/data/repositories/qr_repository_impl.dart';

class MockQrLocalDataSource implements QrLocalDataSource {
  bool permissionGranted = true;
  bool throwPermissionPermanentlyDenied = false;
  String savedPath = '/path/to/gallery/qr.png';
  bool throwSaveError = false;
  bool throwShareError = false;

  @override
  Future<bool> checkAndRequestStoragePermission() async {
    if (throwPermissionPermanentlyDenied) {
      throw const StoragePermissionException(
        AppStrings.permissionPermanentlyDeniedError,
        isPermanentlyDenied: true,
      );
    }
    return permissionGranted;
  }

  @override
  Future<String> saveImageToGallery({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (throwSaveError) {
      throw const ImageSaveException('Disk write failed');
    }
    return savedPath;
  }

  @override
  Future<void> shareImage({
    required Uint8List imageBytes,
    required String fileName,
    String? subject,
    String? text,
  }) async {
    if (throwShareError) {
      throw const ImageShareException('Sharing cancelled or failed');
    }
  }
}

void main() {
  late MockQrLocalDataSource mockDataSource;
  late QrRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockQrLocalDataSource();
    repository = QrRepositoryImpl(localDataSource: mockDataSource);
  });

  group('QrRepositoryImpl', () {
    test(
      'saveQrCodeToGallery returns Result.success with path when successful',
      () async {
        final result = await repository.saveQrCodeToGallery(
          imageBytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'qr_test',
        );

        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals('/path/to/gallery/qr.png'));
      },
    );

    test(
      'saveQrCodeToGallery returns PermissionFailure when permission is denied',
      () async {
        mockDataSource.permissionGranted = false;

        final result = await repository.saveQrCodeToGallery(
          imageBytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'qr_test',
        );

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<PermissionFailure>());
        expect(
          result.failureOrNull?.message,
          equals(AppStrings.permissionDeniedError),
        );
      },
    );

    test(
      'saveQrCodeToGallery returns PermissionFailure with isPermanentlyDenied',
      () async {
        mockDataSource.throwPermissionPermanentlyDenied = true;

        final result = await repository.saveQrCodeToGallery(
          imageBytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'qr_test',
        );

        expect(result.isFailure, isTrue);
        final failure = result.failureOrNull as PermissionFailure;
        expect(failure.isPermanentlyDenied, isTrue);
        expect(
          failure.message,
          equals(AppStrings.permissionPermanentlyDeniedError),
        );
      },
    );

    test('saveQrCodeToGallery returns SaveFailure when data source throws ImageSaveException', () async {
      mockDataSource.throwSaveError = true;

      final result = await repository.saveQrCodeToGallery(
        imageBytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'qr_test',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<SaveFailure>());
    });

    test('shareQrCode returns Result.success when sharing succeeds', () async {
      final result = await repository.shareQrCode(
        imageBytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'qr_share',
        text: 'hello',
      );

      expect(result.isSuccess, isTrue);
    });

    test('shareQrCode returns ShareFailure when data source throws ImageShareException', () async {
      mockDataSource.throwShareError = true;

      final result = await repository.shareQrCode(
        imageBytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'qr_share',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ShareFailure>());
    });
  });
}
