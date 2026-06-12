// ✅ COMPLETE FIXED lib/services/auth_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

// ✅ ADD ALL REQUIRED IMPORTS
import '../models/user_model.dart';
import '../models/detection_history.dart';  // ✅ For DetectionHistory
import '../database/history_database.dart';  // ✅ For HistoryDatabase
import '../utils/validators.dart';
import 'hive_service.dart';
import 'session_service.dart';  // ✅ For SessionService

class AuthService {  // ✅ Remove 'static' - this is a regular class
  static const String _userBoxName = 'users';

  /// Register new user with secure password hashing
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final usernameError = Validators.validateUsername(username);
    if (usernameError != null) {
      return {'success': false, 'error': usernameError};
    }

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      return {'success': false, 'error': emailError};
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      return {'success': false, 'error': passwordError};
    }

    final confirmError = Validators.validateConfirmPassword(confirmPassword, password);
    if (confirmError != null) {
      return {'success': false, 'error': confirmError};
    }

    try {
      final userBox = Hive.box<UserModel>(_userBoxName);

      UserModel? existingEmail;
      try {
        existingEmail = userBox.values.firstWhere(
              (user) => user.email.toLowerCase() == email.toLowerCase().trim(),
        );
      } catch (e) {
        existingEmail = null;
      }
      if (existingEmail != null) {
        return {'success': false, 'error': 'Email already registered'};
      }

      UserModel? existingUsername;
      try {
        existingUsername = userBox.values.firstWhere(
              (user) => user.username.toLowerCase() == username.toLowerCase().trim(),
        );
      } catch (e) {
        existingUsername = null;
      }
      if (existingUsername != null) {
        return {'success': false, 'error': 'Username already taken'};
      }

      final passwordRecord = _hashPassword(password);

      final user = UserModel(
        username: username.trim(),
        email: email.trim().toLowerCase(),
        hashedPassword: passwordRecord['hash']!,
        salt: passwordRecord['salt']!,
      );

      await userBox.put(user.userId, user);

      return {'success': true, 'userId': user.userId};
    } catch (e) {
      return {'success': false, 'error': 'Registration failed: ${e.toString()}'};
    }
  }

  /// Login with brute-force protection
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (SessionService.isLoginLocked) {
      final remaining = SessionService.lockRemainingTime;
      final minutes = remaining?.inMinutes ?? 0;
      return {
        'success': false,
        'error': 'Too many attempts. Try again in $minutes minute${minutes != 1 ? 's' : ''}.',
        'locked': true,
      };
    }

    try {
      final userBox = Hive.box<UserModel>(_userBoxName);
      final emailLower = email.trim().toLowerCase();

      UserModel? user;
      try {
        user = userBox.values.firstWhere(
              (u) => u.email == emailLower,
        );
      } catch (e) {
        user = null;
      }

      if (user == null) {
        await SessionService.recordFailedAttempt();
        return {
          'success': false,
          'error': 'Invalid email or password',
          'attempts': SessionService.loginAttempts,
        };
      }

      if (!_verifyPassword(password, user.salt, user.hashedPassword)) {
        await SessionService.recordFailedAttempt();
        return {
          'success': false,
          'error': 'Invalid email or password',
          'attempts': SessionService.loginAttempts,
        };
      }

      final updatedUser = user.copyWithLastLogin();
      await userBox.put(user.userId, updatedUser);
      await SessionService.login(user.userId);

      return {
        'success': true,
        'userId': user.userId,
        'username': user.username,
      };
    } catch (e) {
      await SessionService.recordFailedAttempt();
      return {'success': false, 'error': 'Login failed: ${e.toString()}'};
    }
  }

  /// ✅ Save scan history for current user
  static Future<bool> saveScanHistory({
    required String diseaseName,
    required double confidence,
    required List<String> symptoms,
    required List<String> treatments,
    required List<String> medicines,
    String? notes,
  }) async {
    final currentUserId = SessionService.currentUserId;
    if (currentUserId == null) {
      return false;
    }

    try {
      if (!HistoryDatabase.isInitialized) {
        await HistoryDatabase.init();
      }

      final history = DetectionHistory.fromTreatmentData(
        userId: currentUserId,
        diseaseName: diseaseName,
        confidence: confidence,
        symptoms: symptoms,
        treatments: treatments,
        medicines: medicines,
        notes: notes,
      );

      await HistoryDatabase.saveDetection(history);
      return true;
    } catch (e) {
      print('❌ Error saving scan history: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    await SessionService.logout();
  }

  static UserModel? getCurrentUser() {
    final userId = SessionService.currentUserId;
    if (userId == null) return null;
    final userBox = Hive.box<UserModel>(_userBoxName);
    return userBox.get(userId);
  }

  static Future<bool> deleteUser(String userId, String password) async {
    final user = getCurrentUser();
    if (user == null || user.userId != userId) return false;

    if (!_verifyPassword(password, user.salt, user.hashedPassword)) {
      return false;
    }

    await HistoryDatabase.clearUserHistory(userId);
    final userBox = Hive.box<UserModel>(_userBoxName);
    await userBox.delete(userId);
    await SessionService.logout();
    return true;
  }

  // 🔐 Password helpers
  static String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  static String _hashPasswordWithSalt(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Map<String, String> _hashPassword(String password) {
    final salt = _generateSalt();
    final hash = _hashPasswordWithSalt(password, salt);
    return {'hash': hash, 'salt': salt};
  }

  static bool _verifyPassword(String password, String salt, String storedHash) {
    final computedHash = _hashPasswordWithSalt(password, salt);
    return computedHash == storedHash;
  }
}