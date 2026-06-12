import 'package:hive_flutter/hive_flutter.dart';
import 'hive_service.dart';

class SessionService {
  static const String _currentUserIdKey = 'current_user_id';
  static const String _loginAttemptsKey = 'login_attempts';
  static const String _lockUntilKey = 'lock_until';

  static const int maxLoginAttempts = 5;
  static const Duration lockDuration = Duration(minutes: 15);

  /// Check if user is logged in
  static bool get isLoggedIn {
    final box = HiveService.getBox<String>(HiveService.sessionBoxName);
    return box.get(_currentUserIdKey) != null;
  }

  /// Get current user ID (null if not logged in)
  static String? get currentUserId {
    final box = HiveService.getBox<String>(HiveService.sessionBoxName);
    return box.get(_currentUserIdKey);
  }

  /// Login: store user ID in session
  static Future<void> login(String userId) async {
    final box = HiveService.getBox<String>(HiveService.sessionBoxName);
    await box.put(_currentUserIdKey, userId);
    await _resetLoginAttempts();
  }

  /// Logout: clear session
  static Future<void> logout() async {
    final box = HiveService.getBox<String>(HiveService.sessionBoxName);
    await box.delete(_currentUserIdKey);
    await _resetLoginAttempts();
  }

  /// Clear all session data
  static Future<void> clearSession() async {
    final box = HiveService.getBox<String>(HiveService.sessionBoxName);
    await box.clear();
  }

  // ✅ Brute-force protection

  /// Record failed login attempt
  static Future<void> recordFailedAttempt() async {
    final box = HiveService.getBox<String>(HiveService.sessionBoxName);
    final attempts = (box.get(_loginAttemptsKey) ?? '0');
    final count = int.tryParse(attempts) ?? 0;

    if (count + 1 >= maxLoginAttempts) {
      // Lock account temporarily
      final lockUntil = DateTime.now().add(lockDuration).millisecondsSinceEpoch;
      await box.put(_lockUntilKey, lockUntil.toString());
    }

    await box.put(_loginAttemptsKey, (count + 1).toString());
  }

  /// Check if login is locked
  static bool get isLoginLocked {
    final box = HiveService.getBox<String>(HiveService.sessionBoxName);
    final lockUntilStr = box.get(_lockUntilKey);
    if (lockUntilStr == null) return false;

    final lockUntil = DateTime.fromMillisecondsSinceEpoch(int.parse(lockUntilStr));
    if (DateTime.now().isAfter(lockUntil)) {
      // Lock expired, reset
      box.delete(_lockUntilKey);
      box.delete(_loginAttemptsKey);
      return false;
    }
    return true;
  }

  /// Get remaining lock time
  static Duration? get lockRemainingTime {
    if (!isLoginLocked) return null;
    final box = HiveService.getBox<String>(HiveService.sessionBoxName);
    final lockUntilStr = box.get(_lockUntilKey);
    if (lockUntilStr == null) return null;

    final lockUntil = DateTime.fromMillisecondsSinceEpoch(int.parse(lockUntilStr));
    final remaining = lockUntil.difference(DateTime.now());
    return remaining > Duration.zero ? remaining : null;
  }

  /// Reset login attempts (called on successful login)
  static Future<void> _resetLoginAttempts() async {
    final box = HiveService.getBox<String>(HiveService.sessionBoxName);
    await box.delete(_loginAttemptsKey);
    await box.delete(_lockUntilKey);
  }

  /// Get current attempt count (for UI feedback)
  static int get loginAttempts {
    final box = HiveService.getBox<String>(HiveService.sessionBoxName);
    return int.tryParse(box.get(_loginAttemptsKey) ?? '0') ?? 0;
  }
}