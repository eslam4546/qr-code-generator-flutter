import 'package:equatable/equatable.dart';

/// Base class for all states emitted by [QrCubit].
sealed class QrState extends Equatable {
  const QrState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the application launches and no QR code has been generated.
class QrInitial extends QrState {
  const QrInitial();
}

/// State emitted upon successful QR code generation, keeping track of active operations.
class QrGeneratedSuccess extends QrState {
  final String qrData;
  final bool isSaving;
  final bool isSharing;

  const QrGeneratedSuccess({
    required this.qrData,
    this.isSaving = false,
    this.isSharing = false,
  });

  QrGeneratedSuccess copyWith({
    String? qrData,
    bool? isSaving,
    bool? isSharing,
  }) {
    return QrGeneratedSuccess(
      qrData: qrData ?? this.qrData,
      isSaving: isSaving ?? this.isSaving,
      isSharing: isSharing ?? this.isSharing,
    );
  }

  @override
  List<Object?> get props => [qrData, isSaving, isSharing];
}

/// Transient state emitted when an operation fails (e.g. empty input, permission denied).
class QrError extends QrState {
  final String message;
  final String? qrData;

  const QrError({required this.message, this.qrData});

  @override
  List<Object?> get props => [message, qrData];
}

/// Transient state emitted when an action completes successfully (e.g. saved to gallery).
class QrFeedbackSuccess extends QrState {
  final String message;
  final String qrData;

  const QrFeedbackSuccess({required this.message, required this.qrData});

  @override
  List<Object?> get props => [message, qrData];
}
