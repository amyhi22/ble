// ═══════════════════════════════════════════════════════════════
//  DiseaseRiskEngine — Evidence-based wheat disease risk calculator
//  INTERNATIONALISED VERSION
//
//  All user-facing strings (disease names, risk levels, triggers,
//  prevention advice) are now resolved through a Locale parameter
//  so they appear in Arabic, French, or English automatically.
//
//  Usage:
//    final locale = context.locale;  // from easy_localization
//    final risks  = DiseaseRiskEngine.calculateRisks(forecast, locale);
//    final alerts = DiseaseRiskEngine.getAlerts(forecast, locale);
// ═══════════════════════════════════════════════════════════════

import 'dart:ui' show Locale;
import '../models/daily_weather.dart';

class DiseaseRisk {
  final String diseaseName;
  final double riskPercent;
  final String riskLevel;
  final String riskLevelKey;
  final String riskColor;
  final List<String> triggers;
  final List<String> prevention;

  const DiseaseRisk({
    required this.diseaseName,
    required this.riskPercent,
    required this.riskLevel,
    required this.riskLevelKey,
    required this.riskColor,
    required this.triggers,
    required this.prevention,
  });
}

// ─── Localised string tables ────────────────────────────────────
class _L {
  final Locale locale;
  _L(this.locale);

  bool get _ar => locale.languageCode == 'ar';
  bool get _fr => locale.languageCode == 'fr';

  // ── Risk levels ──
  String get low      => _ar ? 'منخفض'  : _fr ? 'Faible'   : 'Low';
  String get moderate => _ar ? 'متوسط'  : _fr ? 'Modéré'   : 'Moderate';
  String get high     => _ar ? 'مرتفع'  : _fr ? 'Élevé'    : 'High';
  String get critical => _ar ? 'حرج'    : _fr ? 'Critique'  : 'Critical';

  String level(double p) {
    if (p < 40) return low;
    if (p < 60) return moderate;
    if (p < 75) return high;
    return critical;
  }

  // ── Disease names ──
  String get yellowRust => _ar ? 'الصدأ الأصفر'      : _fr ? 'Rouille jaune'           : 'Yellow Rust';
  String get brownRust  => _ar ? 'الصدأ البني'        : _fr ? 'Rouille brune'            : 'Brown Rust';
  String get stemRust   => _ar ? 'صدأ الساق'          : _fr ? 'Rouille des tiges'        : 'Stem Rust';
  String get septoria   => _ar ? 'سبتوريا القمح'      : _fr ? 'Septoriose du blé'        : 'Wheat Septoria';
  String get fusarium   => _ar ? 'فوزاريوم السنبلة'   : _fr ? 'Fusariose de l\'épi'      : 'Fusarium Head Blight';
  String get mildew     => _ar ? 'البياض الدقيقي'     : _fr ? 'Oïdium'                   : 'Powdery Mildew';
  String get tanSpot    => _ar ? 'البقعة الصفراء'     : _fr ? 'Tache bronzée'            : 'Tan Spot';
  String get rootRot    => _ar ? 'تعفن الجذور'        : _fr ? 'Pourriture racinaire'     : 'Root Rot';

  // ── Shared trigger fragments ──
  String days(int n) => _ar ? '$n أيام' : _fr ? '$n jours' : '$n days';
  String day(int n)  => _ar ? '$n يوم'  : _fr ? '$n jour'  : '$n day';
  String avgTemp(double v) => _ar
      ? 'متوسط الحرارة ${v.toStringAsFixed(1)}°C'
      : _fr ? 'Température moyenne ${v.toStringAsFixed(1)}°C'
      : 'Average temperature ${v.toStringAsFixed(1)}°C';

  // ── Yellow rust triggers ──
  String yrCrit(int n) => _ar
      ? '${days(n)} برطوبة > 80% وحرارة 2–20°C (الشروط المثلى — USDA CDL; PubMed 2003)'
      : _fr ? '${days(n)} humidité > 80 % et T 2–20 °C (conditions optimales — USDA CDL; PubMed 2003)'
      : '${days(n)} with humidity > 80% and T 2–20°C (optimal conditions — USDA CDL; PubMed 2003)';
  String yrCrit1(int n) => _ar
      ? '${day(n)} برطوبة > 80% وحرارة 2–20°C'
      : _fr ? '${day(n)} humidité > 80 % et T 2–20 °C'
      : '${day(n)} with humidity > 80% and T 2–20°C';
  String yrOpt(int n) => _ar
      ? '${days(n)} رطوبة > 70% وحرارة 2–20°C (نافذة إصابة متوسطة)'
      : _fr ? '${days(n)} humidité > 70 % et T 2–20 °C (fenêtre d\'infection modérée)'
      : '${days(n)} with humidity > 70% and T 2–20°C (moderate infection window)';
  String yrOpt2(int n) => _ar
      ? '${days(n)} أيام بظروف مناسبة للصدأ الأصفر'
      : _fr ? '${days(n)} avec conditions favorables à la rouille jaune'
      : '${days(n)} with conditions suitable for yellow rust';
  String yrOptTemp(double v) => _ar
      ? '${avgTemp(v)} في النطاق الأمثل (10–15°C)'
      : _fr ? '${avgTemp(v)} dans la plage optimale (10–15 °C)'
      : '${avgTemp(v)} in the optimal range (10–15°C)';
  String yrAcceptTemp(double v) => _ar
      ? '${avgTemp(v)} في النطاق المقبول للصدأ الأصفر (15–20°C)'
      : _fr ? '${avgTemp(v)} dans la plage acceptable (15–20 °C)'
      : '${avgTemp(v)} in the acceptable range for yellow rust (15–20°C)';
  String yrHighTemp(double v) => _ar
      ? 'تنبيه: ${avgTemp(v)} > 21°C — يثبط تطور الصدأ الأصفر بشكل كبير'
      : _fr ? 'Avertissement : ${avgTemp(v)} > 21 °C — inhibe fortement le développement de la rouille jaune'
      : 'Warning: ${avgTemp(v)} > 21°C — strongly inhibits yellow rust development';

