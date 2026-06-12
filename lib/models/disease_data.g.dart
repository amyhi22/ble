// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disease_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiseaseDataAdapter extends TypeAdapter<DiseaseData> {
  @override
  final int typeId = 0;

  @override
  DiseaseData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiseaseData(
      name: fields[0] as String,
      symptoms: (fields[1] as List).cast<String>(),
      treatments: (fields[2] as List).cast<String>(),
      medicines: (fields[3] as List).cast<String>(),
      advice: (fields[4] as List).cast<String>(),
      iconPath: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DiseaseData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.symptoms)
      ..writeByte(2)
      ..write(obj.treatments)
      ..writeByte(3)
      ..write(obj.medicines)
      ..writeByte(4)
      ..write(obj.advice)
      ..writeByte(5)
      ..write(obj.iconPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiseaseDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
