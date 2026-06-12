import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'irrigation_result.dart';
import 'disease_factor.dart';
import 'irrigation_model_service.dart';
import 'weather_service.dart';

/// Orchestrates the complete irrigation recommendation pipeline
class IrrigationEngine {
  final WeatherService weatherService;
  final IrrigationModelService modelService;

  IrrigationEngine({
    required this.weatherService,
    required this.modelService,
  });

  Future<IrrigationRecommendation> generateRecommendation({
    required String diseaseName,
    bool useCache = true,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final weather = await weatherService.getWeatherForCurrentLocation(
        forceRefresh: !useCache,
      );
      final prediction = await modelService.predictWaterIntensity(
        temperature: weather.temperature,
        humidity: weather.humidity,
        windSpeed: weather.windSpeed,
      );
      final adjustmentFactor =
          DiseaseFactorEngine.getAdjustmentFactor(diseaseName);
      final finalIntensity =
          prediction.waterIntensity * adjustmentFactor.factor;

      // ✅ Store RAW KEYS — UI (IrrigationCard) will translate them
      final categoryKey = _categoryKey(finalIntensity);
      final frequencyKey = _frequencyKey(finalIntensity, weather.humidity);

      // ✅ actionItems are translated here because they contain dynamic values
      final actionItems = _generateActionItems(
        diseaseName,
        finalIntensity,
        weather,
        adjustmentFactor,
      );
      final confidenceKey = _confidenceKey(weather);

      stopwatch.stop();

      return IrrigationRecommendation(
        diseaseName: diseaseName,
        weatherData: weather,
        modelPrediction: prediction,
        adjustmentFactor: adjustmentFactor,
        finalWaterIntensity: finalIntensity.clamp(0.0, 1.0),
        waterVolumeCategory: categoryKey,   // e.g. 'low', 'moderate', 'high', 'critical'
        irrigationFrequency: frequencyKey,  // e.g. 'every_3_4_days', 'daily_twice'
        actionItems: actionItems,
        confidence: confidenceKey,          // e.g. 'high', 'good', 'fair'
        generatedAt: DateTime.now(),
        totalComputationTime: stopwatch.elapsed,
      );
    } catch (e) {
      if (e is IrrigationException) rethrow;
      throw IrrigationException(
        message: 'Recommendation generation failed: $e',
        code: 'RECOMMENDATION_ERROR',
        stackTrace: StackTrace.current,
      );
    }
  }

  // ✅ Returns a SHORT KEY like 'low', 'moderate', 'high', 'critical'
  // IrrigationCard will do: 'irrigation_engine.categories.$key'.tr()
  String _categoryKey(double intensity) {
    if (intensity < 0.3) return 'low';
    if (intensity < 0.6) return 'moderate';
    if (intensity < 0.85) return 'high';
    return 'critical';
  }

  // ✅ Returns a SHORT KEY like 'every_3_4_days', 'daily_twice'
  // IrrigationCard will do: 'irrigation_engine.frequency.$key'.tr()
  String _frequencyKey(double intensity, double humidity) {
    final adjusted = intensity * (humidity > 75 ? 0.8 : 1.0);
    if (adjusted < 0.3) return 'every_3_4_days';
    if (adjusted < 0.6) return 'every_2_3_days';
    if (adjusted < 0.85) return 'every_1_2_days';
    return 'daily_twice';
  }

  // ✅ Returns a SHORT KEY like 'high', 'good', 'fair'
  // IrrigationCard will do: 'irrigation_engine.confidence.$key'.tr()
  String _confidenceKey(WeatherData weather) {
    final age = DateTime.now().difference(weather.timestamp).inMinutes;
    if (age > 60) return 'fair';
    if (age > 30) return 'good';
    return 'high';
  }

  // ✅ actionItems are translated here because they embed dynamic values
  List<String> _generateActionItems(
    String diseaseName,
    double finalIntensity,
    WeatherData weather,
    DiseaseAdjustmentFactor factor,
  ) {
    final items = <String>[];

    // Disease-specific recommendations (translated inside DiseaseFactorEngine)
    items.addAll(
        DiseaseFactorEngine.getDiseaseSpecificRecommendations(diseaseName));

    if (weather.temperature > 30) {
      items.add('irrigation_engine.messages.temp_high'.tr(
        namedArgs: {'value': weather.temperature.toStringAsFixed(1)},
      ));
    }
    if (weather.humidity > 85) {
      items.add('irrigation_engine.messages.high_humidity'.tr());
    }
    if (weather.humidity < 40) {
      items.add('irrigation_engine.messages.low_humidity'.tr());
    }
    if (weather.windSpeed > 15) {
      items.add('irrigation_engine.messages.high_wind'.tr());
    }

    items.insert(
      0,
      'irrigation_engine.messages.optimal_timing'.tr(namedArgs: {
        'value': DiseaseFactorEngine.getOptimalIrrigationTiming(diseaseName),
      }),
    );

    if (finalIntensity > 0.8) {
      items.add('irrigation_engine.messages.high_water_demand'.tr());
    }
    if (factor.factor < 0.85) {
      items.add('irrigation_engine.messages.disease_factor_applied'.tr(
        namedArgs: {'value': factor.rationale},
      ));
    }

    return items;
  }

  Map<String, dynamic> getDiagnostics({
    required IrrigationRecommendation recommendation,
  }) {
    return {
      'timestamp': recommendation.generatedAt.toIso8601String(),
      'computation_time_ms':
          recommendation.totalComputationTime.inMilliseconds,
      'weather': {
        'temperature': recommendation.weatherData.temperature,
        'humidity': recommendation.weatherData.humidity,
        'wind_speed': recommendation.weatherData.windSpeed,
        'location': recommendation.weatherData.location,
      },
      'model_output': {
        'raw_intensity': recommendation.modelPrediction.waterIntensity,
        'inference_time_ms':
            recommendation.modelPrediction.inferenceTime.inMilliseconds,
      },
      'disease_adjustment': {
        'disease': recommendation.adjustmentFactor.diseaseName,
        'factor': recommendation.adjustmentFactor.factor,
        'rationale': recommendation.adjustmentFactor.rationale,
      },
      'final_recommendation': {
        'water_intensity': recommendation.finalWaterIntensity,
        'category_key': recommendation.waterVolumeCategory,
        'frequency_key': recommendation.irrigationFrequency,
        'confidence_key': recommendation.confidence,
      },
    };
  }
}