  // ── Yellow rust prevention ──
  List<String> get yrPrev => _ar ? [
    'الري في الصباح الباكر فقط (5–7 ص) لتقليل بلل الأوراق',
    'تجنب الري الرأسي كلياً عند توقع رطوبة ليلية عالية',
    'رش مبيد فطري وقائي (تريازول) قبل فترة الرطوبة المرتقبة',
    'مراقبة بثرات صفراء/برتقالية على الأوراق مرة أسبوعياً',
    'ضمان تهوية كافية بين صفوف النبات',
  ] : _fr ? [
    'Irriguer tôt le matin uniquement (5 h–7 h) pour réduire le mouillage des feuilles',
    'Éviter totalement l\'irrigation par aspersion lors de nuits à forte humidité prévue',
    'Appliquer un fongicide préventif (triazole) avant la période d\'humidité',
    'Surveiller les pustules jaunes/orange sur feuilles chaque semaine',
    'Assurer une bonne ventilation entre les rangs de plantes',
  ] : [
    'Irrigate early morning only (5–7 AM) to reduce leaf wetness',
    'Avoid overhead irrigation entirely when high overnight humidity is expected',
    'Apply a preventive fungicide (triazole) before the upcoming humidity period',
    'Monitor for yellow/orange pustules on leaves weekly',
    'Ensure adequate ventilation between plant rows',
  ];

  // ── Brown rust triggers ──
  String brInfect(int n) => _ar
      ? '${days(n)} رطوبة > 60% وحرارة 8–16°C (نموذج لوكسمبورغ — Springer 2013)'
      : _fr ? '${days(n)} humidité > 60 % et T 8–16 °C (modèle Luxembourg — Springer 2013)'
      : '${days(n)} humidity > 60% and T 8–16°C (Luxembourg model — Springer 2013)';
  String brInfect2(int n) => _ar
      ? '${days(n)} رطوبة > 60% وحرارة 8–16°C (شروط إصابة ليلية)'
      : _fr ? '${days(n)} humidité > 60 % et T 8–16 °C (conditions d\'infection nocturne)'
      : '${days(n)} humidity > 60% and T 8–16°C (nocturnal infection conditions)';
  String brHighHum(int n) => _ar
      ? '${days(n)} رطوبة > 80% وحرارة 8–25°C (انتشار أسرع)'
      : _fr ? '${days(n)} humidité > 80 % et T 8–25 °C (propagation plus rapide)'
      : '${days(n)} humidity > 80% and T 8–25°C (faster spread)';
  String brFav(int n) => _ar
      ? '${days(n)} رطوبة > 60% وحرارة 8–25°C (USDA CDL)'
      : _fr ? '${days(n)} humidité > 60 % et T 8–25 °C (USDA CDL)'
      : '${days(n)} humidity > 60% and T 8–25°C (USDA CDL)';
  String brOptTemp(double v) => _ar
      ? '${avgTemp(v)} في النطاق الأمثل للصدأ البني (15–25°C — USDA CDL)'
      : _fr ? '${avgTemp(v)} dans la plage optimale de la rouille brune (15–25 °C — USDA CDL)'
      : '${avgTemp(v)} in optimal range for brown rust (15–25°C — USDA CDL)';
  String brAccTemp(double v) => _ar
      ? '${avgTemp(v)} في النطاق القابل للإصابة (8–15°C)'
      : _fr ? '${avgTemp(v)} dans la plage infectieuse (8–15 °C)'
      : '${avgTemp(v)} in the infectable range (8–15°C)';

  List<String> get brPrev => _ar ? [
    'الري الصباحي فقط لتقليل الرطوبة الليلية على الأوراق',
    'رش مبيد تريازول أو ستروبيلورين عند ظهور أولى البثرات البنية',
    'فحص الوجه السفلي للأوراق يومياً خلال فترة الخطر',
    'التفضيل لنظام الري بالتنقيط',
  ] : _fr ? [
    'Irriguer le matin uniquement pour réduire l\'humidité nocturne sur les feuilles',
    'Appliquer un triazole ou strobilurine dès les premières pustules brunes',
    'Inspecter la face inférieure des feuilles quotidiennement pendant la période à risque',
    'Privilégier l\'irrigation goutte-à-goutte',
  ] : [
    'Morning irrigation only to reduce overnight leaf humidity',
    'Apply triazole or strobilurin fungicide at the first brown pustules',
    'Inspect the underside of leaves daily during the risk period',
    'Prefer drip irrigation',
  ];

  // ── Stem rust triggers ──
  String srHotHumid(int n) => _ar
      ? '${days(n)} حرارة نهارية 18–30°C ورطوبة > 60% (Nebraska Ext.; USDA CDL)'
      : _fr ? '${days(n)} T diurne 18–30 °C et humidité > 60 % (Nebraska Ext.; USDA CDL)'
      : '${days(n)} daytime T 18–30°C and humidity > 60% (Nebraska Ext.; USDA CDL)';
  String srHotHumid1(int n) => _ar
      ? '${day(n)} حرارة 18–30°C ورطوبة > 60%'
      : _fr ? '${day(n)} T 18–30 °C et humidité > 60 %'
      : '${day(n)} with T 18–30°C and humidity > 60%';
  String srNight(int n) => _ar
      ? '${days(n)} حرارة ليلية 15–22°C ورطوبة > 55% (تعزز دورة العدوى)'
      : _fr ? '${days(n)} T nocturne 15–22 °C et humidité > 55 % (favorise les cycles d\'infection)'
      : '${days(n)} night T 15–22°C and humidity > 55% (enhances infection cycles)';
  String srFav(int n) => _ar
      ? '${days(n)} حرارة 15–30°C ورطوبة > 55% (نطاق إصابة مقبول)'
      : _fr ? '${days(n)} T 15–30 °C et humidité > 55 % (plage d\'infection acceptable)'
      : '${days(n)} T 15–30°C and humidity > 55% (acceptable infection range)';
  String srAvg(double t, double h) => _ar
      ? '${avgTemp(t)} ورطوبة ${h.toStringAsFixed(0)}% ضمن النطاق الأمثل'
      : _fr ? '${avgTemp(t)} et humidité ${h.toStringAsFixed(0)} % dans la plage optimale'
      : '${avgTemp(t)} and humidity ${h.toStringAsFixed(0)}% within optimal range';

