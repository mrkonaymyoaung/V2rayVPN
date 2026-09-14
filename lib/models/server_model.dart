/// Server model representing a VPN server entry from servers.json
class ServerModel {
  final String id;
  final String name;
  final String country;
  final String protocol;
  final String tier; // "free" or "premium"
  final String uri;

  ServerModel({
    required this.id,
    required this.name,
    required this.country,
    required this.protocol,
    required this.tier,
    required this.uri,
  });

  bool get isPremium => tier.toLowerCase() == 'premium';

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      country: json['country'] as String? ?? '🌐',
      protocol: json['protocol'] as String? ?? 'vless',
      tier: json['tier'] as String? ?? 'free',
      uri: json['uri'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'protocol': protocol,
      'tier': tier,
      'uri': uri,
    };
  }
}

/// Container for the full servers.json response
class ServerListResponse {
  final int version;
  final String updatedAt;
  final List<ServerModel> servers;

  ServerListResponse({
    required this.version,
    required this.updatedAt,
    required this.servers,
  });

  factory ServerListResponse.fromJson(Map<String, dynamic> json) {
    return ServerListResponse(
      version: json['version'] as int? ?? 1,
      updatedAt: json['updatedAt'] as String? ?? '',
      servers: (json['servers'] as List<dynamic>?)
              ?.map((e) => ServerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
