import 'package:equatable/equatable.dart';

/// Base class for all Matrix-related failures
abstract class MatrixFailure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const MatrixFailure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];
}

/// Network-related failures
class NetworkFailure extends MatrixFailure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authentication failures
class AuthenticationFailure extends MatrixFailure {
  const AuthenticationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authorization failures (insufficient permissions)
class AuthorizationFailure extends MatrixFailure {
  const AuthorizationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Server-side failures
class ServerFailure extends MatrixFailure {
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Client-side failures
class ClientFailure extends MatrixFailure {
  const ClientFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Room-related failures
class RoomFailure extends MatrixFailure {
  const RoomFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Message-related failures
class MessageFailure extends MatrixFailure {
  const MessageFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// File upload/download failures
class FileFailure extends MatrixFailure {
  const FileFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Encryption-related failures
class EncryptionFailure extends MatrixFailure {
  const EncryptionFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Sync-related failures
class SyncFailure extends MatrixFailure {
  const SyncFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Voice/Video call failures
class CallFailure extends MatrixFailure {
  const CallFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Database-related failures
class DatabaseFailure extends MatrixFailure {
  const DatabaseFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Unknown or unexpected failures
class UnknownFailure extends MatrixFailure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.details,
  });
}