  List<String> get srPrev => _ar ? [
    'مراقبة الساق والأوراق السفلية لاكتشاف البثرات البنية-السوداء',
    'الري الصباحي المبكر فقط (6–8 ساعات رطوبة حرجة)',
    'تطبيق مبيد فطري جهازي (تريازول) فور ظهور أولى الأعراض',
    'تجنب التسميد الآزوتي الزائد في مرحلة الإشطاء',
  ] : _fr ? [
    'Surveiller les tiges et les feuilles inférieures pour détecter des pustules brun-noires',
    'Irriguer tôt le matin uniquement (6–8 heures d\'humidité critique)',
    'Appliquer un fongicide systémique (triazole) dès les premiers symptômes',
    'Éviter les excès d\'azote au stade tallage',
  ] : [
    'Monitor stems and lower leaves for brown-black pustules',
    'Early morning irrigation only (6–8 critical hours of moisture)',
    'Apply a systemic fungicide (triazole) at first symptoms',
    'Avoid excess nitrogen fertilisation during tillering',
  ];

  // ── Septoria triggers ──
  String sepEpic(int n) => _ar
      ? '${days(n)} رطوبة > 85% وحرارة 15–25°C (شروط وبائية — AHDB; Plantix)'
      : _fr ? '${days(n)} humidité > 85 % et T 15–25 °C (conditions épidémiques — AHDB; Plantix)'
      : '${days(n)} humidity > 85% and T 15–25°C (epidemic conditions — AHDB; Plantix)';
  String sepEpic1(int n) => _ar
      ? '${day(n)} رطوبة > 85% وحرارة 15–25°C (> 20 ساعة رطوبة حرجة)'
      : _fr ? '${day(n)} humidité > 85 % et T 15–25 °C (> 20 h d\'humidité critique)'
      : '${day(n)} humidity > 85% and T 15–25°C (> 20 h critical humidity needed)';
  String sepVeryHigh(int n) => _ar
      ? '${days(n)} رطوبة ≥ 90% (PMC 7716521)'
      : _fr ? '${days(n)} humidité ≥ 90 % (PMC 7716521)'
      : '${days(n)} humidity ≥ 90% (PMC 7716521)';
  String sepVeryHigh2(int n) => _ar
      ? '${days(n)} رطوبة ≥ 90%'
      : _fr ? '${days(n)} humidité ≥ 90 %'
      : '${days(n)} with humidity ≥ 90%';
  String sepFav(int n) => _ar
      ? '${days(n)} رطوبة > 70% وحرارة 10–25°C (تراكم بلل يرفع الخطر)'
      : _fr ? '${days(n)} humidité > 70 % et T 10–25 °C (accumulation de rosée)'
      : '${days(n)} humidity > 70% and T 10–25°C (accumulated wetness raises risk)';
  String sepOptTemp(double v) => _ar
      ? '${avgTemp(v)} في النطاق الأمثل للسبتوريا (15–20°C — AHDB)'
      : _fr ? '${avgTemp(v)} dans la plage optimale de la septoriose (15–20 °C — AHDB)'
      : '${avgTemp(v)} in optimal range for septoria (15–20°C — AHDB)';
  String sepAccTemp(double v) => _ar
      ? '${avgTemp(v)} في نطاق مقبول للسبتوريا (20–25°C)'
      : _fr ? '${avgTemp(v)} dans une plage acceptable (20–25 °C)'
      : '${avgTemp(v)} in acceptable range for septoria (20–25°C)';
  String sepCold(double v) => _ar
      ? '${avgTemp(v)} < 4°C — الدورة البيولوجية للسبتوريا متوقفة تماماً (Plantix)'
      : _fr ? '${avgTemp(v)} < 4 °C — cycle biologique de la septoriose complètement arrêté (Plantix)'
      : '${avgTemp(v)} < 4°C — septoria biological cycle completely stopped (Plantix)';

  List<String> get sepPrev => _ar ? [
    'التحول لنظام الري بالتنقيط فوراً',
    'إزالة الأوراق السفلية المصابة وتدميرها خارج الحقل',
    'رش مبيد تريازول أو مزيج ستروبيلورين+تريازول',
    'تحسين صرف الحقل وتجنب التكثيف الزائد',
    'المراقبة الأسبوعية في مراحل الإشطاء والشوكة',
  ] : _fr ? [
    'Passer immédiatement à l\'irrigation goutte-à-goutte',
    'Retirer et détruire hors champ les feuilles inférieures infectées',
    'Appliquer un triazole ou un mélange strobilurine+triazole',
    'Améliorer le drainage et éviter la densité excessive',
    'Surveillance hebdomadaire au stade tallage et épi 1 cm',
  ] : [
    'Switch to drip irrigation immediately',
    'Remove and destroy infected lower leaves outside the field',
    'Apply triazole or strobilurin+triazole mixture',
    'Improve field drainage and avoid excessive plant density',
    'Weekly monitoring at tillering and flag-leaf stages',
  ];

