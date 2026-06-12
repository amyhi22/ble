// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetectionHistoryAdapter extends TypeAdapter<DetectionHistory> {
  @override
  final int typeId = 1;

  @override
  DetectionHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetectionHistory(
      id: fields[0] as String?,
      userId: fields[1] as String,
      diseaseName: fields[2] as String,
      confidence: fields[3] as double,
      symptoms: (fields[4] as List).cast<String>(),
      treatments: (fields[5] as List).cast<String>(),
      medicines: (fields[6] as List).cast<String>(),
      timestamp: fields[7] as DateTime?,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DetectionHistory obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.diseaseName)
      ..writeByte(3)
      ..write(obj.confidence)
      ..writeByte(4)
      ..write(obj.symptoms)
      ..writeByte(5)
      ..write(obj.treatments)
      ..writeByte(6)
      ..write(obj.medicines)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
