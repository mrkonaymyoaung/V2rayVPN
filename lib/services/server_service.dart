import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/server_model.dart';

/// Service for fetching and managing VPN server configurations
class ServerService {
  static const _serversUrl =
      'https://raw.githubusercontent.com/mrkonaymyoaung/backup/refs/heads/main/servers.json';

  /// Fetches the full server list from the backend
  Future<ServerListResponse> fetchServers() async {
    try {
      final response = await http.get(Uri.parse(_serversUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch servers: ${response.statusCode}');
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ServerListResponse.fromJson(json);
    } catch (e) {
      throw Exception('Error fetching servers: $e');
    }
  }
}
