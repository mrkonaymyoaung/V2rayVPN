import 'dart:async';
import 'package:flutter_v2ray/flutter_v2ray.dart';

/// Connection status enum
enum VpnStatus { disconnected, connecting, connected, disconnecting, error }

/// VPN connection state data
class VpnStatusData {
  final VpnStatus status;
  final String message;
  final String duration;
  final int uploadSpeed;
  final int downloadSpeed;
  final int upload;
  final int download;

  VpnStatusData({
    required this.status,
    this.message = '',
    this.duration = '00:00:00',
    this.uploadSpeed = 0,
    this.downloadSpeed = 0,
    this.upload = 0,
    this.download = 0,
  });
}

/// Service wrapping flutter_v2ray for VPN connection management
class VpnService {
  final _controller = StreamController<VpnStatusData>.broadcast();
  Stream<VpnStatusData> get statusStream => _controller.stream;

  FlutterV2ray? _v2ray;
  bool _initialized = false;

  VpnStatusData _current = VpnStatusData(status: VpnStatus.disconnected);
  VpnStatusData get current => _current;

  void _emit(VpnStatusData data) {
    _current = data;
    _controller.add(data);
  }

  /// Initialize the V2Ray engine (must be called before any VPN operations)
  Future<void> initialize() async {
    if (_initialized) return;
    _v2ray = FlutterV2ray(
      onStatusChanged: (status) {
        final state = status.state.toUpperCase();
        if (state == 'CONNECTED') {
          _emit(VpnStatusData(
            status: VpnStatus.connected,
            message: 'Connected',
            duration: status.duration,
            uploadSpeed: status.uploadSpeed,
            downloadSpeed: status.downloadSpeed,
            upload: status.upload,
            download: status.download,
          ));
        } else if (state == 'CONNECTING') {
          _emit(VpnStatusData(
            status: VpnStatus.connecting,
            message: 'Connecting...',
          ));
        } else if (state == 'DISCONNECTING') {
          _emit(VpnStatusData(
            status: VpnStatus.disconnecting,
            message: 'Disconnecting...',
          ));
        } else {
          _emit(VpnStatusData(
            status: VpnStatus.disconnected,
            message: 'Disconnected',
          ));
        }
      },
    );
    await _v2ray!.initializeV2Ray();
    _initialized = true;
  }

  /// Request VPN permission from the user
  Future<bool> requestPermission() async {
    if (!_initialized) await initialize();
    return await _v2ray!.requestPermission();
  }

  /// Get server delay (ping) for a V2Ray config
  Future<int> getServerDelay(String configJson) async {
    if (!_initialized) await initialize();
    try {
      return await _v2ray!.getServerDelay(config: configJson);
    } catch (e) {
      return -1;
    }
  }

  /// Connect to a VPN server using a V2Ray share link
  Future<void> connect(String link) async {
    if (!_initialized) await initialize();
    _emit(VpnStatusData(status: VpnStatus.connecting, message: 'Connecting...'));
    try {
      final parser = FlutterV2ray.parseFromURL(link);
      final hasPermission = await _v2ray!.requestPermission();
      if (!hasPermission) {
        _emit(VpnStatusData(
          status: VpnStatus.error,
          message: 'VPN permission denied',
        ));
        return;
      }
      _v2ray!.startV2Ray(
        remark: parser.remark,
        config: parser.getFullConfiguration(),
        blockedApps: null,
        bypassSubnets: ['0.0.0.0/0', '::/0'],
        proxyOnly: false,
      );
    } catch (e) {
      _emit(VpnStatusData(
        status: VpnStatus.error,
        message: 'Connection failed: $e',
      ));
    }
  }

  /// Disconnect from the VPN
  Future<void> disconnect() async {
    if (!_initialized) return;
    _emit(VpnStatusData(
      status: VpnStatus.disconnecting,
      message: 'Disconnecting...',
    ));
    try {
      _v2ray!.stopV2Ray();
    } catch (e) {
      _emit(VpnStatusData(
        status: VpnStatus.error,
        message: 'Disconnect failed: $e',
      ));
    }
  }

  void dispose() {
    _controller.close();
  }
}