  // ── Fusarium triggers ──
  String fusRapid(int n) => _ar
      ? '${days(n)} رطوبة > 95% وحرارة 16–30°C (انتشار فائق — PMC 9793406)'
      : _fr ? '${days(n)} humidité > 95 % et T 16–30 °C (propagation ultra-rapide — PMC 9793406)'
      : '${days(n)} humidity > 95% and T 16–30°C (ultra-rapid spread — PMC 9793406)';
  String fusCrit(int n) => _ar
      ? '${days(n)} رطوبة > 90% وحرارة 15–30°C (خطر عالٍ)'
      : _fr ? '${days(n)} humidité > 90 % et T 15–30 °C (risque élevé)'
      : '${days(n)} humidity > 90% and T 15–30°C (high risk)';
  String fusCrit1(int n) => _ar
      ? '${day(n)} رطوبة > 90% وحرارة 15–30°C'
      : _fr ? '${day(n)} humidité > 90 % et T 15–30 °C'
      : '${day(n)} humidity > 90% and T 15–30°C';
  String fusFav(int n) => _ar
      ? '${days(n)} رطوبة ≥ 70% وحرارة 15–30°C (Bayer: 36h+ عند الإزهار)'
      : _fr ? '${days(n)} humidité ≥ 70 % et T 15–30 °C (Bayer : 36 h+ à la floraison)'
      : '${days(n)} humidity ≥ 70% and T 15–30°C (Bayer: 36 h+ during flowering)';
  String fusOptTemp(double v) => _ar
      ? '${avgTemp(v)} في النطاق الأمثل لنمو الفطر (25–30°C، أمثلية عند 28–29°C)'
      : _fr ? '${avgTemp(v)} dans la plage optimale du champignon (25–30 °C, optimum 28–29 °C)'
      : '${avgTemp(v)} in the optimal range for fungal growth (25–30°C, optimum 28–29°C)';
  String fusFavTemp(double v) => _ar
      ? '${avgTemp(v)} مواتٍ للفوزاريوم (20–25°C — Bayer)'
      : _fr ? '${avgTemp(v)} favorable à la fusariose (20–25 °C — Bayer)'
      : '${avgTemp(v)} favorable for Fusarium (20–25°C — Bayer)';

  List<String> get fusPrev => _ar ? [
    'تجنب الري الرأسي كلياً خلال مرحلة الإزهار',
    'رش Prothioconazole أو Tebuconazole عند 50% إزهار',
    'ضمان صرف جيد لمياه الأمطار',
    'فحص الحبوب عند الحصاد للكشف عن الميكوتوكسينات (DON)',
    'زراعة أصناف مقاومة للفوزاريوم إن أمكن',
  ] : _fr ? [
    'Éviter totalement l\'irrigation par aspersion pendant la floraison',
    'Appliquer du Prothioconazole ou Tebuconazole à 50 % de floraison',
    'Assurer un bon drainage des eaux de pluie',
    'Analyser les grains à la récolte pour les mycotoxines (DON)',
    'Utiliser des variétés résistantes à la fusariose si possible',
  ] : [
    'Completely avoid overhead irrigation during flowering',
    'Apply Prothioconazole or Tebuconazole at 50% flowering',
    'Ensure good drainage of rainwater from the field',
    'Test grain at harvest for mycotoxins (DON)',
    'Use Fusarium-resistant varieties if available',
  ];

  // ── Mildew triggers ──
  String mildSweet(int n) => _ar
      ? '${days(n)} رطوبة ≥ 85% وحرارة 12–22°C (Bayer; USDA)'
      : _fr ? '${days(n)} humidité ≥ 85 % et T 12–22 °C (Bayer; USDA)'
      : '${days(n)} humidity ≥ 85% and T 12–22°C (Bayer; USDA)';
  String mildSweet2(int n) => _ar
      ? '${days(n)} رطوبة ≥ 85% وحرارة 12–22°C'
      : _fr ? '${days(n)} humidité ≥ 85 % et T 12–22 °C'
      : '${days(n)} humidity ≥ 85% and T 12–22°C';
  String mildOptTemp(double v) => _ar
      ? '${avgTemp(v)} في النطاق الأمثل (15–21°C — Bayer 2024)'
      : _fr ? '${avgTemp(v)} dans la plage optimale (15–21 °C — Bayer 2024)'
      : '${avgTemp(v)} in the optimal range (15–21°C — Bayer 2024)';
  String mildAccTemp(double v) => _ar
      ? '${avgTemp(v)} في نطاق مقبول (12–15°C)'
      : _fr ? '${avgTemp(v)} dans une plage acceptable (12–15 °C)'
      : '${avgTemp(v)} in acceptable range (12–15°C)';
  String mildHighTemp(double v) => _ar
      ? 'تنبيه: ${avgTemp(v)} > 25°C — يُفكك البياض الدقيقي (Bayer)'
      : _fr ? 'Avertissement : ${avgTemp(v)} > 25 °C — détériore l\'oïdium (Bayer)'
      : 'Warning: ${avgTemp(v)} > 25°C — destroys powdery mildew (Bayer)';
  String mildDew(int n) => _ar
      ? '${days(n)} فارق حراري ≥ 12°C بين النهار والليل → تكوّن ندى'
      : _fr ? '${days(n)} écart thermique ≥ 12 °C jour/nuit → formation de rosée'
      : '${days(n)} days with ≥ 12°C diurnal range → dew formation compensates rain absence';
  String mildMod(int n) => _ar
      ? '${days(n)} رطوبة 70–84% وحرارة 12–22°C (خطر معتدل)'
      : _fr ? '${days(n)} humidité 70–84 % et T 12–22 °C (risque modéré)'
      : '${days(n)} humidity 70–84% and T 12–22°C (moderate risk)';
  String mildDiurnal(double v) => _ar
      ? 'فارق حراري يومي متوسط ${v.toStringAsFixed(1)}°C يعزز تكثف الرطوبة'
      : _fr ? 'Amplitude thermique quotidienne moyenne ${v.toStringAsFixed(1)} °C favorise la condensation'
      : 'Average daily thermal range ${v.toStringAsFixed(1)}°C enhances moisture condensation';

