import 'package:hive_flutter/hive_flutter.dart';
import '../models/detection_history.dart';

class HistoryDatabase {
  static const String _boxName = 'detection_history';
  static Box<DetectionHistory>? _historyBox;  // ✅ Make nullable for safety check

  /// Initialize Hive box for history
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DetectionHistoryAdapter());
    }
    _historyBox = await Hive.openBox<DetectionHistory>(_boxName);
  }

  /// ✅ Helper: Ensure box is initialized before use (prevents LateInitializationError)
  static Box<DetectionHistory> get _box {
    if (_historyBox == null) {
      throw StateError(
        'HistoryDatabase not initialized. '
            'Call HistoryDatabase.init() in main.dart before using.',
      );
    }
    return _historyBox!;
  }

  /// ✅ Save detection with userId (data isolation)
  static Future<void> saveDetection(DetectionHistory detection) async {
    await _box.put(detection.id, detection);
  }

  /// ✅ Get history for SPECIFIC USER ONLY (data isolation)
  static List<DetectionHistory> getUserHistory(String userId) {
    final allItems = _box.values.toList();
    // ✅ FILTER: Only return items belonging to this user
    final userItems = allItems
        .where((item) => item.userId == userId)
        .toList();
    // Sort by date (newest first)
    userItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return userItems;
  }

  /// ✅ Get recent history for specific user
  static List<DetectionHistory> getUserRecentHistory({
    required String userId,
    int limit = 5,
  }) {
    return getUserHistory(userId).take(limit).toList();
  }

  /// ✅ Delete a history item (with ownership check)
  static Future<bool> deleteHistory(String id, String userId) async {
    final item = _box.get(id);
    // ✅ Security: Only allow user to delete their own items
    if (item == null || item.userId != userId) {
      return false;
    }
    await _box.delete(id);
    return true;
  }

  /// ✅ Clear history for specific user
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

  /// Get count of history items for specific user
  static int getUserHistoryCount(String userId) {
    return _box.values
        .where((item) => item.userId == userId)
        .length;
  }

  /// Stream for real-time updates
  static Stream<BoxEvent> get historyStream => _box.watch();

  /// Check if database is initialized (for debugging)
  static bool get isInitialized => _historyBox != null;
}