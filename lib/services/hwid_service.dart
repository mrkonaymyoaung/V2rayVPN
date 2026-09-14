import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Service for HWID generation and premium status checking
class HwidService {
  static const _channel = MethodChannel('com.mrkonaymyoaung.v2ray_vpn/hwid');
  static const _premiumListUrl =
      'https://raw.githubusercontent.com/mrkonaymyoaung/backup/refs/heads/main/premium.txt';

  /// Gets the device HWID via platform channel (Android ID formatted as XXXX-XXXX-XXXX-XXXX)
  Future<String> getHwid() async {
    try {
      final hwid = await _channel.invokeMethod<String>('getHwid');
      return hwid ?? '0000-0000-0000-0000';
    } catch (e) {
      // Catch all exceptions including MissingPluginException
      // which does NOT extend PlatformException
      return '0000-0000-0000-0000';
    }
  }

  /// Fetches the premium HWID list and checks if this device is premium
  Future<bool> checkPremiumStatus() async {
    try {
      final hwid = await getHwid();
      final response = await http.get(Uri.parse(_premiumListUrl));
      if (response.statusCode != 200) return false;
      final lines = response.body
          .split('\n')
          .map((l) => l.trim().toUpperCase())
          .where((l) => l.isNotEmpty)
          .toList();
      return lines.contains(hwid.toUpperCase());
    } catch (e) {
      return false;
    }
  }

  /// Fetches the raw premium list (for debugging/display)
  Future<List<String>> fetchPremiumList() async {
    try {
      final response = await http.get(Uri.parse(_premiumListUrl));
      if (response.statusCode != 200) return [];
      return response.body
          .split('\n')
          .map((l) => l.trim().toUpperCase())
          .where((l) => l.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }
}
