import 'package:flutter/foundation.dart';

@immutable
abstract class AppException implements Exception {
  final String message;
  final String? details;

  const AppException(this.message, {this.details});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([
    String message = 'Network connection issue. Please check your internet connection.',
    String? details,
  ]) : super(message, details: details);
}

class AuthException extends AppException {
  const AuthException([
    String message = 'Authentication failed or session expired.',
    String? details,
  ]) : super(message, details: details);
}

class ValidationException extends AppException {
  const ValidationException(String message, [String? details])
      : super(message, details: details);
}

class UnknownException extends AppException {
  const UnknownException([
    String message = 'An unexpected error occurred. Please try again.',
    String? details,
  ]) : super(message, details: details);
}
