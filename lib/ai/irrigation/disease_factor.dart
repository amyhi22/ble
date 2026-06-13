import 'irrigation_result.dart';

/// يتعامل مع تعديلات الري الخاصة بالأمراض
///
/// التصنيفات المدعومة:
/// - حشرة المن (Aphid)
/// - الصدأ الأسود (Black Rust)
/// - اللفحة (Blast)
/// - الصدأ البني (Brown Rust)
/// - تعفن الجذور الشائع (Common Root Rot)
/// - لفحة رأس السنبلة الفيوزارية (Fusarium Head Blight)
/// - سليم (Healthy)
/// - لفحة الأوراق (Leaf Blight)
/// - البياض الدقيقي (Mildew)
/// - العث (Mite)
/// - السبتوريا (Septoria)
/// - التفحم (Smut)
/// - ذبابة الساق (Stem fly)
/// - تان سبوت (Tan spot)
/// - الصدأ الأصفر (Yellow Rust)
class DiseaseFactorEngine {
  /// الحصول على عامل التعديل لمرض معين
  ///
  /// النتيجة: DiseaseAdjustmentFactor مع عامل ضربي
  static DiseaseAdjustmentFactor getAdjustmentFactor(
      String diseaseName) {
    final normalized = diseaseName.trim().toLowerCase();

    // =========================
    // أمراض الصدأ
    // =========================
    if (normalized.contains('black rust') ||
        normalized.contains('brown rust') ||
        normalized.contains('yellow rust')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.90,
        rationale:
        'أمراض الصدأ تنتشر بشكل أسرع في الظروف الرطبة؛ قلل الري قليلاً لتقليل رطوبة الأوراق.',
      );
    }

