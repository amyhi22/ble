import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_scan_history.dart';

class UserScanHistoryDatabase {
  static const String _boxName = 'user_scan_history';
  static late Box<UserScanHistory> _historyBox;

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(UserScanHistoryAdapter());
    }
    _historyBox = await Hive.openBox<UserScanHistory>(_boxName);
  }

  static Future<void> saveScan(UserScanHistory scan) async {
    await _historyBox.put(scan.id, scan);
  }

  static List<UserScanHistory> getUserHistory(String userId) {
    final allItems = _historyBox.values.toList();
    final userItems = allItems
        .where((item) => item.userId == userId)
        .toList();
    userItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return userItems;
  }

  static List<UserScanHistory> getUserRecentHistory({
    required String userId,
    int limit = 5,
  }) {
    return getUserHistory(userId).take(limit).toList();
  }

  /// ✅ FIX: Method signature matches the call in home_screen.dart
  static Future<bool> deleteScan({
    required String id,      // ✅ Named parameter 'id'
    required String userId,  // ✅ Named parameter 'userId'
  }) async {
    final item = _historyBox.get(id);
    // ✅ Security: Only allow user to delete their own items
    if (item == null || item.userId != userId) {
      return false;
    }
    await _historyBox.delete(id);
    return true;
  }

  static Future<void> clearUserHistory(String userId) async {
    final keysToDelete = _historyBox.values
        .where((item) => item.userId == userId)
        .map((item) => item.id)
        .toList();

    for (final key in keysToDelete) {
      await _historyBox.delete(key);
    }
  }

  static bool userHasHistory(String userId) {
    return _historyBox.values.any((item) => item.userId == userId);
  }

  static int getUserHistoryCount(String userId) {
    return _historyBox.values
        .where((item) => item.userId == userId)
        .length;
  }

  static Stream<BoxEvent> get historyStream => _historyBox.watch();
}