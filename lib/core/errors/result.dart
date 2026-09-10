import 'app_failure.dart';

/// The return type of every repository method.
///
/// Callers must handle both arms, which is what keeps exceptions from leaking
/// out of the data layer and into widgets.
sealed class Result<T> {
  const Result();

  /// Whether this result carries a value.
  bool get isSuccess => this is Success<T>;

  /// The value, or null when this is a [ResultFailure].
  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    ResultFailure<T>() => null,
  };

  /// The failure, or null when this is a [Success].
  AppFailure? get failureOrNull => switch (this) {
    Success<T>() => null,
    ResultFailure<T>(:final failure) => failure,
  };

  /// Collapses both arms into a single value.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) => switch (this) {
    Success<T>(:final value) => onSuccess(value),
    ResultFailure<T>(:final failure) => onFailure(failure),
  };
}

/// A completed operation and its value.
final class Success<T> extends Result<T> {
  const Success(this.value);

  /// The produced value.
  final T value;
}

/// A failed operation and the reason.
final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  /// Why the operation failed.
  final AppFailure failure;
}
