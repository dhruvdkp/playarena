import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamebooking/app.dart';
import 'package:gamebooking/core/theme/theme_controller.dart';
import 'package:gamebooking/firebase_options.dart';
import 'package:gamebooking/data/services/crashlytics_service.dart';
import 'package:gamebooking/data/services/firestore_service.dart';
import 'package:gamebooking/data/datasources/firestore_seed.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics error handlers
  await CrashlyticsService().init();

  // Load persisted theme mode so the first frame renders with the
  // user's saved preference (light / dark / system).
  await ThemeController.instance.init();

  // Seed Firestore with demo data in background (don't block app startup)
  final firestoreService = FirestoreService();
  FirestoreSeed(firestoreService).seedIfEmpty();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1E293B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const GameBookingApp());
}
