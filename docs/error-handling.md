# PulseFit Error Handling Guidelines

This document outlines the standard error handling patterns across the PulseFit application to ensure consistent, secure, and user-friendly error reporting.

---

## Core Exception Hierarchy

All feature exceptions in PulseFit extend the base `AppException` class located at `lib/core/error/app_exception.dart`:

```dart
abstract class AppException implements Exception {
  final String message;
  final String? details;

  const AppException(this.message, {this.details});
}
```

### Standard Exceptions

1. **`NetworkException`**: Connectivity or DNS failures.
2. **`AuthException`**: Session expiration or permission issues.
3. **`ValidationException`**: User input formatting errors.
4. **`AiAnalysisException`**: AI Vision API errors, including quota limits (`isQuotaError`), API key errors (`isApiKeyError`), and server errors (`isServerError`).
5. **`UnknownException`**: Fallback for unexpected failures.

---

## User Message Formatting with `ErrorPresenter`

Never pass raw `Exception` strings or `$e` directly into UI `Text` or `SnackBar` widgets. Always format errors using `ErrorPresenter.userMessage()` located at `lib/core/error/error_presenter.dart`:

```dart
try {
  await service.performOperation();
} catch (e) {
  debugPrint('Technical log: $e'); // Keep full log for developers
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ErrorPresenter.userMessage(e))),
    );
  }
}
```

---

## Guidelines for New Contributors

1. Extend `AppException` when defining domain-specific exceptions.
2. Ensure technical details (e.g. stack traces, raw HTTP payloads) are passed to `details` or `debugPrint`, **never** directly to `message`.
3. Use `ErrorPresenter.userMessage(e)` for all user-facing dialogs, snackbars, and error sheets.
