import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

// Global key so NotificationService can show banners from anywhere in the app
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// ─── App Entry Point ──────────────────────────────────────────────────────────
//
// This is the very first Dart code that runs when the app starts.
// It does three things:
//   1. Initializes Flutter (required before any async code)
//   2. Connects to Firebase (for push notifications)
//   3. Starts the app wrapped in ProviderScope (for Riverpod state management)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved server URL from SharedPreferences before any API call is made
  await AppConstants.init();

  // Connect to Firebase — push notifications won't work until flutterfire configure
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  runApp(const ProviderScope(child: GrazeTrackApp()));
}

class GrazeTrackApp extends StatelessWidget {
  const GrazeTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GrazeTrack',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,

      // Light theme — used when the phone is in normal (light) mode
      theme: AppTheme.lightTheme,

      // Dark theme — automatically used when the phone switches to dark mode
      darkTheme: AppTheme.darkTheme,

      // ThemeMode.system means: follow the phone's system setting automatically
      // Users can switch dark mode in their phone Settings → Display
      themeMode: ThemeMode.system,

      // GoRouter handles all navigation between screens
      routerConfig: appRouter,
    );
  }
}