  List<String> get mildPrev => _ar ? [
    'ضمان تهوية جيدة بين النباتات (تجنب الزراعة الكثيفة)',
    'رش مبيد كبريتي أو ستروبيلورين كإجراء وقائي',
    'الري على مستوى التربة فقط — تجنب رش الأوراق',
    'إزالة الأوراق المصابة بالبودرة البيضاء فوراً',
    'تجنب الإفراط في التسميد الآزوتي',
  ] : _fr ? [
    'Assurer une bonne ventilation entre les plantes (éviter la densité excessive)',
    'Appliquer un fongicide soufré ou strobilurine en préventif',
    'Irriguer au niveau du sol uniquement — éviter la pulvérisation foliaire',
    'Retirer immédiatement les feuilles avec poudre blanche',
    'Éviter l\'excès d\'azote',
  ] : [
    'Ensure good ventilation between plants (avoid dense planting)',
    'Apply sulphur-based or strobilurin fungicide as preventive',
    'Irrigate at soil level only — avoid leaf wetting',
    'Remove leaves with white powder immediately',
    'Avoid excess nitrogen fertilisation',
  ];

  // ── Tan spot triggers ──
  String tsOpt(int n) => _ar
      ? '${days(n)} رطوبة > 80% وحرارة 18–28°C (Minireview 2024)'
      : _fr ? '${days(n)} humidité > 80 % et T 18–28 °C (Minireview 2024)'
      : '${days(n)} humidity > 80% and T 18–28°C (Minireview 2024)';
  String tsOpt1(int n) => _ar
      ? '${day(n)} رطوبة > 80% وحرارة 18–28°C'
      : _fr ? '${day(n)} humidité > 80 % et T 18–28 °C'
      : '${day(n)} humidity > 80% and T 18–28°C';
  String tsFast(int n) => _ar
      ? '${days(n)} رطوبة > 75% وحرارة 20–27°C (UAEX FSA-7544)'
      : _fr ? '${days(n)} humidité > 75 % et T 20–27 °C (UAEX FSA-7544)'
      : '${days(n)} humidity > 75% and T 20–27°C (UAEX FSA-7544)';
  String tsFast2(int n) => _ar
      ? '${days(n)} رطوبة > 75% وحرارة 20–27°C'
      : _fr ? '${days(n)} humidité > 75 % et T 20–27 °C'
      : '${days(n)} humidity > 75% and T 20–27°C';
  String tsMin(int n) => _ar
      ? '${days(n)} رطوبة > 70% وحرارة > 10°C (تراكم بلل مستمر)'
      : _fr ? '${days(n)} humidité > 70 % et T > 10 °C (accumulation continue de rosée)'
      : '${days(n)} humidity > 70% and T > 10°C (continuous wetness accumulation)';
  String tsOptTemp(double v) => _ar
      ? '${avgTemp(v)} في النطاق الأمثل للبقعة الصفراء (20–27°C)'
      : _fr ? '${avgTemp(v)} dans la plage optimale de la tache bronzée (20–27 °C)'
      : '${avgTemp(v)} in the optimal range for tan spot (20–27°C)';

  List<String> get tsPrev => _ar ? [
    'تجنب الري المسائي — الري الصباحي فقط (6 ساعات بلل تُنبت الجراثيم)',
    'دفن بقايا المحصول السابق لتقليل مصدر العدوى',
    'تناوب المحاصيل (عدم زراعة قمح خلف قمح)',
    'رش مبيد فطري عند مرحلة الورقة العلمية',
  ] : _fr ? [
    'Éviter l\'irrigation en soirée — irriguer le matin uniquement (6 h de rosée suffisent à germer)',
    'Enfouir les résidus de récolte précédents pour réduire l\'inoculum',
    'Pratiquer la rotation des cultures (ne pas semer blé après blé)',
    'Appliquer un fongicide au stade feuille étendard',
  ] : [
    'Avoid evening irrigation — morning only (6 h of wetness germinates spores)',
    'Bury previous crop residues to reduce inoculum source',
    'Rotate crops (do not plant wheat after wheat)',
    'Apply fungicide at flag-leaf stage',
  ];

  // ── Root rot triggers ──
  String rrWaterlog(int n) => _ar
      ? '${days(n)} رطوبة > 90% وحرارة < 20°C (Bipolaris sorokiniana)'
      : _fr ? '${days(n)} humidité > 90 % et T < 20 °C (Bipolaris sorokiniana)'
      : '${days(n)} humidity > 90% and T < 20°C (Bipolaris sorokiniana)';
  String rrWaterlog1(int n) => _ar
      ? '${day(n)} رطوبة > 90% مع حرارة منخفضة < 20°C'
      : _fr ? '${day(n)} humidité > 90 % avec T basse < 20 °C'
      : '${day(n)} humidity > 90% with low T < 20°C';
  String rrHighHum(int n) => _ar
      ? '${days(n)} رطوبة > 85% (ضغط مستمر على الجذور)'
      : _fr ? '${days(n)} humidité > 85 % (pression continue sur les racines)'
      : '${days(n)} humidity > 85% (continuous root pressure)';
  String rrHighHum2(int n) => _ar
      ? '${days(n)} رطوبة > 85%'
      : _fr ? '${days(n)} humidité > 85 %'
      : '${days(n)} humidity > 85%';
  String rrAvg(double t, double h) => _ar
      ? 'حرارة ${t.toStringAsFixed(1)}°C مع رطوبة ${h.toStringAsFixed(0)}% → ظروف ملائمة لتعفن الجذور'
      : _fr ? 'T ${t.toStringAsFixed(1)} °C avec humidité ${h.toStringAsFixed(0)} % → conditions favorables à la pourriture racinaire'
      : 'T ${t.toStringAsFixed(1)}°C with humidity ${h.toStringAsFixed(0)}% → conditions suitable for root rot';

