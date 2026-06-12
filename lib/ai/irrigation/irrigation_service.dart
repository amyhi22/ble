import 'package:flutter/foundation.dart';
import 'irrigation_engine.dart';
import 'irrigation_model_service.dart';
import 'weather_service.dart';
import 'irrigation_result.dart';

/// Singleton service for irrigation recommendations
///
/// Lazy-initializes all dependencies and provides a clean API for widgets
class IrrigationService {
  static final IrrigationService _instance = IrrigationService._internal();

  late IrrigationModelService _modelService;
  late WeatherService _weatherService;
  late IrrigationEngine _engine;

  bool _isInitialized = false;
  final List<String> _initErrors = [];

  IrrigationService._internal();

  factory IrrigationService() {
    return _instance;
  }

  /// Initialize all dependencies
  ///
  /// Must be called once at app startup (e.g., in main())
  /// Safe to call multiple times (idempotent)
  Future<void> initialize({
    required String openWeatherMapApiKey,
  }) async {
    if (_isInitialized) {
      print('ℹ️ IrrigationService already initialized');
      return;
    }

    try {
      // Initialize weather service
      _weatherService = WeatherService(apiKey: openWeatherMapApiKey);
      print('✅ WeatherService initialized');

      // Initialize model service
      _modelService = IrrigationModelService();
      await _modelService.initialize();
      print('✅ IrrigationModelService initialized');

      // Initialize engine
      _engine = IrrigationEngine(
        weatherService: _weatherService,
        modelService: _modelService,
      );
      print('✅ IrrigationEngine initialized');

      _isInitialized = true;
      print('✅ IrrigationService fully initialized');
    } catch (e) {
      final error = 'IrrigationService initialization failed: $e';
      _initErrors.add(error);
      print('❌ $error');
      rethrow;
    }
  }

  /// Check if service is ready
  bool get isInitialized => _isInitialized;

  /// Get initialization errors
  List<String> get initErrors => _initErrors;

  /// Generate irrigation recommendation
  ///
  /// This is the main public API
  Future<IrrigationRecommendation> getRecommendation({
    required String diseaseName,
    bool useCache = true,
  }) async {
    if (!_isInitialized) {
      throw IrrigationException(
        message: 'IrrigationService not initialized. Call initialize() first.',
        code: 'SERVICE_NOT_INIT',
      );
    }

    return _engine.generateRecommendation(
      diseaseName: diseaseName,
      useCache: useCache,
    );
  }

  /// Get service diagnostics
  Map<String, dynamic> getDiagnostics({
    required IrrigationRecommendation? recommendation,
  }) {
    return {
      'initialized': _isInitialized,
      'init_errors': _initErrors,
      'model_specs': _modelService.getModelSpecs(),
      'weather_cache_fresh': _weatherService.isCacheFresh(),
      'recommendation_diagnostics':
      recommendation != null ? _engine.getDiagnostics(recommendation: recommendation) : null,
    };
  }

  /// Cleanup resources
  void dispose() {
    _modelService.dispose();
    _weatherService.clearCache();
    _isInitialized = false;
    print('🧹 IrrigationService disposed');
  }
}