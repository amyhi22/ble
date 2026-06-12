import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_scan_history.g.dart';  // ✅ Links to generated adapter

@HiveType(typeId: 3)  // ✅ Unique typeId (0=disease, 1=detection_history, 2=user, 3=user_scan_history)
class UserScanHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)  // ✅ CRITICAL: Link to specific user
  final String userId;

  @HiveField(2)
  final String diseaseName;

  @HiveField(3)
  final double confidence;

  @HiveField(4)
  final List<String> symptoms;

  @HiveField(5)
  final List<String> treatments;

  @HiveField(6)
  final List<String> medicines;

  @HiveField(7)
  final DateTime timestamp;

  @HiveField(8)
  final String? notes;

  @HiveField(9)  // ✅ Optional: Store image path if saved
  final String? imagePath;

  UserScanHistory({
    String? id,
    required this.userId,  // ✅ REQUIRED: Must pass userId
    required this.diseaseName,
    required this.confidence,
    required this.symptoms,
    required this.treatments,
    required this.medicines,
    DateTime? timestamp,
    this.notes,
    this.imagePath,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  // ✅ Formatted date for UI display
  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // ✅ Factory: Create from treatment data + current user
  factory UserScanHistory.fromTreatmentData({
    required String userId,  // ✅ Pass current user's ID
    required String diseaseName,
    required double confidence,
    required List<String> symptoms,
    required List<String> treatments,
    required List<String> medicines,
    String? notes,
    String? imagePath,
  }) {
    return UserScanHistory(
      userId: userId,  // ✅ Link to user
      diseaseName: diseaseName,
      confidence: confidence,
      symptoms: symptoms,
      treatments: treatments,
      medicines: medicines,
      notes: notes,
      imagePath: imagePath,
    );
  }

  // ✅ Safe JSON representation (never include sensitive data)
  Map<String, dynamic> toSafeMap() {
    return {
      'id': id,
      'userId': userId,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'symptomCount': symptoms.length,
      'treatmentCount': treatments.length,
    };
  }
}