import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

/// Connection status enum
enum VpnStatus { disconnected, connecting, connected, disconnecting, error }

/// VPN connection state data
class VpnStatusData {
  final VpnStatus status;
  final String message;
  final int? delay;
  final int? uploadSpeed;
  final int? downloadSpeed;

  VpnStatusData({
    required this.status,
    this.message = '',
    this.delay,
    this.uploadSpeed,
    this.downloadSpeed,
  });
}

/// Service wrapping flutter_v2ray for VPN connection management
class VpnService {
  final _controller = StreamController<VpnStatusData>.broadcast();
  Stream<VpnStatusData> get statusStream => _controller.stream;

  FlutterV2ray? _v2ray;
  bool _initialized = false;
  Timer? _statsTimer;

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
        final state = status.state;
        if (state == 'Connected' || state == 'connected') {
          _emit(VpnStatusData(
            status: VpnStatus.connected,
            message: 'Connected',
            delay: status.delay,
            uploadSpeed: status.uploadSpeed,
            downloadSpeed: status.downloadSpeed,
          ));
        } else if (state == 'Connecting' || state == 'connecting') {
          _emit(VpnStatusData(
            status: VpnStatus.connecting,
            message: 'Connecting...',
          ));
        } else if (state == 'Disconnecting' || state == 'disconnecting') {
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
        bypassSubnets: null,
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

  /// Toggle VPN connection
  Future<void> toggle(String? currentLink) async {
    if (_current.status == VpnStatus.connected ||
        _current.status == VpnStatus.connecting) {
      await disconnect();
    } else if (currentLink != null) {
      await connect(currentLink);
    }
  }

  void dispose() {
    _statsTimer?.cancel();
    _controller.close();
  }
}
