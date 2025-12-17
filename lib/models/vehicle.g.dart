// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 0;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      id: fields[0] as int?,
      model: fields[1] as String,
      year: fields[2] as int,
      plate: fields[3] as String?,
      currentMileage: fields[4] as double,
      marketValue: fields[5] as double?,
      lastFipeUpdate: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.model)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.plate)
      ..writeByte(4)
      ..write(obj.currentMileage)
      ..writeByte(5)
      ..write(obj.marketValue)
      ..writeByte(6)
      ..write(obj.lastFipeUpdate);
  }
}