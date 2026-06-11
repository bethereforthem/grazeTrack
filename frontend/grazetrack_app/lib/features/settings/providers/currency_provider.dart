import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

// ─── Supported currencies ─────────────────────────────────────────────
const Map<String, String> kCurrencySymbols = {
  'USD': '\$',
  'EUR': '€',
  'GBP': '£',
  'KES': 'KSh',
  'TZS': 'TSh',
  'UGX': 'USh',
  'NGN': '₦',
  'ZAR': 'R',
  'INR': '₹',
  'CNY': '¥',
  'AUD': 'A\$',
  'CAD': 'C\$',
  'BRL': 'R\$',
  'RWF': 'RF',
  'ETB': 'Br',
  'GHS': '₵',
};

// ─── State ─────────────────────────────────────────────────────────────
class CurrencyState {
  final String code;
  final String symbol;
  final double rate; // rate FROM USD TO this currency
  final bool isLoading;

  const CurrencyState({
    this.code = 'USD',
    this.symbol = '\$',
    this.rate = 1.0,
    this.isLoading = false,
  });

  CurrencyState copyWith({
    String? code,
    String? symbol,
    double? rate,
    bool? isLoading,
  }) =>
      CurrencyState(
        code: code ?? this.code,
        symbol: symbol ?? this.symbol,
        rate: rate ?? this.rate,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─── Notifier ──────────────────────────────────────────────────────────
class CurrencyNotifier extends StateNotifier<CurrencyState> {
  static const _prefKey = 'selected_currency';
  static const _ratesKey = 'exchange_rates_cache';
  static const _ratesTimeKey = 'exchange_rates_time';

  CurrencyNotifier() : super(const CurrencyState()) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey) ?? 'USD';
    await _applyCode(saved, prefs);
  }

  Future<void> selectCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
    await _applyCode(code, prefs);
  }

  Future<void> _applyCode(String code, SharedPreferences prefs) async {
    if (code == 'USD') {
      state = const CurrencyState(
          code: 'USD', symbol: '\$', rate: 1.0, isLoading: false);
      CurrencySettings.update('USD', '\$', 1.0);
      return;
    }

    // Try cached rates (valid for 1 hour)
    final cachedJson = prefs.getString(_ratesKey);
    final cachedTime = prefs.getInt(_ratesTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic>? rates;

    if (cachedJson != null && (now - cachedTime) < 3600000) {
      rates = jsonDecode(cachedJson) as Map<String, dynamic>;
    } else {
      rates = await _fetchRates(prefs);
    }

    final rate =
        rates != null ? (rates[code] as num?)?.toDouble() ?? 1.0 : 1.0;
    final symbol = kCurrencySymbols[code] ?? code;

    state =
        state.copyWith(code: code, symbol: symbol, rate: rate, isLoading: false);
    CurrencySettings.update(code, symbol, rate);
  }

  Future<Map<String, dynamic>?> _fetchRates(SharedPreferences prefs) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = Dio();
      final response = await dio
          .get('https://open.er-api.com/v6/latest/USD')
          .timeout(const Duration(seconds: 10));
      final rates = response.data['rates'] as Map<String, dynamic>;
      await prefs.setString(_ratesKey, jsonEncode(rates));
      await prefs.setInt(
          _ratesTimeKey, DateTime.now().millisecondsSinceEpoch);
      return rates;
    } catch (_) {
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// ─── Global currency settings (used by AppUtils.formatCurrency) ────────
class CurrencySettings {
  static String _symbol = '\$';
  static double _rate = 1.0;
  static String _code = 'USD';

  static void update(String code, String symbol, double rate) {
    _code = code;
    _symbol = symbol;
    _rate = rate;
  }

  static String get symbol => _symbol;
  static double get rate => _rate;
  static String get code => _code;
}

final currencyProvider =
    StateNotifierProvider<CurrencyNotifier, CurrencyState>(
  (ref) => CurrencyNotifier(),
);
