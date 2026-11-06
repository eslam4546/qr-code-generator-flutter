import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted when input validation fails (e.g. empty input).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Emitted when OS storage or photo library permissions are denied.
class PermissionFailure extends Failure {
  final bool isPermanentlyDenied;

  const PermissionFailure(super.message, {this.isPermanentlyDenied = false});

  @override
  List<Object?> get props => [message, isPermanentlyDenied];
}

/// Emitted when saving the QR code image to the device gallery fails.
class SaveFailure extends Failure {
  const SaveFailure(super.message);
}

/// Emitted when sharing the QR code image fails.
class ShareFailure extends Failure {
  const ShareFailure(super.message);
}

/// Emitted when RepaintBoundary bitmap capture fails.
class CaptureFailure extends Failure {
  const CaptureFailure(super.message);
}
