import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class RegistrationData extends HiveObject {
  @HiveField(0)
  String firstName;

  @HiveField(1)
  String lastName;

  @HiveField(2)
  String contactNo;

  @HiveField(3)
  String email;

  @HiveField(4)
  String password;

  @HiveField(5)
  String address;

  @HiveField(6)
  Uint8List? image;

  RegistrationData({
    required this.firstName,
    required this.lastName,
    required this.contactNo,
    required this.email,
    required this.password,
    required this.address,
    this.image,
  });
}