  List<String> get rrPrev => _ar ? [
    'تخفيض الري فوراً وتحسين صرف مياه الحقل',
    'فحص الجذور للكشف عن التلون البني أو الأسود',
    'تجنب دهس التربة بالجرارات في فترة الرطوبة العالية',
    'تطبيق مبيدات فطرية جذرية (ميتالاكسيل أو تيبوكونازول)',
  ] : _fr ? [
    'Réduire l\'irrigation immédiatement et améliorer le drainage',
    'Inspecter les racines pour détecter des décolorations brunes ou noires',
    'Éviter le tassement du sol par les tracteurs pendant les périodes humides',
    'Appliquer des fongicides racinaires (métalaxyl ou tébuconazole)',
  ] : [
    'Reduce irrigation immediately and improve field drainage',
    'Inspect roots for brown or black discolouration',
    'Avoid soil compaction by tractors during high-humidity periods',
    'Apply root fungicides (metalaxyl or tebuconazole)',
  ];
}

// ─── Main engine ────────────────────────────────────────────────
class DiseaseRiskEngine {
  static List<DiseaseRisk> calculateRisks(
      List<DailyWeather> forecast, Locale locale) {
    return [
      _yellowRust(forecast, locale),
      _brownRust(forecast, locale),
      _stemRust(forecast, locale),
      _septoria(forecast, locale),
      _fusarium(forecast, locale),
      _mildew(forecast, locale),
      _tanSpot(forecast, locale),
      _rootRot(forecast, locale),
    ]..sort((a, b) => b.riskPercent.compareTo(a.riskPercent));
  }

  static List<DiseaseRisk> getAlerts(
      List<DailyWeather> forecast, Locale locale) {
    return calculateRisks(forecast, locale)
        .where((r) => r.riskPercent >= 60.0)
        .toList();
  }

  // ─── helpers ──────────────────────────────────────────────────
  static double _avg(List<DailyWeather> f, double Function(DailyWeather) fn) =>
      f.map(fn).reduce((a, b) => a + b) / f.length;

  static int _daysBoth(List<DailyWeather> f,
          bool Function(DailyWeather) c1, bool Function(DailyWeather) c2) =>
      f.where((d) => c1(d) && c2(d)).length;

  static double _cap(double s) => s.clamp(0.0, 85.0);

  static String _levelKey(double p) {
    if (p < 40) return 'Low';
    if (p < 60) return 'Moderate';
    if (p < 75) return 'High';
    return 'Critical';
  }

  static String _color(double p) {
    if (p < 40) return '#4CAF50';
    if (p < 60) return '#FFC107';
    if (p < 75) return '#FF9800';
    return '#F44336';
  }

  // ─── 1. Yellow Rust ───────────────────────────────────────────
  static DiseaseRisk _yellowRust(List<DailyWeather> f, Locale locale) {
    final l = _L(locale);
    final avgTemp = _avg(f, (d) => d.avgTemp);

    final critDays = _daysBoth(f,
        (d) => d.humidity > 80, (d) => d.avgTemp >= 2 && d.avgTemp <= 20);
    final optDays = _daysBoth(f,
        (d) => d.humidity > 70, (d) => d.avgTemp >= 2 && d.avgTemp <= 20);

    double s = 0;
    final t = <String>[], p = <String>[];

    if (critDays >= 3) { s += 45; t.add(l.yrCrit(critDays)); }
    else if (critDays >= 1) { s += 25; t.add(l.yrCrit1(critDays)); }
    if (optDays >= 4) { s += 25; t.add(l.yrOpt(optDays)); }
    else if (optDays >= 2) { s += 12; t.add(l.yrOpt2(optDays)); }
    if (avgTemp >= 10 && avgTemp <= 15) { s += 15; t.add(l.yrOptTemp(avgTemp)); }
    else if (avgTemp > 15 && avgTemp <= 20) { s += 7; t.add(l.yrAcceptTemp(avgTemp)); }
    if (avgTemp > 21) { s = (s * 0.4).clamp(0, 85); t.add(l.yrHighTemp(avgTemp)); }
    if (s > 0) p.addAll(l.yrPrev);

    final pct = _cap(s);
    return DiseaseRisk(
      diseaseName: l.yellowRust,
      riskPercent: pct,
      riskLevel: l.level(pct),
      riskLevelKey: _levelKey(pct),
      riskColor: _color(pct),
      triggers: t,
      prevention: p,
    );
  }

  // ─── 2. Brown Rust ────────────────────────────────────────────
  static DiseaseRisk _brownRust(List<DailyWeather> f, Locale locale) {
    final l = _L(locale);
    final avgTemp = _avg(f, (d) => d.avgTemp);

    final infectionDays = _daysBoth(f,
        (d) => d.humidity > 60, (d) => d.avgTemp >= 8 && d.avgTemp <= 16);
    final favDays = _daysBoth(f,
        (d) => d.humidity > 60, (d) => d.avgTemp >= 8 && d.avgTemp <= 25);
    final highHumDays = _daysBoth(f,
        (d) => d.humidity > 80, (d) => d.avgTemp >= 8 && d.avgTemp <= 25);

    double s = 0;
    final t = <String>[], p = <String>[];

    if (infectionDays >= 4) { s += 42; t.add(l.brInfect(infectionDays)); }
    else if (infectionDays >= 2) { s += 22; t.add(l.brInfect2(infectionDays)); }
    if (highHumDays >= 3) { s += 25; t.add(l.brHighHum(highHumDays)); }
    else if (favDays >= 5) { s += 18; t.add(l.brFav(favDays)); }
    else if (favDays >= 3) s += 10;
    if (avgTemp >= 15 && avgTemp <= 25) { s += 13; t.add(l.brOptTemp(avgTemp)); }
    else if (avgTemp >= 8 && avgTemp < 15) { s += 6; t.add(l.brAccTemp(avgTemp)); }
    if (s > 0) p.addAll(l.brPrev);

    final pct = _cap(s);
    return DiseaseRisk(
      diseaseName: l.brownRust,
      riskPercent: pct,
      riskLevel: l.level(pct),
      riskLevelKey: _levelKey(pct),
      riskColor: _color(pct),
      triggers: t,
      prevention: p,
    );
  }

