import 'package:flutter/foundation.dart';
import '../services/hwid_service.dart';

/// Provider for HWID authentication and premium status
class AuthProvider extends ChangeNotifier {
  final _hwidService = HwidService();

  String _hwid = '';
  bool _isPremium = false;
  bool _isLoading = true;
  String _error = '';

  String get hwid => _hwid;
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String get error => _error;

  /// Initialize: get HWID and check premium status
  Future<void> initialize() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _hwid = await _hwidService.getHwid();
      _isPremium = await _hwidService.checkPremiumStatus();
    } catch (e) {
      _error = e.toString();
      _isPremium = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Re-check premium status
  Future<void> refreshPremium() async {
    _isPremium = await _hwidService.checkPremiumStatus();
    notifyListeners();
  }
}
