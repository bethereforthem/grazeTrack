import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'features/settings/providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

// Global key so NotificationService can show banners from anywhere in the app
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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

class GrazeTrackApp extends ConsumerWidget {
  const GrazeTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'GrazeTrack',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,

      // ── Localization ──────────────────────────────────────────────
      locale: locale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // Fallback delegates provide English Material/Cupertino strings for
        // locales not covered by the Global delegates (e.g. Kinyarwanda).
        // They are checked only when the Global delegates return isSupported=false.
        _MaterialLocalizationsFallback(),
        _CupertinoLocalizationsFallback(),
      ],

      // Light theme — used when the phone is in normal (light) mode
      theme: AppTheme.lightTheme,

      // Dark theme — automatically used when the phone switches to dark mode
      darkTheme: AppTheme.darkTheme,

      // ThemeMode.system means: follow the phone's system setting automatically
      themeMode: ThemeMode.system,

      // GoRouter handles all navigation between screens
      routerConfig: appRouter,
    );
  }
}

/// Provides English [MaterialLocalizations] for any locale that
/// [GlobalMaterialLocalizations] does not support (e.g. Kinyarwanda).
class _MaterialLocalizationsFallback
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialLocalizationsFallback();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(
          const DefaultMaterialLocalizations());

  @override
  bool shouldReload(_MaterialLocalizationsFallback old) => false;
}

/// Provides English [CupertinoLocalizations] for any locale that
/// [GlobalCupertinoLocalizations] does not support (e.g. Kinyarwanda).
class _CupertinoLocalizationsFallback
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _CupertinoLocalizationsFallback();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
          const DefaultCupertinoLocalizations());

  @override
  bool shouldReload(_CupertinoLocalizationsFallback old) => false;
}
