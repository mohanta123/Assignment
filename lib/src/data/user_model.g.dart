// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RegistrationDataAdapter extends TypeAdapter<RegistrationData> {
  @override
  final int typeId = 0;

  @override
  RegistrationData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RegistrationData(
      firstName: fields[0] as String,
      lastName: fields[1] as String,
      contactNo: fields[2] as String,
      email: fields[3] as String,
      password: fields[4] as String,
      address: fields[5] as String,
      image: fields[6] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, RegistrationData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.firstName)
      ..writeByte(1)
      ..write(obj.lastName)
      ..writeByte(2)
      ..write(obj.contactNo)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegistrationDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
