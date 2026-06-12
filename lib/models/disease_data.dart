import 'package:hive/hive.dart';

part 'disease_data.g.dart';

@HiveType(typeId: 0)
class DiseaseData extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<String> symptoms;

  @HiveField(2)
  final List<String> treatments;

  @HiveField(3)
  final List<String> medicines;

  @HiveField(4)
  final List<String> advice;

  @HiveField(5)
  final String iconPath;

  DiseaseData({
    required this.name,
    required this.symptoms,
    required this.treatments,
    required this.medicines,
    required this.advice,
    required this.iconPath,
  });
}