import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'detection_history.g.dart';

@HiveType(typeId: 1)  // ✅ Keep your existing typeId
class DetectionHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)  // ✅ ADD THIS: Link to specific user
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

  DetectionHistory({
    String? id,
    required this.userId,  // ✅ REQUIRED: Must pass userId
    required this.diseaseName,
    required this.confidence,
    required this.symptoms,
    required this.treatments,
    required this.medicines,
    DateTime? timestamp,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  // Formatted date for UI
  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // ✅ Factory: Create from treatment data + current user
  factory DetectionHistory.fromTreatmentData({
    required String userId,  // ✅ Pass current user's ID
    required String diseaseName,
    required double confidence,
    required List<String> symptoms,
    required List<String> treatments,
    required List<String> medicines,
    String? notes,
  }) {
    return DetectionHistory(
      userId: userId,  // ✅ Link to user
      diseaseName: diseaseName,
      confidence: confidence,
      symptoms: symptoms,
      treatments: treatments,
      medicines: medicines,
      notes: notes,
    );
  }
}