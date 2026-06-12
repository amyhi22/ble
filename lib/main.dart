import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'ai/irrigation/irrigation_service.dart';

import 'models/disease_data.dart';
import 'models/user_model.dart';
import 'models/detection_history.dart';

import 'database/disease_database.dart';
import 'database/history_database.dart';

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // ─── Hive ────────────────────────────────────────────────
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(DiseaseDataAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DetectionHistoryAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserModelAdapter());

  await Hive.openBox<DiseaseData>('diseases');
  await Hive.openBox<DetectionHistory>('detection_history');
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<String>('session');

  // ✅ HistoryDatabase ne dépend pas de .tr() → OK ici
  try {
    await HistoryDatabase.init();
    debugPrint('✅ HistoryDatabase initialized');
  } catch (e) {
    debugPrint('❌ HistoryDatabase init failed: $e');
    rethrow;
  }

  // ✅ IrrigationService ne dépend pas de .tr() → OK ici
  try {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENWEATHER_API_KEY missing in .env file');
    }
    await IrrigationService().initialize(openWeatherMapApiKey: apiKey);
    debugPrint('✅ IrrigationService initialized');
  } catch (e) {
    debugPrint('❌ IrrigationService init failed: $e');
  }

  // ❌ DiseaseDatabase.init() retiré d'ici — il utilise .tr()
  //    et doit être appelé APRÈS que EasyLocalization soit monté
  //    dans le widget tree. Voir AgroScanApp._initDatabase() ci-dessous.

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const AgroScanApp(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AgroScanApp — StatefulWidget pour initialiser DiseaseDatabase
// après que EasyLocalization soit actif dans le widget tree
// ─────────────────────────────────────────────────────────────────────────────

class AgroScanApp extends StatefulWidget {
  const AgroScanApp({super.key});

  @override
  State<AgroScanApp> createState() => _AgroScanAppState();
}

class _AgroScanAppState extends State<AgroScanApp> {
  @override
  void initState() {
    super.initState();
    // ✅ Appelé après le premier build — EasyLocalization est monté,
    //    context.locale est actif, .tr() retourne la bonne langue.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDiseaseDatabase();
    });
  }

  Future<void> _initDiseaseDatabase() async {
    try {
      // ✅ Ici .tr() connaît la locale restaurée par EasyLocalization
      await DiseaseDatabase.init();
      debugPrint('✅ DiseaseDatabase initialized (locale: ${context.locale})');
    } catch (e) {
      debugPrint('⚠️ DiseaseDatabase warning: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroScan',
      debugShowCheckedModeBanner: false,

      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      theme: ThemeData(
        primaryColor: const Color(0xFF594020),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF594020),
          secondary: const Color(0xFF768E2E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),

      home: const SplashScreen(),
    );
  }
}