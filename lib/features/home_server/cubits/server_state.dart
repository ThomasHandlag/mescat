part of 'server_cubit.dart';

abstract class ServerState extends Equatable {
  const ServerState();
}

final class ServerEmpty extends ServerState {
  const ServerEmpty();

  @override
  List<Object?> get props => [];
}

final class ServerListLoading extends ServerState {
  const ServerListLoading();

  @override
  List<Object?> get props => [];
}

final class ServerListLoaded extends ServerState {
  final List<ServerInfo> servers;
  final ServerInfo? selectedServer;

  const ServerListLoaded(this.servers, {this.selectedServer});

  @override
  List<Object?> get props => [servers, selectedServer];

  ServerListLoaded copyWith({
    List<ServerInfo>? servers,
    ServerInfo? selectedServer,
  }) {
    return ServerListLoaded(
      servers ?? this.servers,
      selectedServer: selectedServer ?? this.selectedServer,
    );
  }
}

final class ServerInfo extends Equatable {
  final String domain;
  final int online;
  final String? rulesUrl;
  final String? privacyUrl;
  final String? location;
  final bool slidingSync;
  final bool email;
  final bool captcha;

  const ServerInfo({
    required this.domain,
    required this.online,
    required this.rulesUrl,
    required this.privacyUrl,
    required this.location,
    required this.slidingSync,
    required this.email,
    required this.captcha,
  });

  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    final isp = json['isp'] as String?;
    
    return ServerInfo(
      domain: json['client_domain'] as String,
      online: json['online_status'] as int,
      rulesUrl: json['rules'] as String?,
      privacyUrl: json['privacy'] as String?,
      location: isp != null ? _getLocation(isp) : null,
      slidingSync: json['sliding_sync'] as bool? ?? false,
      email: json['email'] as bool,
      captcha: json['captcha'] as bool,
    );
  }

  static String _getLocation(String isp) {
    final match = RegExp(r'\((.*?)\)').firstMatch(isp);
    return match?.group(1) ?? '';
  }

  @override
  List<Object?> get props => [
    domain,
    online,
    rulesUrl,
    privacyUrl,
    location,
    slidingSync,
    email,
    captcha,
  ];

  String toJson() {
    return '''
    {
      "client_domain": "$domain",
      "online_status": $online,
      "rules": "$rulesUrl",
      "privacy": "$privacyUrl",
      "isp": "$location",
      "sliding_sync": $slidingSync,
      "email": $email,
      "captcha": $captcha
    }
    ''';
  }
}
