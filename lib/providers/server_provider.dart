import 'package:flutter/foundation.dart';
import '../models/server_model.dart';
import '../services/server_service.dart';

/// Provider for server list management
class ServerProvider extends ChangeNotifier {
  final _serverService = ServerService();

  List<ServerModel> _servers = [];
  ServerModel? _selectedServer;
  bool _isLoading = false;
  String _error = '';
  String _updatedAt = '';
  int _version = 1;
  Map<String, int> _pings = {}; // server id -> ping ms

  List<ServerModel> get servers => _servers;
  List<ServerModel> get freeServers =>
      _servers.where((s) => !s.isPremium).toList();
  List<ServerModel> get premiumServers =>
      _servers.where((s) => s.isPremium).toList();
  ServerModel? get selectedServer => _selectedServer;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get updatedAt => _updatedAt;
  int get version => _version;
  int? getPing(String serverId) => _pings[serverId];

  /// Fetch servers from backend
  Future<void> fetchServers() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _serverService.fetchServers();
      _servers = response.servers;
      _updatedAt = response.updatedAt;
      _version = response.version;
      // Auto-select first free server if none selected
      if (_selectedServer == null && _servers.isNotEmpty) {
        _selectedServer = freeServers.isNotEmpty ? freeServers.first : _servers.first;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Select a server
  void selectServer(ServerModel server) {
    _selectedServer = server;
    notifyListeners();
  }

  /// Check if a server is accessible for the user's tier
  bool canAccess(ServerModel server, bool isPremium) {
    if (server.isPremium) return isPremium;
    return true;
  }

  /// Set ping for a server
  void setPing(String serverId, int ping) {
    _pings[serverId] = ping;
    notifyListeners();
  }
}
