part of 'mescat_entities.dart';

/// Base class for all Matrix-related failures
abstract class MCFailure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const MCFailure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];
}

/// Network-related failures
class NetworkFailure extends MCFailure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authentication failures
class AuthenticationFailure extends MCFailure {
  const AuthenticationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authorization failures (insufficient permissions)
class AuthorizationFailure extends MCFailure {
  const AuthorizationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Server-side failures
class ServerFailure extends MCFailure {
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Client-side failures
class ClientFailure extends MCFailure {
  const ClientFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Room-related failures
class RoomFailure extends MCFailure {
  const RoomFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Message-related failures
class MessageFailure extends MCFailure {
  const MessageFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// File upload/download failures
class FileFailure extends MCFailure {
  const FileFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Encryption-related failures
class EncryptionFailure extends MCFailure {
  const EncryptionFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Sync-related failures
class SyncFailure extends MCFailure {
  const SyncFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Voice/Video call failures
class CallFailure extends MCFailure {
  const CallFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Database-related failures
class DatabaseFailure extends MCFailure {
  const DatabaseFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Unknown or unexpected failures
class UnknownFailure extends MCFailure {
  const UnknownFailure({
    required super.message,
    super.code,
    super.details,
  });
}