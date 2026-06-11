import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../features/settings/providers/currency_provider.dart';

// Utility functions used across the app

class AppUtils {
  // Format a number as currency using the currently selected currency.
  // Amounts are stored in USD; this converts to the selected currency.
  static String formatCurrency(double amount) {
    final converted = amount * CurrencySettings.rate;
    return NumberFormat.currency(
      symbol: CurrencySettings.symbol,
      decimalDigits: 2,
    ).format(converted);
  }

  // Format a date string: "2024-01-15T..." → "Jan 15, 2024"
  static String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  // Format date to show time too: "Jan 15, 2024 · 10:30 AM"
  static String formatDateTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy · hh:mm a').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  // Show a snackbar message (green = success, red = error)
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show a confirmation dialog before a destructive action (e.g., delete)
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Delete',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Get a color based on profit/loss
  static Color profitColor(double profit) {
    return profit >= 0 ? Colors.green[700]! : Colors.red[700]!;
  }

  // Get profit/loss label
  static String profitLabel(double profit) {
    return profit >= 0
        ? 'Profit: ${formatCurrency(profit)}'
        : 'Loss: ${formatCurrency(profit.abs())}';
  }
}
