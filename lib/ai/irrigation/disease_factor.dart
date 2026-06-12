import 'irrigation_result.dart';

/// Handles disease-specific irrigation adjustments
///
/// Supported labels:
/// - Aphid
/// - Black Rust
/// - Blast
/// - Brown Rust
/// - Common Root Rot
/// - Fusarium Head Blight
/// - Healthy
/// - Leaf Blight
/// - Mildew
/// - Mite
/// - Septoria
/// - Smut
/// - Stem fly
/// - Tan spot
/// - Yellow Rust
class DiseaseFactorEngine {
  /// Get adjustment factor for specific disease
  ///
  /// Returns: DiseaseAdjustmentFactor with multiplicative factor
  static DiseaseAdjustmentFactor getAdjustmentFactor(
      String diseaseName) {
    final normalized = diseaseName.trim().toLowerCase();

    // =========================
    // RUST DISEASES
    // =========================
    if (normalized.contains('black rust') ||
        normalized.contains('brown rust') ||
        normalized.contains('yellow rust')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.90,
        rationale:
        'Rust diseases spread faster in humid conditions; slightly reduce irrigation to minimize leaf wetness.',
      );
    }

    // =========================
    // SEPTORIA
    // =========================
    if (normalized.contains('septoria')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.75,
        rationale:
        'Septoria thrives in wet conditions; significantly reduce irrigation to reduce disease pressure.',
      );
    }

    // =========================
    // MILDEW
    // =========================
    if (normalized.contains('mildew')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 1.0,
        rationale:
        'Mildew is less affected by irrigation amount; maintain normal watering with good airflow.',
      );
    }

    // =========================
    // TAN SPOT
    // =========================
    if (normalized.contains('tan spot')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.85,
        rationale:
        'Tan Spot spreads under prolonged moisture; moderate irrigation reduction recommended.',
      );
    }

    // =========================
    // BLAST
    // =========================
    if (normalized.contains('blast')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.80,
        rationale:
        'Blast disease develops rapidly in humid environments; reduce irrigation frequency.',
      );
    }

    // =========================
    // FUSARIUM HEAD BLIGHT
    // =========================
    if (normalized.contains('fusarium')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.80,
        rationale:
        'Fusarium Head Blight favors wet and humid conditions; reduce excess irrigation.',
      );
    }

    // =========================
    // LEAF BLIGHT
    // =========================
    if (normalized.contains('leaf blight')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.85,
        rationale:
        'Leaf Blight severity increases with leaf wetness; moderate irrigation reduction recommended.',
      );
    }

    // =========================
    // ROOT ROT
    // =========================
    if (normalized.contains('root rot')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.70,
        rationale:
        'Root Rot is strongly linked to overwatering and poor drainage; reduce irrigation significantly.',
      );
    }

    // =========================
    // SMUT
    // =========================
    if (normalized.contains('smut')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.95,
        rationale:
        'Smut diseases are weakly related to irrigation; slight reduction applied as precaution.',
      );
    }

    // =========================
    // APHID
    // =========================
    if (normalized.contains('aphid')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 1.05,
        rationale:
        'Aphid infestation may stress plants; maintain slightly higher hydration for recovery.',
      );
    }

    // =========================
    // MITE
    // =========================
    if (normalized.contains('mite')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 1.10,
        rationale:
        'Mites thrive in dry conditions; slightly increase irrigation and humidity near soil level.',
      );
    }

    // =========================
    // STEM FLY
    // =========================
    if (normalized.contains('stem fly')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 1.0,
        rationale:
        'Stem fly damage is not strongly affected by irrigation levels.',
      );
    }

    // =========================
    // HEALTHY
    // =========================
    if (normalized == 'healthy' ||
        normalized.contains('healthy')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 1.0,
        rationale:
        'Plant is healthy; standard irrigation practices apply.',
      );
    }

    // =========================
    // UNKNOWN DISEASE
    // =========================
    return DiseaseAdjustmentFactor(
      diseaseName: diseaseName,
      factor: 0.95,
      rationale:
      'Unknown condition detected; applying conservative irrigation adjustment.',
    );
  }

  /// Get disease-specific recommendations
  static List<String> getDiseaseSpecificRecommendations(
      String diseaseName) {
    final normalized = diseaseName.trim().toLowerCase();

    // Rust diseases
    if (normalized.contains('rust')) {
      return [
        'Avoid overhead irrigation',
        'Water early morning only',
        'Reduce leaf wetness duration',
        'Monitor disease spread weekly',
      ];
    }

    // Septoria
    if (normalized.contains('septoria')) {
      return [
        'Use drip irrigation only',
        'Improve field drainage',
        'Remove infected leaves',
        'Increase air circulation',
      ];
    }

    // Mildew
    if (normalized.contains('mildew')) {
      return [
        'Avoid excessive humidity',
        'Ensure good airflow',
        'Apply preventive fungicide',
        'Water at soil level only',
      ];
    }

    // Root Rot
    if (normalized.contains('root rot')) {
      return [
        'Reduce irrigation immediately',
        'Improve soil drainage',
        'Avoid waterlogging',
        'Inspect roots regularly',
      ];
    }

    // Blast
    if (normalized.contains('blast')) {
      return [
        'Avoid excess nitrogen fertilizer',
        'Reduce irrigation frequency',
        'Monitor humidity carefully',
        'Apply fungicide if needed',
      ];
    }

    // Aphid
    if (normalized.contains('aphid')) {
      return [
        'Inspect underside of leaves',
        'Use biological pest control',
        'Avoid plant stress',
        'Monitor infestation daily',
      ];
    }

    // Mite
    if (normalized.contains('mite')) {
      return [
        'Increase humidity slightly',
        'Inspect leaves for webbing',
        'Avoid drought stress',
        'Apply appropriate pesticide if necessary',
      ];
    }

    // Healthy
    if (normalized.contains('healthy')) {
      return [
        'Maintain regular irrigation schedule',
        'Monitor soil moisture regularly',
        'Apply preventive care practices',
        'Inspect crops weekly',
      ];
    }

    return [
      'Confirm diagnosis with agricultural expert',
      'Monitor crop condition closely',
      'Document disease progression',
      'Adjust irrigation conservatively',
    ];
  }

  /// Get optimal irrigation timing based on disease
  static String getOptimalIrrigationTiming(
      String diseaseName) {
    final normalized = diseaseName.trim().toLowerCase();

    // Moisture-sensitive diseases
    if (normalized.contains('rust') ||
        normalized.contains('septoria') ||
        normalized.contains('blast') ||
        normalized.contains('blight') ||
        normalized.contains('fusarium')) {
      return 'Early morning (5-7 AM) to allow rapid drying of foliage';
    }

    // Root diseases
    if (normalized.contains('root rot')) {
      return 'Morning only with controlled low-volume irrigation';
    }

    // Mites
    if (normalized.contains('mite')) {
      return 'Late evening with moderate soil moisture maintenance';
    }

    return 'Early morning or late evening with soil-level irrigation';
  }
}