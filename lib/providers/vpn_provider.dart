import 'package:flutter/foundation.dart';
import '../services/vpn_service.dart';

/// Provider for VPN connection state management
class VpnProvider extends ChangeNotifier {
  final _vpnService = VpnService();
  late Stream _statusStream;
  late void Function() _listener;

  VpnStatusData _status = VpnStatusData(status: VpnStatus.disconnected);
  VpnStatusData get status => _status;
  VpnStatus get connectionStatus => _status.status;
  bool get isConnected => _status.status == VpnStatus.connected;
  bool get isConnecting => _status.status == VpnStatus.connecting;
  String get statusMessage => _status.message;
  int? get uploadSpeed => _status.uploadSpeed;
  int? get downloadSpeed => _status.downloadSpeed;
  int? get delay => _status.delay;

  String? _currentLink;
  String? get currentLink => _currentLink;

  /// Initialize the VPN service and start listening to status
  Future<void> initialize() async {
    await _vpnService.initialize();
    _statusStream = _vpnService.statusStream;
    _listener = () {
      _status = _vpnService.current;
      notifyListeners();
    };
    _statusStream.listen((data) {
      _status = data;
      notifyListeners();
    });
  }

  /// Connect to a server using its V2Ray link
  Future<void> connect(String link) async {
    _currentLink = link;
    await _vpnService.connect(link);
    notifyListeners();
  }

  /// Disconnect from VPN
  Future<void> disconnect() async {
    await _vpnService.disconnect();
    _currentLink = null;
    notifyListeners();
  }

  /// Toggle VPN connection
  Future<void> toggle() async {
    if (isConnected || isConnecting) {
      await disconnect();
    } else if (_currentLink != null) {
      await connect(_currentLink!);
    }
  }

  /// Get server delay for a config
  Future<int> getServerDelay(String configJson) async {
    return await _vpnService.getServerDelay(configJson);
  }

  void dispose() {
    _vpnService.dispose();
    super.dispose();
  }
}
