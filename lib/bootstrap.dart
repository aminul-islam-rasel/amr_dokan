import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/storage/shared_prefs_service.dart';

Future<void> bootstrap() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Lock Orientation to Portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // System UI Overlay Style (Status bar)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();

    // Setup Flutter Error Handler
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint('Flutter Error: ${details.exceptionAsString()}');
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        debugPrint('Platform Async Error: $error\n$stack');
      }
      return true;
    };

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const AmarDokanApp(),
      ),
    );
  }, (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('Unhandled Zone Error: $error\n$stackTrace');
    }
  });
}
