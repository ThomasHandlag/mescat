import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isOnline;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        avatarUrl,
        createdAt,
        isOnline,
      ];

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isOnline,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}