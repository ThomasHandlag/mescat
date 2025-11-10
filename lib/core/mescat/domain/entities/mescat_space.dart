part of 'mescat_entities.dart';

class MatrixSpace extends Equatable {
  final String spaceId;
  final String name;
  final String? description;
  final String? avatarUrl;
  final bool isPublic;
  final List<String> childRoomIds;
  final List<String> adminIds;
  final List<String> moderatorIds;
  final Map<String, dynamic> permissions;
  final DateTime createdAt;
  final int memberCount;
  final Room mRoom;

  const MatrixSpace({
    required this.spaceId,
    required this.name,
    this.description,
    this.avatarUrl,
    this.isPublic = false,
    this.childRoomIds = const [],
    this.adminIds = const [],
    this.moderatorIds = const [],
    this.permissions = const {},
    required this.createdAt,
    this.memberCount = 0,
    required this.mRoom,
  });

  @override
  List<Object?> get props => [
    spaceId,
    name,
    description,
    avatarUrl,
    isPublic,
    childRoomIds,
    adminIds,
    moderatorIds,
    permissions,
    createdAt,
    memberCount,
    mRoom,
  ];

  MatrixSpace copyWith({
    String? spaceId,
    String? name,
    String? description,
    String? avatarUrl,
    bool? isPublic,
    List<String>? childRoomIds,
    List<String>? adminIds,
    List<String>? moderatorIds,
    Map<String, dynamic>? permissions,
    DateTime? createdAt,
    int? memberCount,
  Room? mRoom,
  }) {
    return MatrixSpace(
      spaceId: spaceId ?? this.spaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPublic: isPublic ?? this.isPublic,
      childRoomIds: childRoomIds ?? this.childRoomIds,
      adminIds: adminIds ?? this.adminIds,
      moderatorIds: moderatorIds ?? this.moderatorIds,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
      mRoom: mRoom ?? this.mRoom,
    );
  }
}