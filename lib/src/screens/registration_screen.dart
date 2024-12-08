import 'dart:io';
import 'dart:typed_data';
import 'package:assignment1/src/screens/registrationListPage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/user_model.dart';
import 'login_screen.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController contactNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String stAddress = '';
  bool showText = false;
  File? _image;

  /// Image Picker
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    PermissionStatus cameraPermission = await Permission.camera.request();
    PermissionStatus storagePermission = await Permission.storage.request();

    if (cameraPermission.isGranted && storagePermission.isGranted) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera and storage permissions are required')),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getLocation() async {
    var status = await Permission.location.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission is required')),
      );
      return;
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await _convertCoordinatesToAddress(position.latitude, position.longitude);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> _convertCoordinatesToAddress(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark first = placemarks.first;

        setState(() {
          stAddress =
          "${first.street}, ${first.subLocality}, ${first.locality}, ${first.administrativeArea}, ${first.postalCode}";
          addressController.text = stAddress; // Update address field
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error converting coordinates to address: $e')),
      );
    }
  }

  late Box<RegistrationData> registrationBox;

  @override
  void initState() {
    super.initState();
    _openHiveBox();
  }

  Future<void> _openHiveBox() async {
    registrationBox = await Hive.openBox<RegistrationData>('registrationBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // User Image Picker
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!) as ImageProvider
                      : AssetImage('assets/placeholder.png'),
                  child: _image == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(height: 20),

              // First Name
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),

              // Last Name
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),

              // Contact No
              TextFormField(
                controller: contactNoController,
                decoration: InputDecoration(labelText: 'Contact No'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
              ),

              // Email
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email ID'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  } else if (!RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              // Password
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),

              // Confirm Password
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),

              // Address Field with Location Fetch Icon
              Row(
                children: [
                  InkWell(
                    onTap: _getLocation,
                    child: Icon(
                      Icons.location_on_outlined,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'User Address',
                        hintText: 'Enter or fetch your address',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Check for duplicates before saving
                    bool isDuplicate = await _checkForDuplicates();

                    if (isDuplicate) {
                      // Set an appropriate error message if duplicate data is found
                      errorMessage = 'Email, Contact No, or Password already exists. Please enter a unique value.';

                      // Show an alert if duplicate data is found
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Duplicate Data Found'),
                            content: Text(errorMessage ?? ''),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Proceed with saving the data if no duplicates
                      Uint8List? imageBytes = _image != null ? await _image!.readAsBytes() : null;

                      final newRegistration = RegistrationData(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        contactNo: contactNoController.text,
                        email: emailController.text,
                        password: passwordController.text,
                        address: addressController.text,
                        image: imageBytes,
                      );

                      // Add to Hive box
                      await registrationBox.add(newRegistration);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Registration successful')),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }
                  }
                },
                child: Text('Register'),
              ),



            ],
          ),
        ),
      ),
    );
  }
  String? errorMessage;
  bool _isDuplicateRegistration(String email, String contactNo, String password) {
    for (var registration in registrationBox.values) {
      if (registration.email == email) {
        return true; // Duplicate email found
      }
      if (registration.contactNo == contactNo) {
        return true; // Duplicate contact number found
      }
      if (registration.password == password) {
        return true; // Duplicate password found
      }
    }
    return false;
  }
  Future<bool> _checkForDuplicates() async {
    var allRegistrations = registrationBox.values.toList();

    for (var registration in allRegistrations) {
      if (registration.email == emailController.text ||
          registration.contactNo == contactNoController.text ||
          registration.password == passwordController.text) {
        return true; // Duplicate found
      }
    }
    return false; // No duplicates found
  }
}
