import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  // ─── Server URL Configuration ────────────────────────────────────────────
  //
  // Priority order (highest to lowest):
  //   1. URL saved by user in Settings → Server Address  (persists across restarts)
  //   2. --dart-define=API_URL=...                       (compile-time override)
  //   3. Hard-coded default below                        (fallback)
  //
  // To run with a specific IP:
  //   flutter run --dart-define=API_URL=http://192.168.31.239:5000/api/v1

  static const String _serverUrlPrefKey = 'server_url';

  static const String _compiledUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.31.239:5000/api/v1',
  );

  // Runtime URL — loaded from SharedPreferences at app startup
  static String _runtimeUrl = '';

  // Load saved server URL from SharedPreferences (call once in main())
  static Future<void> init() async {
    if (kIsWeb) {
      _runtimeUrl = 'http://localhost:5000/api/v1';
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    _runtimeUrl = prefs.getString(_serverUrlPrefKey) ?? _compiledUrl;
  }

  // Save a new server URL and apply it immediately (no restart needed)
  static Future<void> saveServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlPrefKey, url);
    _runtimeUrl = url;
  }

  // Clear saved URL and fall back to the compiled default
  static Future<void> resetServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_serverUrlPrefKey);
    _runtimeUrl = _compiledUrl;
  }

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api/v1';
    return _runtimeUrl.isNotEmpty ? _runtimeUrl : _compiledUrl;
  }

  // ─── Local Storage Keys ─────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // ─── Animal Types ────────────────────────────────────────────────
  static const List<String> animalTypes = [
    'Cow',
    'Goat',
    'Sheep',
    'Pig',
    'Chicken',
    'Horse',
    'Camel',
    'Other'
  ];

  // ─── Feed Types ──────────────────────────────────────────────────
  static const List<String> feedTypes = [
    'Hay',
    'Grain',
    'Silage',
    'Grass',
    'Pellets',
    'Supplement',
    'Other'
  ];

  // ─── Feed Units ──────────────────────────────────────────────────
  static const List<String> feedUnits = ['kg', 'liters', 'bales', 'bags'];

  // ─── Health Record Types ─────────────────────────────────────────
  static const List<String> healthTypes = [
    'Vaccination',
    'Treatment',
    'Checkup',
    'Deworming',
    'Surgery',
    'Other'
  ];

  // ─── Animal Health Statuses ──────────────────────────────────────
  static const List<String> healthStatuses = [
    'Healthy',
    'Sick',
    'Recovering',
    'Critical'
  ];

  // ─── Expense Categories ──────────────────────────────────────────
  static const List<String> expenseTypes = [
    'Feed',
    'Medicine',
    'Labor',
    'Equipment',
    'Transport',
    'Other'
  ];

  // ─── User Roles ──────────────────────────────────────────────────
  static const String roleAdmin = 'Admin';
  static const String roleFarmer = 'Farmer';
  static const String roleManager = 'Manager';
}
