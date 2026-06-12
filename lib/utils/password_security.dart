import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Secure password hashing using SHA-256 with salt
///
/// ⚠️ For production: Consider using bcrypt via `bcrypt` package
/// This implementation provides strong security for local storage
class PasswordSecurity {
  /// Generate cryptographically secure random salt (32 bytes)
  static String generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Hash password with salt using SHA-256
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify password against stored hash
  static bool verifyPassword(String password, String salt, String storedHash) {
    final computedHash = hashPassword(password, salt);
    return computedHash == storedHash;
  }

  /// Create secure password record (hash + salt)
  static Map<String, String> createPasswordRecord(String password) {
    final salt = generateSalt();
    final hash = hashPassword(password, salt);
    return {'hash': hash, 'salt': salt};
  }
}