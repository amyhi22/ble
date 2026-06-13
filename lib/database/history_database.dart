import 'package:hive_flutter/hive_flutter.dart';
import '../models/detection_history.dart';

class HistoryDatabase {
  static const String _boxName = 'detection_history';
  static Box<DetectionHistory>? _historyBox;

  /// Initialize Hive box for history
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DetectionHistoryAdapter());
    }
    _historyBox = await Hive.openBox<DetectionHistory>(_boxName);
  }

  /// Ensure box is initialized before use
  static Box<DetectionHistory> get _box {
    if (_historyBox == null) {
      throw StateError(
        'HistoryDatabase not initialized. '
            'Call HistoryDatabase.init() in main.dart before using.',
      );
    }
    return _historyBox!;
  }

  /// Save detection with userId
  static Future<void> saveDetection(DetectionHistory detection) async {
    await _box.put(detection.id, detection);
  }

  /// Prevent duplicate saves for the same disease on the same day
  static bool alreadyExistsToday({
    required String userId,
    required String diseaseName,
  }) {
    final now = DateTime.now();

    return _box.values.any((item) {
      return item.userId == userId &&
          item.diseaseName.toLowerCase() == diseaseName.toLowerCase() &&
          item.timestamp.year == now.year &&
          item.timestamp.month == now.month &&
          item.timestamp.day == now.day;
    });
  }

  /// Get history for a specific user only
  static List<DetectionHistory> getUserHistory(String userId) {
    final allItems = _box.values.toList();

    final userItems = allItems
        .where((item) => item.userId == userId)
        .toList();

    userItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return userItems;
  }

  /// Get recent history for a specific user
  static List<DetectionHistory> getUserRecentHistory({
    required String userId,
    int limit = 5,
  }) {
    return getUserHistory(userId).take(limit).toList();
  }

  /// Delete a history item (ownership check)
  static Future<bool> deleteHistory(
      String id,
      String userId,
      ) async {
    final item = _box.get(id);

    if (item == null || item.userId != userId) {
      return false;
    }

    await _box.delete(id);
    return true;
  }

  /// Clear history for a specific user
  static Future<void> clearUserHistory(String userId) async {
    final keysToDelete = _box.values
        .where((item) => item.userId == userId)
        .map((item) => item.id)
        .toList();

    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }

  /// Check if user has any history
  static bool userHasHistory(String userId) {
    return _box.values.any((item) => item.userId == userId);
  }

  /// Get count of history items for a specific user
  static int getUserHistoryCount(String userId) {
    return _box.values
        .where((item) => item.userId == userId)
        .length;
  }

  /// Stream for real-time updates
  static Stream<BoxEvent> get historyStream => _box.watch();

  /// Check if database is initialized
  static bool get isInitialized => _historyBox != null;
}