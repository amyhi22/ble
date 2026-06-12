/// Represents weather data from external API or local sensor
class WeatherData {
  final double temperature; // Celsius
  final double humidity; // 0-100 percentage
  final double windSpeed; // km/h
  final DateTime timestamp;
  final String? location;
  

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.timestamp,
    this.location,
  });

  // For JSON serialization (if caching)
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['temperature'] as double,
      humidity: json['humidity'] as double,
      windSpeed: json['windSpeed'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'humidity': humidity,
    'windSpeed': windSpeed,
    'timestamp': timestamp.toIso8601String(),
    'location': location,
  };

  @override
  String toString() =>
      'WeatherData(temp: ${temperature.toStringAsFixed(1)}°C, humidity: ${humidity.toStringAsFixed(0)}%, wind: ${windSpeed.toStringAsFixed(1)}km/h)';
}

/// Raw prediction from TFLite irrigation model
class IrrigationModelPrediction {
  final double waterIntensity; // 0.0 - 1.0 (normalized)
  final List<double> rawOutput; // Raw model output for debugging
  final Duration inferenceTime;

  IrrigationModelPrediction({
    required this.waterIntensity,
    required this.rawOutput,
    required this.inferenceTime,
  });

  @override
  String toString() =>
      'IrrigationModelPrediction(intensity: ${waterIntensity.toStringAsFixed(3)}, inference: ${inferenceTime.inMilliseconds}ms)';
}

/// Disease-specific adjustment factor
class DiseaseAdjustmentFactor {
  final String diseaseName;
  final double factor; // 0.6 - 1.2 (multiplier)
  final String rationale; // Why this factor was applied

  DiseaseAdjustmentFactor({
    required this.diseaseName,
    required this.factor,
    required this.rationale,
  });

  @override
  String toString() => 'DiseaseAdjustmentFactor($diseaseName: ${factor.toStringAsFixed(2)}x - $rationale)';
}

/// Final irrigation recommendation with full context
class IrrigationRecommendation {
  final String diseaseName;
  final WeatherData weatherData;
  final IrrigationModelPrediction modelPrediction;
  final DiseaseAdjustmentFactor adjustmentFactor;

  // Final computed values
  final double finalWaterIntensity; // 0.0 - 1.0
  final String waterVolumeCategory; // "Low", "Moderate", "High", "Critical"
  final String irrigationFrequency; // "Every 2 days", "Daily", etc.
  final List<String> actionItems; // Specific instructions
  final String confidence; // Visual confidence indicator

  // Metadata
  final DateTime generatedAt;
  final Duration totalComputationTime;

  IrrigationRecommendation({
    required this.diseaseName,
    required this.weatherData,
    required this.modelPrediction,
    required this.adjustmentFactor,
    required this.finalWaterIntensity,
    required this.waterVolumeCategory,
    required this.irrigationFrequency,
    required this.actionItems,
    required this.confidence,
    required this.generatedAt,
    required this.totalComputationTime,
  });

  /// Get color based on water intensity (for UI rendering)
  String getIntensityColor() {
    if (finalWaterIntensity < 0.3) return '#4CAF50'; // Green - Low
    if (finalWaterIntensity < 0.6) return '#FFC107'; // Amber - Moderate
    if (finalWaterIntensity < 0.85) return '#FF9800'; // Orange - High
    return '#F44336'; // Red - Critical
  }

  /// Get water amount in liters (example for 1m² field)
  int getEstimatedWaterLiters({double fieldAreaM2 = 1.0}) {
    // Example: 0.5 intensity = 25L per m² per day
    return (finalWaterIntensity * 50 * fieldAreaM2).toInt();
  }

  @override
  String toString() =>
      'IrrigationRecommendation($diseaseName, intensity: ${finalWaterIntensity.toStringAsFixed(2)}, category: $waterVolumeCategory)';
}

/// Error handling for irrigation operations
class IrrigationException implements Exception {
  final String message;
  final String code;
  final StackTrace? stackTrace;

  IrrigationException({
    required this.message,
    required this.code,
    this.stackTrace,
  });

  @override
  String toString() => 'IrrigationException($code): $message';
}