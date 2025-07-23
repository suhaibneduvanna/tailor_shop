// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garment_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GarmentTypeAdapter extends TypeAdapter<GarmentType> {
  @override
  final int typeId = 0;

  @override
  GarmentType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GarmentType(
      id: fields[0] as String,
      name: fields[1] as String,
      measurements: (fields[2] as List).cast<String>(),
      basePrice: fields[3] as double,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GarmentType obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.measurements)
      ..writeByte(3)
      ..write(obj.basePrice)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GarmentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
