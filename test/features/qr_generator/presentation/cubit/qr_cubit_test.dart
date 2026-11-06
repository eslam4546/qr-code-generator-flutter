import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator_app/core/constants/app_strings.dart';
import 'package:qr_generator_app/core/errors/failures.dart';
import 'package:qr_generator_app/core/utils/qr_image_capturer.dart';
import 'package:qr_generator_app/core/utils/result.dart';
import 'package:qr_generator_app/features/qr_generator/domain/repositories/qr_repository.dart';
import 'package:qr_generator_app/features/qr_generator/presentation/cubit/qr_cubit.dart';
import 'package:qr_generator_app/features/qr_generator/presentation/cubit/qr_state.dart';

class MockQrRepository implements QrRepository {
  Result<String> saveResult = Result.success(
    '/storage/emulated/0/Pictures/qr.png',
  );
  Result<void> shareResult = Result.success(null);

  @override
  Future<Result<String>> saveQrCodeToGallery({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    return saveResult;
  }

  @override
  Future<Result<void>> shareQrCode({
    required Uint8List imageBytes,
    required String fileName,
    String? text,
  }) async {
    return shareResult;
  }
}

class FakeQrImageCapturer extends QrImageCapturer {
  const FakeQrImageCapturer();

  @override
  Future<Uint8List> capturePng(
    GlobalKey repaintBoundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    return Uint8List.fromList([1, 2, 3, 4]);
  }
}

void main() {
  late MockQrRepository mockRepository;
  late FakeQrImageCapturer fakeCapturer;
  late QrCubit cubit;

  setUp(() {
    mockRepository = MockQrRepository();
    fakeCapturer = const FakeQrImageCapturer();
    cubit = QrCubit(
      qrRepository: mockRepository,
      qrImageCapturer: fakeCapturer,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('QrCubit', () {
    test('initial state should be QrInitial', () {
      expect(cubit.state, equals(const QrInitial()));
    });

    test('generateQr with valid text should emit QrGeneratedSuccess', () {
      const testInput = 'https://auspify.com';

      expectLater(
        cubit.stream,
        emitsInOrder([const QrGeneratedSuccess(qrData: testInput)]),
      );

      cubit.generateQr(testInput);
    });

    test(
      'generateQr with empty text should emit QrError with empty input message',
      () {
        expectLater(
          cubit.stream,
          emitsInOrder([
            const QrError(message: AppStrings.emptyInputError, qrData: null),
          ]),
        );

        cubit.generateQr('   ');
      },
    );

    test('saveQrToGallery emits saving state, then feedback success, then normal success', () async {
      final key = GlobalKey();
      cubit.generateQr('test_qr');

      final expectedStates = [
        const QrGeneratedSuccess(
          qrData: 'test_qr',
          isSaving: true,
          isSharing: false,
        ),
        const QrFeedbackSuccess(
          message: AppStrings.saveSuccess,
          qrData: 'test_qr',
        ),
        const QrGeneratedSuccess(
          qrData: 'test_qr',
          isSaving: false,
          isSharing: false,
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.saveQrToGallery(key);
    });

    test(
      'saveQrToGallery emits QrError when repository returns PermissionFailure',
      () async {
        final key = GlobalKey();
        cubit.generateQr('test_qr');

        mockRepository.saveResult = Result.failure(
          const PermissionFailure(AppStrings.permissionDeniedError),
        );

        final expectedStates = [
          const QrGeneratedSuccess(
            qrData: 'test_qr',
            isSaving: true,
            isSharing: false,
          ),
          const QrError(
            message: AppStrings.permissionDeniedError,
            qrData: 'test_qr',
          ),
          const QrGeneratedSuccess(
            qrData: 'test_qr',
            isSaving: false,
            isSharing: false,
          ),
        ];

        expectLater(cubit.stream, emitsInOrder(expectedStates));

        await cubit.saveQrToGallery(key);
      },
    );

    test('shareQrCode emits sharing state, then feedback success, then normal success', () async {
      final key = GlobalKey();
      cubit.generateQr('test_qr');

      final expectedStates = [
        const QrGeneratedSuccess(
          qrData: 'test_qr',
          isSaving: false,
          isSharing: true,
        ),
        const QrFeedbackSuccess(
          message: AppStrings.shareSuccess,
          qrData: 'test_qr',
        ),
        const QrGeneratedSuccess(
          qrData: 'test_qr',
          isSaving: false,
          isSharing: false,
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.shareQrCode(key);
    });

    test('reset emits QrInitial', () {
      cubit.generateQr('test_qr');
      expect(cubit.state, isA<QrGeneratedSuccess>());

      cubit.reset();
      expect(cubit.state, equals(const QrInitial()));
    });
  });
}
