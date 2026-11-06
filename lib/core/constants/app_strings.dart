/// Centralized user-facing strings and message constants.
class AppStrings {
  const AppStrings._();

  static const String appTitle = 'QR Generator';
  static const String appSubtitle =
      'Generate, save, and share QR codes instantly';

  // Input Section
  static const String inputLabel = 'Enter Text or URL';
  static const String inputHint = 'https://example.com or any message...';
  static const String generateButton = 'Generate QR Code';

  // Action Buttons
  static const String saveButton = 'Save to Gallery';
  static const String shareButton = 'Share';
  static const String saving = 'Saving...';
  static const String sharing = 'Sharing...';

  // Success Feedback
  static const String saveSuccess =
      'QR code saved to your gallery successfully!';
  static const String shareSuccess = 'QR code prepared for sharing!';

  // Error Messages
  static const String emptyInputError =
      'Please enter text or a URL before generating.';
  static const String permissionDeniedError =
      'Storage permission is required to save the QR code.';
  static const String permissionPermanentlyDeniedError =
      'Storage permission was permanently denied. Please enable it in App Settings.';
  static const String captureFailedError =
      'Failed to render the QR code image. Please try again.';
  static const String saveFailedError = 'Failed to save the image to gallery.';
  static const String shareFailedError = 'Failed to share the QR code image.';
  static const String unexpectedError =
      'An unexpected error occurred. Please try again.';
}
