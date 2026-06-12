import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_model.g.dart';  // ✅ CRITICAL: Links to generated adapter

@HiveType(typeId: 2)
class UserModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String hashedPassword;

  @HiveField(4)
  final String salt;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime? lastLogin;

  UserModel({
    String? userId,
    required this.username,
    required this.email,
    required this.hashedPassword,
    required this.salt,
    DateTime? createdAt,
    this.lastLogin,
  })  : userId = userId ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // ✅ ADD THIS METHOD (fixes copyWithLastLogin error)
  UserModel copyWithLastLogin() {
    return UserModel(
      userId: userId,
      username: username,
      email: email,
      hashedPassword: hashedPassword,
      salt: salt,
      createdAt: createdAt,
      lastLogin: DateTime.now(),
    );
  }

  Map<String, dynamic> toSafeMap() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}