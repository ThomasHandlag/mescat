import 'package:equatable/equatable.dart';

class Server extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final String ownerId;
  final List<String> memberIds;
  final List<String> channelIds;
  final DateTime createdAt;

  const Server({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.ownerId,
    this.memberIds = const [],
    this.channelIds = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconUrl,
        ownerId,
        memberIds,
        channelIds,
        createdAt,
      ];

  Server copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? ownerId,
    List<String>? memberIds,
    List<String>? channelIds,
    DateTime? createdAt,
  }) {
    return Server(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      channelIds: channelIds ?? this.channelIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}