    // =========================
    // السبتوريا
    // =========================
    if (normalized.contains('septoria')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.75,
        rationale:
        'السبتوريا تزدهر في الظروف الرطبة؛ قلل الري بشكل كبير لتقليل ضغط المرض.',
      );
    }

    // =========================
    // البياض الدقيقي
    // =========================
    if (normalized.contains('mildew')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 1.0,
        rationale:
        'البياض الدقيقي لا يتأثر كثيراً بكمية الري؛ حافظ على الري المعتاد مع تهوية جيدة.',
      );
    }

    // =========================
    // تان سبوت
    // =========================
    if (normalized.contains('tan spot')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.85,
        rationale:
        'تان سبوت ينتشر في ظروف الرطوبة المطولة؛ يُنصح بتخفيض معتدل للري.',
      );
    }

    // =========================
    // اللفحة (Blast)
    // =========================
    if (normalized.contains('blast')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.80,
        rationale:
        'مرض اللفحة يتطور بسرعة في البيئات الرطبة؛ قلل تكرار الري.',
      );
    }

    // =========================
    // لفحة رأس السنبلة الفيوزارية
    // =========================
    if (normalized.contains('fusarium')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.80,
        rationale:
        'لفحة رأس السنبلة الفيوزارية تفضل الظروف الرطبة؛ قلل الري الزائد.',
      );
    }

    // =========================
    // لفحة الأوراق
    // =========================
    if (normalized.contains('leaf blight')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.85,
        rationale:
        'تزداد شدة لفحة الأوراق مع رطوبة الأوراق؛ يُنصح بتخفيض معتدل للري.',
      );
    }

    // =========================
    // تعفن الجذور
    // =========================
    if (normalized.contains('root rot')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.70,
        rationale:
        'تعفن الجذور مرتبط بشكل كبير بالإفراط في الري وضعف الصرف؛ قلل الري بشكل كبير.',
      );
    }

    // =========================
    // التفحم
    // =========================
    if (normalized.contains('smut')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 0.95,
        rationale:
        'أمراض التفحم مرتبطة بشكل ضعيف بالري؛ يتم تطبيق تخفيض طفيف كإجراء احترازي.',
      );
    }

    // =========================
    // حشرة المن
    // =========================
    if (normalized.contains('aphid')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 1.05,
        rationale:
        'الإصابة بحشرة المن قد تُضعف النبات؛ حافظ على رطوبة أعلى قليلاً للمساعدة في التعافي.',
      );
    }

    // =========================
    // العث
    // =========================
    if (normalized.contains('mite')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 1.10,
        rationale:
        'العث يزدهر في الظروف الجافة؛ زد الري والرطوبة قليلاً عند مستوى التربة.',
      );
    }

    // =========================
    // ذبابة الساق
    // =========================
    if (normalized.contains('stem fly')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 1.0,
        rationale:
        'أضرار ذبابة الساق لا تتأثر بشكل كبير بمستويات الري.',
      );
    }

    // =========================
    // سليم
    // =========================
    if (normalized == 'healthy' ||
        normalized.contains('healthy')) {
      return DiseaseAdjustmentFactor(
        diseaseName: diseaseName,
        factor: 1.0,
        rationale:
        'النبات سليم؛ تُطبق ممارسات الري المعتادة.',
      );
    }

    // =========================
    // مرض غير معروف
    // =========================
    return DiseaseAdjustmentFactor(
      diseaseName: diseaseName,
      factor: 0.95,
      rationale:
      'تم اكتشاف حالة غير معروفة؛ يتم تطبيق تعديل ري متحفظ.',
    );
  }

  /// الحصول على التوصيات الخاصة بالمرض
  static List<String> getDiseaseSpecificRecommendations(
      String diseaseName) {
    final normalized = diseaseName.trim().toLowerCase();

    // أمراض الصدأ
    if (normalized.contains('rust')) {
      return [
        'تجنب الري العلوي',
        'الري في الصباح الباكر فقط',
        'تقليل مدة رطوبة الأوراق',
        'مراقبة انتشار المرض أسبوعياً',
      ];
    }

    // السبتوريا
    if (normalized.contains('septoria')) {
      return [
        'استخدم الري بالتنقيط فقط',
        'تحسين تصريف الحقل',
        'إزالة الأوراق المصابة',
        'زيادة التهوية',
      ];
    }

    // البياض الدقيقي
    if (normalized.contains('mildew')) {
      return [
        'تجنب الرطوبة الزائدة',
        'تأكد من وجود تهوية جيدة',
        'استخدم مبيد فطري وقائي',
        'الري عند مستوى التربة فقط',
      ];
    }

    // تعفن الجذور
    if (normalized.contains('root rot')) {
      return [
        'قلل الري على الفور',
        'حسّن تصريف التربة',
        'تجنب تشبع التربة بالماء',
        'افحص الجذور بشكل منتظم',
      ];
    }

    // اللفحة
    if (normalized.contains('blast')) {
      return [
        'تجنب الإفراط في استخدام الأسمدة النيتروجينية',
        'قلل تكرار الري',
        'راقب الرطوبة بعناية',
        'استخدم مبيد فطري عند الحاجة',
      ];
    }

    // حشرة المن
    if (normalized.contains('aphid')) {
      return [
        'افحص الجانب السفلي للأوراق',
        'استخدم المكافحة البيولوجية للآفات',
        'تجنب إجهاد النبات',
        'راقب الإصابة يومياً',
      ];
    }

    // العث
    if (normalized.contains('mite')) {
      return [
        'زد الرطوبة قليلاً',
        'افحص الأوراق بحثاً عن الشبكات',
        'تجنب الإجهاد الناتج عن الجفاف',
        'استخدم المبيد المناسب إذا لزم الأمر',
      ];
    }

    // سليم
    if (normalized.contains('healthy')) {
      return [
        'حافظ على جدول الري المعتاد',
        'راقب رطوبة التربة بانتظام',
        'طبّق ممارسات الرعاية الوقائية',
        'افحص المحاصيل أسبوعياً',
      ];
    }

    return [
      'تأكيد التشخيص مع خبير زراعي',
      'مراقبة حالة المحصول بشكل دقيق',
      'توثيق تطور المرض',
      'تعديل الري بشكل متحفظ',
    ];
  }

  /// الحصول على التوقيت الأمثل للري بناءً على المرض
  static String getOptimalIrrigationTiming(
      String diseaseName) {
    final normalized = diseaseName.trim().toLowerCase();

    // الأمراض الحساسة للرطوبة
    if (normalized.contains('rust') ||
        normalized.contains('septoria') ||
        normalized.contains('blast') ||
        normalized.contains('blight') ||
        normalized.contains('fusarium')) {
      return 'الصباح الباكر (5-7 صباحاً) للسماح بتجفيف الأوراق بسرعة';
    }

    // أمراض الجذور
    if (normalized.contains('root rot')) {
      return 'الصباح فقط مع ري منخفض الحجم ومتحكم به';
    }

    // العث
    if (normalized.contains('mite')) {
      return 'المساء المتأخر مع الحفاظ على رطوبة تربة معتدلة';
    }

    return 'الصباح الباكر أو المساء المتأخر مع الري عند مستوى التربة';
  }
}