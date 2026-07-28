import 'package:flutter/foundation.dart';
import 'failures.dart';

@immutable
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.error(Failure failure) = Error<T>;

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;

  T? get data => switch (this) {
        Success<T>(data: final d) => d,
        Error<T>() => null,
      };

  Failure? get failure => switch (this) {
        Success<T>() => null,
        Error<T>(failure: final f) => f,
      };

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success<T>(data: final d) => onSuccess(d),
      Error<T>(failure: final f) => onError(f),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
