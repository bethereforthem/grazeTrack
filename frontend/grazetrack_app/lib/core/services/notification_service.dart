import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../main.dart' show scaffoldMessengerKey;
import '../../core/theme/app_theme.dart';
import 'api_service.dart';

// NotificationService sets up Firebase push notifications.
// When the app starts, it requests permission and saves the FCM token
// to the backend so the server can send push notifications to this device.

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiService _api = ApiService();

  Future<void> initialize(String userId) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFcmToken(userId, token);
      }

      _messaging.onTokenRefresh.listen((newToken) {
        _saveFcmToken(userId, newToken);
      });

      // Show an in-app banner when a push arrives while the app is open
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showBanner(
          title: message.notification?.title ?? 'New Notification',
          body: message.notification?.body ?? '',
          type: message.data['type'] as String? ?? '',
        );
      });
    }
  }

  // Show a floating SnackBar banner from anywhere in the app
  static void showBanner({
    required String title,
    String body = '',
    String type = '',
  }) =>
      _showBanner(title: title, body: body, type: type);

  static void _showBanner({
    required String title,
    required String body,
    required String type,
  }) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryGreen,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withAlpha(40),
              child: Icon(_iconFor(type), color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  if (body.isNotEmpty)
                    Text(
                      body,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to notifications screen
            // The route is handled by the caller if needed
          },
        ),
      ),
    );
  }

  static IconData _iconFor(String type) {
    switch (type) {
      case 'chat_message':
        return Icons.chat_bubble_outline;
      case 'order_update':
        return Icons.receipt_long_outlined;
      case 'payment':
        return Icons.attach_money;
      default:
        return Icons.notifications_outlined;
    }
  }

  Future<void> _saveFcmToken(String userId, String token) async {
    try {
      await _api.put('/users/$userId', {'fcmToken': token});
    } catch (e) {
      if (kDebugMode) print('Failed to save FCM token: $e');
    }
  }
}