  // ─── 3. Stem Rust ─────────────────────────────────────────────
  static DiseaseRisk _stemRust(List<DailyWeather> f, Locale locale) {
    final l = _L(locale);
    final avgHum = _avg(f, (d) => d.humidity);
    final avgTemp = _avg(f, (d) => d.avgTemp);

    final hotHumidDays = _daysBoth(f,
        (d) => d.temp >= 18 && d.temp <= 30, (d) => d.humidity > 60);
    final favDays = _daysBoth(f,
        (d) => d.temp >= 15 && d.temp <= 30, (d) => d.humidity > 55);
    final nightOptDays = _daysBoth(f,
        (d) => d.minTemp >= 15 && d.minTemp <= 22, (d) => d.humidity > 55);

    double s = 0;
    final t = <String>[], p = <String>[];

    if (hotHumidDays >= 3) { s += 45; t.add(l.srHotHumid(hotHumidDays)); }
    else if (hotHumidDays >= 1) { s += 22; t.add(l.srHotHumid1(hotHumidDays)); }
    if (nightOptDays >= 3) { s += 22; t.add(l.srNight(nightOptDays)); }
    else if (favDays >= 4) { s += 15; t.add(l.srFav(favDays)); }
    if (avgHum > 65 && avgTemp >= 18 && avgTemp <= 30) {
      s += 10; t.add(l.srAvg(avgTemp, avgHum));
    }
    if (s > 0) p.addAll(l.srPrev);

    final pct = _cap(s);
    return DiseaseRisk(
      diseaseName: l.stemRust,
      riskPercent: pct,
      riskLevel: l.level(pct),
      riskLevelKey: _levelKey(pct),
      riskColor: _color(pct),
      triggers: t,
      prevention: p,
    );
  }

  // ─── 4. Septoria ──────────────────────────────────────────────
  static DiseaseRisk _septoria(List<DailyWeather> f, Locale locale) {
    final l = _L(locale);
    final avgTemp = _avg(f, (d) => d.avgTemp);

    final epicDays = _daysBoth(f,
        (d) => d.humidity > 85, (d) => d.avgTemp >= 15 && d.avgTemp <= 25);
    final favDays = _daysBoth(f,
        (d) => d.humidity > 70, (d) => d.avgTemp >= 10 && d.avgTemp <= 25);
    final veryHighHumDays = f.where((d) => d.humidity >= 90).length;

    double s = 0;
    final t = <String>[], p = <String>[];

    if (epicDays >= 3) { s += 48; t.add(l.sepEpic(epicDays)); }
    else if (epicDays >= 1) { s += 26; t.add(l.sepEpic1(epicDays)); }
    if (veryHighHumDays >= 4) { s += 22; t.add(l.sepVeryHigh(veryHighHumDays)); }
    else if (veryHighHumDays >= 2) { s += 12; t.add(l.sepVeryHigh2(veryHighHumDays)); }
    if (favDays >= 4) { s += 15; t.add(l.sepFav(favDays)); }
    else if (favDays >= 2) s += 8;
    if (avgTemp >= 15 && avgTemp <= 20) { s += 10; t.add(l.sepOptTemp(avgTemp)); }
    else if (avgTemp > 20 && avgTemp <= 25) { s += 5; t.add(l.sepAccTemp(avgTemp)); }
    if (avgTemp < 4) { s = 0; t.add(l.sepCold(avgTemp)); }
    if (s > 0) p.addAll(l.sepPrev);

    final pct = _cap(s);
    return DiseaseRisk(
      diseaseName: l.septoria,
      riskPercent: pct,
      riskLevel: l.level(pct),
      riskLevelKey: _levelKey(pct),
      riskColor: _color(pct),
      triggers: t,
      prevention: p,
    );
  }

  // ─── 5. Fusarium ──────────────────────────────────────────────
  static DiseaseRisk _fusarium(List<DailyWeather> f, Locale locale) {
    final l = _L(locale);
    final avgTemp = _avg(f, (d) => d.avgTemp);

    final rapidDays = _daysBoth(f,
        (d) => d.humidity > 95, (d) => d.avgTemp >= 16 && d.avgTemp <= 30);
    final critDays = _daysBoth(f,
        (d) => d.humidity > 90, (d) => d.avgTemp >= 15 && d.avgTemp <= 30);
    final favDays = _daysBoth(f,
        (d) => d.humidity >= 70, (d) => d.avgTemp >= 15 && d.avgTemp <= 30);

    double s = 0;
    final t = <String>[], p = <String>[];

    if (rapidDays >= 2) { s += 50; t.add(l.fusRapid(rapidDays)); }
    else if (critDays >= 2) { s += 40; t.add(l.fusCrit(critDays)); }
    else if (critDays == 1) { s += 24; t.add(l.fusCrit1(critDays)); }
    if (favDays >= 3) { s += 25; t.add(l.fusFav(favDays)); }
    else if (favDays >= 1) s += 12;
    if (avgTemp >= 25 && avgTemp <= 30) { s += 10; t.add(l.fusOptTemp(avgTemp)); }
    else if (avgTemp >= 20 && avgTemp < 25) { s += 6; t.add(l.fusFavTemp(avgTemp)); }
    if (s > 0) p.addAll(l.fusPrev);

    final pct = _cap(s);
    return DiseaseRisk(
      diseaseName: l.fusarium,
      riskPercent: pct,
      riskLevel: l.level(pct),
      riskLevelKey: _levelKey(pct),
      riskColor: _color(pct),
      triggers: t,
      prevention: p,
    );
  }

