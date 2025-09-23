import 'package:flutter/material.dart';

/// Base exception class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const AppException(
    this.message, {
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'AppException: $message';
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(
    String message, {
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(
    String message, {
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );
}

/// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException(
    String message, {
    this.fieldErrors,
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );

  String? getFieldError(String field) {
    final errors = fieldErrors?[field];
    return errors?.isNotEmpty == true ? errors!.first : null;
  }

  List<String> getAllFieldErrors(String field) {
    return fieldErrors?[field] ?? [];
  }
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException(
    String message, {
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );
}

/// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException(
    String message, {
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException(
    String message, {
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );
}

/// File operation related exceptions
class FileException extends AppException {
  const FileException(
    String message, {
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );
}

/// Business logic related exceptions
class BusinessLogicException extends AppException {
  const BusinessLogicException(
    String message, {
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );
}

/// Timeout related exceptions
class TimeoutException extends AppException {
  const TimeoutException(
    String message, {
    String? code,
    dynamic originalException,
  }) : super(
          message,
          code: code,
          originalException: originalException,
        );
}