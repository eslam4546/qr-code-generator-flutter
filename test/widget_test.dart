import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator_app/core/constants/app_strings.dart';
import 'package:qr_generator_app/core/utils/result.dart';
import 'package:qr_generator_app/features/qr_generator/domain/repositories/qr_repository.dart';
import 'package:qr_generator_app/features/qr_generator/presentation/widgets/qr_action_buttons.dart';
import 'package:qr_generator_app/features/qr_generator/presentation/widgets/qr_display_card.dart';
import 'package:qr_generator_app/main.dart';

class MockQrRepository implements QrRepository {
  @override
  Future<Result<String>> saveQrCodeToGallery({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    return Result.success('/path/qr.png');
  }

  @override
  Future<Result<void>> shareQrCode({
    required Uint8List imageBytes,
    required String fileName,
    String? text,
  }) async {
    return Result.success(null);
  }
}

void main() {
  late MockQrRepository mockRepository;

  setUp(() {
    mockRepository = MockQrRepository();
  });

  testWidgets(
    'Initial screen renders title, input field, and generate button',
    (WidgetTester tester) async {
      await tester.pumpWidget(QrGeneratorApp(qrRepository: mockRepository));

      // Verify AppBar title
      expect(find.text(AppStrings.appTitle), findsOneWidget);

      // Verify Input Field
      expect(find.byType(TextField), findsOneWidget);

      // Verify Generate Button
      expect(find.text(AppStrings.generateButton), findsOneWidget);

      // Verify placeholder is present and QR card is NOT yet displayed
      expect(find.text('Your QR code will appear here'), findsOneWidget);
      expect(find.byType(QrDisplayCard), findsNothing);
      expect(find.byType(QrActionButtons), findsNothing);
    },
  );

  testWidgets('Clicking generate with empty input displays error SnackBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(QrGeneratorApp(qrRepository: mockRepository));

    // Tap generate without entering anything
    await tester.tap(find.text(AppStrings.generateButton));
    await tester.pump(); // Start animation
    await tester.pump(
      const Duration(milliseconds: 300),
    ); // Complete SnackBar animation

    // Verify error SnackBar
    expect(find.text(AppStrings.emptyInputError), findsOneWidget);
  });

  testWidgets(
    'Entering text and clicking generate displays QR card and action buttons',
    (WidgetTester tester) async {
      await tester.pumpWidget(QrGeneratorApp(qrRepository: mockRepository));

      // Enter text into TextField
      await tester.enterText(find.byType(TextField), 'https://auspify.com');
      await tester.pump();

      // Tap Generate
      await tester.tap(find.text(AppStrings.generateButton));
      await tester.pumpAndSettle();

      // Verify QR Display Card and Action buttons appear
      expect(find.byType(QrDisplayCard), findsOneWidget);
      expect(find.byType(QrActionButtons), findsOneWidget);
      expect(find.text(AppStrings.saveButton), findsOneWidget);
      expect(find.text(AppStrings.shareButton), findsOneWidget);
      expect(find.text('Your QR code will appear here'), findsNothing);
    },
  );
}