  // ─── 6. Powdery Mildew ────────────────────────────────────────
  static DiseaseRisk _mildew(List<DailyWeather> f, Locale locale) {
    final l = _L(locale);
    final avgTemp = _avg(f, (d) => d.avgTemp);
    final diurnal = _avg(f, (d) => d.temp - d.minTemp);

    final sweetDays = _daysBoth(f,
        (d) => d.humidity >= 85, (d) => d.avgTemp >= 12 && d.avgTemp <= 22);
    final dewDays = f.where((d) => (d.temp - d.minTemp) >= 12).length;
    final modDays = _daysBoth(f,
        (d) => d.humidity >= 70 && d.humidity < 85,
        (d) => d.avgTemp >= 12 && d.avgTemp <= 22);

    double s = 0;
    final t = <String>[], p = <String>[];

    if (sweetDays >= 4) { s += 40; t.add(l.mildSweet(sweetDays)); }
    else if (sweetDays >= 2) { s += 22; t.add(l.mildSweet2(sweetDays)); }
    if (avgTemp >= 15 && avgTemp <= 21) { s += 22; t.add(l.mildOptTemp(avgTemp)); }
    else if (avgTemp >= 12 && avgTemp < 15) { s += 10; t.add(l.mildAccTemp(avgTemp)); }
    if (avgTemp > 25) { s = (s * 0.3).clamp(0, 85); t.add(l.mildHighTemp(avgTemp)); }
    if (dewDays >= 3) { s += 18; t.add(l.mildDew(dewDays)); }
    if (modDays >= 3) { s += 8; t.add(l.mildMod(modDays)); }
    if (diurnal >= 10) { s += 5; t.add(l.mildDiurnal(diurnal)); }
    if (s > 0) p.addAll(l.mildPrev);

    final pct = _cap(s);
    return DiseaseRisk(
      diseaseName: l.mildew,
      riskPercent: pct,
      riskLevel: l.level(pct),
      riskLevelKey: _levelKey(pct),
      riskColor: _color(pct),
      triggers: t,
      prevention: p,
    );
  }

  // ─── 7. Tan Spot ──────────────────────────────────────────────
  static DiseaseRisk _tanSpot(List<DailyWeather> f, Locale locale) {
    final l = _L(locale);
    final avgTemp = _avg(f, (d) => d.avgTemp);

    final optDays = _daysBoth(f,
        (d) => d.humidity > 80, (d) => d.avgTemp >= 18 && d.avgTemp <= 28);
    final fastDays = _daysBoth(f,
        (d) => d.humidity > 75, (d) => d.avgTemp >= 20 && d.avgTemp <= 27);
    final minDays = _daysBoth(f,
        (d) => d.humidity > 70, (d) => d.avgTemp > 10 && d.avgTemp <= 30);

    double s = 0;
    final t = <String>[], p = <String>[];

    if (optDays >= 3) { s += 42; t.add(l.tsOpt(optDays)); }
    else if (optDays >= 1) { s += 22; t.add(l.tsOpt1(optDays)); }
    if (fastDays >= 3) { s += 25; t.add(l.tsFast(fastDays)); }
    else if (fastDays >= 2) { s += 13; t.add(l.tsFast2(fastDays)); }
    if (minDays >= 5) { s += 12; t.add(l.tsMin(minDays)); }
    if (avgTemp >= 20 && avgTemp <= 27) { s += 11; t.add(l.tsOptTemp(avgTemp)); }
    if (s > 0) p.addAll(l.tsPrev);

    final pct = _cap(s);
    return DiseaseRisk(
      diseaseName: l.tanSpot,
      riskPercent: pct,
      riskLevel: l.level(pct),
      riskLevelKey: _levelKey(pct),
      riskColor: _color(pct),
      triggers: t,
      prevention: p,
    );
  }

  // ─── 8. Root Rot ──────────────────────────────────────────────
  static DiseaseRisk _rootRot(List<DailyWeather> f, Locale locale) {
    final l = _L(locale);
    final avgHum = _avg(f, (d) => d.humidity);
    final avgTemp = _avg(f, (d) => d.avgTemp);

    final waterlogDays = _daysBoth(f,
        (d) => d.humidity > 90, (d) => d.avgTemp < 20);
    final highHumDays = f.where((d) => d.humidity > 85).length;

    double s = 0;
    final t = <String>[], p = <String>[];

    if (waterlogDays >= 3) { s += 48; t.add(l.rrWaterlog(waterlogDays)); }
    else if (waterlogDays >= 1) { s += 24; t.add(l.rrWaterlog1(waterlogDays)); }
    if (highHumDays >= 4) { s += 22; t.add(l.rrHighHum(highHumDays)); }
    else if (highHumDays >= 2) { s += 12; t.add(l.rrHighHum2(highHumDays)); }
    if (avgTemp < 18 && avgHum > 80) { s += 15; t.add(l.rrAvg(avgTemp, avgHum)); }
    if (s > 0) p.addAll(l.rrPrev);

    final pct = _cap(s);
    return DiseaseRisk(
      diseaseName: l.rootRot,
      riskPercent: pct,
      riskLevel: l.level(pct),
      riskLevelKey: _levelKey(pct),
      riskColor: _color(pct),
      triggers: t,
      prevention: p,
    );
  }
}