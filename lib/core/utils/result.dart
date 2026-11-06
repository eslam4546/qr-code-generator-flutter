import '../errors/failures.dart';

/// Lightweight, functional result container for domain layer responses.
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = SuccessResult<T>;
  factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is SuccessResult<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get dataOrNull => switch (this) {
    SuccessResult<T>(data: final d) => d,
    FailureResult<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    SuccessResult<T>() => null,
    FailureResult<T>(failure: final f) => f,
  };

  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      SuccessResult<T>(data: final d) => onSuccess(d),
      FailureResult<T>(failure: final f) => onFailure(f),
    };
  }
}

final class SuccessResult<T> extends Result<T> {
  final T data;
  const SuccessResult(this.data);
}

final class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);
}
