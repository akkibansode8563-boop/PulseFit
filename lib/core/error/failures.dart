import 'package:flutter/foundation.dart';

@immutable
abstract class Failure {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection', super.code]);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred', super.code]);
}
