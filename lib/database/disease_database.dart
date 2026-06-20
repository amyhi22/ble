import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/disease_data.dart';

/// Centralized database for wheat disease information
class DiseaseDatabase {
  DiseaseDatabase._();
  static const String _boxName = 'diseases';
  static Box<DiseaseData>? _diseaseBox;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(DiseaseDataAdapter());
      }
      _diseaseBox = await Hive.openBox<DiseaseData>(_boxName);
      if (_diseaseBox!.isEmpty) {
        await _seedDatabase();
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ DiseaseDatabase initialization failed: $e');
      rethrow;
    }
  }

  static DiseaseData? getDisease(String name) {
    _checkInitialized();
    if (name.isEmpty) return null;
    final key = name.toLowerCase().trim();
    return _diseaseBox!.get(key);
  }

  static List<DiseaseData> getAllDiseases() {
    _checkInitialized();
    return _diseaseBox!.values.toList();
  }

  static bool hasDisease(String name) {
    _checkInitialized();
    return _diseaseBox!.containsKey(name.toLowerCase().trim());
  }

  static List<String> getDiseaseNames() {
    _checkInitialized();
    return _diseaseBox!.keys.cast<String>().toList();
  }

  static Future<void> clear() async {
    _checkInitialized();
    await _diseaseBox!.clear();
    await _seedDatabase();
  }

  static int get diseaseCount => _diseaseBox?.length ?? 0;
  static bool get isReady => _isInitialized && _diseaseBox != null;

  static void _checkInitialized() {
    if (!_isInitialized || _diseaseBox == null) {
      throw StateError(
        'DiseaseDatabase not initialized. Call DiseaseDatabase.init() in main().',
      );
    }
  }

  static Future<void> _seedDatabase() async {
    if (_diseaseBox == null) return;

    final diseases = <String, DiseaseData>{
      // ─────────────────────────────────────────
      'yellow rust': DiseaseData(
        name: 'Yellow Rust',
        iconPath: 'assets/icons/yellow_rust.png',
        symptoms: const [
          'Yellow-orange pustules on leaves',
          'Linear arrangement of spores',
          'Premature leaf yellowing',
          'Reduced grain yield',
        ],
        treatments: const [
          'Apply fungicides at early infection',
          'Use resistant wheat varieties',
          'Remove infected crop residues',
          'Avoid excessive nitrogen fertilization',
        ],
        medicines: const [
          'استشر متخصصاً زراعياً للحصول على المبيدات المعتمدة.',

        ],
        advice: const [
          'Plant early to avoid peak rust season',
          'Ensure proper field drainage',
          'Monitor weather for humidity spikes',
          'Rotate with non-host crops',
        ],
      ),

      // ─────────────────────────────────────────
      'black rust': DiseaseData(
        name: 'Black Rust',
        iconPath: 'assets/icons/black_rust.png',
        symptoms: const [
          'يظهر الطور الأول (اليوريدي) كبقع صفراء باهتة صغيرة.',
          'تليها بثرات بنية محمرة مستطيلة الشكل على أغمدة الأوراق والسيقان.',
          'الطور الثاني (التيليتي): بثرات سوداء لامعة غير متشققة على الساق.',
          'النباتات المصابة قصيرة وسهلة الانهيار.',
        ],
        treatments: const [
          'الرش الوقائي قبل الانتشار الشديد باستخدام مبيدات جهازية.',
          'تكرار الرش كل 14 يوماً.',
          'استخدام رذاذ جيد الغطاء مع إضافة مذيبات للالتصاق.',
          'إزالة النباتات المضيفة البديلة إن وجدت.',
        ],
        medicines: const ['استشر متخصصاً زراعياً للحصول على المبيدات المعتمدة.'],
        advice: const [
          'دورة زراعية 2-3 سنوات مع محاصيل غير مضيفة.',
          'زراعة أصناف مقاومة مثل Morocco أو Little Club.',
          'تسميد متوازن (تقليل النيتروجين الزائد).',
          'رصد جوي منتظم وزراعة متأخرة قليلاً.',
        ],
      ),

      // ─────────────────────────────────────────
      'aphid': DiseaseData(
        name: 'Aphid',
        iconPath: 'assets/icons/aphid.png',
        symptoms: const [
          'تجمع المن على الأوراق والسيقان مسبباً تجعدها واصفرارها.',
          'يفرز المن عسلاً لزجاً يجذب النمل والعفن الأسود.',
          'قزامة النباتات وضعف السنابل وتقليل الإنتاج.',
        ],
        treatments: const [
          'الرش عند تجاوز الحد الاقتصادي (10-15 حشرة/سنبلة).',
          'تكرار بعد 7-10 أيام إذا لزم.',
        ],
        medicines: const ['استشر متخصصاً زراعياً للحصول على المبيدات المعتمدة.'],
        advice: const [
          'إطلاق أعداء طبيعيين مثل الدعسوقة.',
          'زراعة متأخرة ودورة مع خضروات.',
          'تجنب الإفراط في النيتروجين.',
        ],
      ),

      // ─────────────────────────────────────────
      'blast': DiseaseData(
        name: 'Blast',
        iconPath: 'assets/icons/Blast.png',
        symptoms: const [
          'بقع رمادية أو بيضاوية مشبعة بالماء على الأوراق.',
          'نخر رمادي أو بني مع حواف سوداء أو هالة مصفرة.',
          'تبييض جزئي أو كامل للسنابل مع نقطة إصابة رمادية عند القاعدة.',
          'سنابل بيضاء أو نحيلة وغير ممتلئة.',
        ],
        treatments: const [
          'مبيدات فطرية جهازية مرتين بفاصل 7-10 أيام من مرحلة الإبط.',
          'معالجة البذور بـ Provax 200 WP أو Nativo قبل الزراعة.',
        ],
        medicines: const ['استشر متخصصاً زراعياً للحصول على المبيدات المعتمدة.'],
        advice: const [
          'زراعة أصناف مقاومة وتعديل توقيت الزراعة.',
          'تجنب الزراعة الكثيفة والإفراط في النيتروجين.',
          'دورة زراعية مناسبة ومراقبة الطقس للرش الوقائي.',
        ],
      ),

      // ─────────────────────────────────────────
      'brown rust': DiseaseData(
        name: 'Brown Rust',
        iconPath: 'assets/icons/aphid.png',
        symptoms: const [
          'بقع صغيرة برتقالية أو بنية فاتحة على سطح الأوراق السفلية.',
          'بثرات برتقالية مسحوقية تتحول إلى بني داكن مع التقدم.',
          'تجفيف الأوراق واصفرارها وتقليل التمثيل الضوئي.',
        ],
        treatments: const [
          'الرش الفوري بمبيدات فطرية جهازية عند ظهور أول أعراض.',
          'تكرار الرش بعد 10-14 يوماً في حالة الرطوبة العالية.',
          'الرش في الصباح الباكر أو المساء بحجم ماء 300-400 لتر/هكتار.',
        ],
        medicines: const ['استشر متخصصاً زراعياً للحصول على المبيدات المعتمدة.'],
        advice: const [
          'تجنب الزراعة الكثيفة (200-250 كجم بذور/هكتار).',
          'زراعة أصناف مقاومة.',
          'دورة زراعية مع بقوليات وتدمير بقايا المحصول.',
        ],
      ),

      // ─────────────────────────────────────────
      'common root rot': DiseaseData(
        name: 'Common Root Rot',
        iconPath: 'assets/icons/aphid.png',
        symptoms: const [
          'تلون بني عند قاعدة الساق والجذر مع تقلص المجموع الجذري.',
          'نباتات سهلة النزع، صفراء شاحبة، سنابل ضامرة.',
          'قزامة النباتات وتقليل الإنتاج.',
        ],
        treatments: const [
          'معالجة البذور بمبيدات فطرية جهازية قبل الزراعة.',
          'تحسين تصريف التربة فوراً وإزالة النباتات المصابة.',
          'منتجات بيولوجية مثل Bacillus subtilis.',
        ],
        medicines: const ['استشر متخصصاً زراعياً للحصول على المبيدات المعتمدة.'],
        advice: const [
          'دورة زراعية 2-3 سنوات مع البقوليات.',
          'تسميد متوازن غني بالفوسفور والبوتاسيوم.',
          'ري منتظم غير مفرط ورصد أسبوعي.',
        ],
      ),

      // ─────────────────────────────────────────
      'fusarium head blight': DiseaseData(
        name: 'Fusarium Head Blight',
        iconPath: 'assets/icons/aphid.png',
        symptoms: const [
          'سنابل غارقة بالماء وبيضاء اللون في البداية.',
          'تتحول إلى وردي-بني مع نمو فطري وفير.',
          'حبوب متعفنة صغيرة مجعدة بلون أحمر-وردي ملوثة بسموم DON.',
        ],
        treatments: const [
          'رش مبيدات جهازية في بداية الإزهار (GS 61) مع تكرار بعد 3-5 أيام.',
          'معالجة البذور بـ Celest Extra FS.',
          'تجفيف الحبوب بعد الحصاد عند 70°C لـ 5 أيام.',
        ],
        medicines: const ['استشر متخصصاً زراعياً للحصول على المبيدات المعتمدة.'],
        advice: const [
          'زراعة أصناف مقاومة مثل Sumai 3 أو Ernie.',
          'تجنب الإفراط في النيتروجين والري المتأخر.',
          'رصد جوي أثناء التزهير.',
        ],
      ),

      // ─────────────────────────────────────────
      'leaf blight': DiseaseData(
        name: 'Leaf Blight',
        iconPath: 'assets/icons/aphid.png',
        symptoms: const [
          'بقع صغيرة بنية داكنة إلى سوداء على الأوراق الفلقية.',
          'لطخ بيضوية بنية فاتحة إلى داكنة تندمج لتغطي الورقة.',
          'نباتات قصيرة وسنابل ضامرة وحبوب صغيرة أو فارغة.',
        ],
        treatments: const [
          'الرش الفوري بمبيدات جهازية عند GS 21-30.',
          'تكرار كل 10-14 يوماً مع حجم ماء 400 لتر/هكتار.',
        ],
        medicines: const ['استشر متخصصاً زراعياً للحصول على المبيدات المعتمدة.'],
        advice: const [
          'زراعة أصناف مقاومة وبذور معالجة بـ Dividend أو Celest.',
          'دورة زراعية 2-3 سنوات مع بقوليات.',
          'ري معتدل مع تهوية جيدة.',
        ],
      ),

      // ─────────────────────────────────────────
      'mildew': DiseaseData(
        name: 'Mildew',
        iconPath: 'assets/icons/aphid.png',
        symptoms: const [
          'بقع صفراء صغيرة على الأوراق السفلية.',
          'طبقة بيضاء مسحوقية تنتشر إلى الأوراق العلوية والسيقان والسنابل.',
          'الطبقة تتحول بنية أو رمادية مسببة اصفراراً وجفافاً.',
        ],
        treatments: const [
          'الرش الوقائي-علاجي عند أول علامات بيضاء مع تكرار كل 7-10 أيام.',
          'زيت النيم أو بيكربونات الصوديوم للحقول الصغيرة.',
        ],
        medicines: const ['استشر متخصصاً زراعياً للحصول على المبيدات المعتمدة.'],
        advice: const [
          'تجنب الزراعة الكثيفة والإفراط في النيتروجين.',
          'تدوير المحاصيل وتدمير القمح المتطوع.',
          'معالجات بذور مثل Tebuconazole.',
        ],
      ),

      // ─────────────────────────────────────────
      'septoria': DiseaseData(
        name: 'Septoria',
        iconPath: 'assets/icons/aphid.png',
        symptoms: const [
          'بقع صغيرة صفراء غارقة بالماء تتوسع إلى بقع شريطية بيضوية.',
          'مركزها يجف ليصبح بنياً محمراً أو رمادياً محاط بهالة صفراء.',
          'اندماج البقع لتغطي الورقة وتسقيطها.',
        ],
        treatments: const [
          'رش وقائي-علاجي مع تكرار 2-3 مرات كل 10-14 يوماً.',
          'حجم ماء 300-400 لتر/هكتار مع رش صباحي أو مسائي.',
        ],
        medicines: const ['استشر متخصصاً زراعياً للحصول على المبيدات المعتمدة.'],
        advice: const [
          'دورة زراعية ثلاثية مع بقوليات أو صليبيات.',
          'ري معتدل ورصد أسبوعي.',
          'تجنب الزراعة الكثيفة والإفراط في النيتروجين.',
        ],
      ),

      // ─────────────────────────────────────────
      'mite': DiseaseData(
        name: 'Mite',
        iconPath: 'assets/icons/aphid.png',
        symptoms: const [
          'شحوب وتجعد أطراف الأوراق العلوية وبقع صفراء منقطة.',
          'ولف الأوراق كأنبوب.',
          'قزامة النباتات وضعف السنابل.',
        ],
        treatments: const [
          'رش مبيدات عند تجاوز الحد الاقتصادي (5-10 عث/ورقة) مع تكرار كل 7-10 أيام.',
          'زيوت معدنية أو صابونيات للاختناق.',
        ],
        medicines: const ['استشر متخصصاً زراعياً للحصول على المبيدات المعتمدة.'],
        advice: const [
          'تدمير القمح المتطوع والحشائش قبل الزراعة بـ 3 أسابيع.',
          'زراعة متأخرة ودورة مع خضروات.',
          'إطلاق أعداء طبيعيين مثل الدعسوقة.',
        ],
      ),

      // ═══════════════════════════════════════════
      // ✅ 4 MALADIES AJOUTÉES (manquaient dans .dart)
      // ═══════════════════════════════════════════

      'healthy': DiseaseData(
        name: 'Healthy',
        iconPath: 'assets/icons/healthy.png',
        symptoms: const [
          'No disease symptoms detected.',
        ],
        treatments: const [],
        medicines: const [],
        advice: const [
          'Continue regular monitoring.',
          'Maintain good irrigation practices.',
        ],
      ),

      // ─────────────────────────────────────────
      'smut': DiseaseData(
        name: 'Smut',
        iconPath: 'assets/icons/aphid.png',
        symptoms: const [
          'Masses of powdery black spores replacing grain kernels.',
          'Infected plants may show stunted growth.',
          'Soot-like black layer on spikes and seeds.',
        ],
        treatments: const [
          'Use certified disease-free seeds.',
          'Apply fungicide seed treatments before planting.',
          'Remove and destroy infected plant material.',
        ],
        medicines: const [
          'Consult a local agricultural specialist for registered fungicides.',
        ],
        advice: const [
          'Rotate crops to break the disease cycle.',
          'Avoid planting in fields with a history of smut.',
          'Regularly monitor fields and remove infected plants early.',
        ],
      ),

      // ─────────────────────────────────────────
      'stem fly': DiseaseData(
        name: 'Stem fly',
        iconPath: 'assets/icons/aphid.png',
        symptoms: const [
          'Young leaves turn yellow and wilt (dead heart symptoms).',
          'Larvae tunnel inside the stem causing internal damage.',
          'Infected tillers die before heading.',
        ],
        treatments: const [
          'Apply insecticides during early tillering stage.',
          'Use systemic insecticides for effective control.',
          'Remove and destroy damaged tillers immediately.',
        ],
        medicines: const [
          'Consult a local agricultural specialist for registered insecticides.',
        ],
        advice: const [
          'Early sowing to avoid peak fly population periods.',
          'Avoid late sowing which increases susceptibility.',
          'Regularly monitor crops for early detection.',
        ],
      ),

      // ─────────────────────────────────────────
      'tan spot': DiseaseData(
        name: 'Tan spot',
        iconPath: 'assets/icons/aphid.png',
        symptoms: const [
          'Tan to brown oval lesions with a yellow halo on leaves.',
          'Lesions may coalesce causing large dead areas on leaves.',
          'Severe infections reduce photosynthesis and yield.',
        ],
        treatments: const [
          'Apply foliar fungicides at first signs of infection.',
          'Use resistant varieties if available.',
          'Remove crop residues after harvest to reduce infection source.',
        ],
        medicines: const [
          'Consult a local agricultural specialist for registered fungicides.',
        ],
        advice: const [
          'Rotate crops to reduce soil infection sources.',
          'Avoid excessive irrigation that promotes leaf wetness.',
          'Monitor fields regularly especially in humid conditions.',
        ],
      ),
    };

    await _diseaseBox!.putAll(diseases);
  }
}
