import 'package:hive_flutter/hive_flutter.dart';
import '../models/disease_data.dart';
import '../models/detection_history.dart';
import '../models/user_model.dart';

class HiveService {
  // Box names
  static const String diseaseBoxName = 'diseases';
  static const String historyBoxName = 'detection_history';
  static const String userBoxName = 'users';
  static const String sessionBoxName = 'session';

  /// Initialize Hive and register all adapters
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters with unique typeIds
    _registerAdapter(0, DiseaseDataAdapter());
    _registerAdapter(1, DetectionHistoryAdapter());
    _registerAdapter(2, UserModelAdapter());

    // Open all boxes
    await Hive.openBox<DiseaseData>(diseaseBoxName);
    await Hive.openBox<DetectionHistory>(historyBoxName);
    await Hive.openBox<UserModel>(userBoxName);
    await Hive.openBox<String>(sessionBoxName); // Store current userId
  }

  static void _registerAdapter(int typeId, TypeAdapter adapter) {
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  /// Get box by name (type-safe)
  static Box<T> getBox<T>(String name) => Hive.box<T>(name);

  /// Check if box exists
  static bool hasBox(String name) => Hive.isBoxOpen(name);

  /// Close all boxes (for testing)
  static Future<void> closeAll() async {
    await Hive.close();
  }
}