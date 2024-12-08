import 'package:assignment1/src/screens/registrationListPage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:assignment1/src/screens/registration_screen.dart';  // Import your RegistrationPage

import '../data/user_model.dart'; // Import your RegistrationData model

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Reference to the local Hive box
  late Box<RegistrationData> registrationBox;

  @override
  void initState() {
    super.initState();
    // Open the Hive box if it's not already open
    _openHiveBox();
  }

  // Function to open the Hive box
  Future<void> _openHiveBox() async {
    // Check if the box is already open
    if (!Hive.isBoxOpen('registrationBox')) {
      registrationBox = await Hive.openBox<RegistrationData>('registrationBox');
    } else {
      registrationBox = Hive.box<RegistrationData>('registrationBox');
    }
  }

  // Function to handle login
  void _login() async {
    // Wait for the Hive box to be opened before proceeding
    await _openHiveBox();

    if (_formKey.currentState?.validate() ?? false) {
      // Check if local data is available
      var allRegistrations = registrationBox.values.toList();

      if (allRegistrations.isEmpty) {
        // No local data available, show an alert
        _showAlert('No registration data available. Please register first.');
        return;
      }

      // Compare the entered credentials with the stored data
      for (var registration in allRegistrations) {
        if (registration.email == emailController.text &&
            registration.password == passwordController.text) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegistrationListPage()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged in successfully!')),
          );
          // Navigate to the next screen (e.g., Home Page)
          return;
        }
      }

      // If no match is found, show an alert
      _showAlert('Invalid email or password. Please try again.');
    }
  }

  // Show alert dialog
  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Failed'),
          content: Text(message),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(child: Text('Login')),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Email ID field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email ID'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  } else if (!RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Password field
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
              SizedBox(height: 20),
              // Login Button
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              SizedBox(height: 20),
              // Option to navigate to Registration Page (optional)
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Don't have an account? ",
                      ),
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to RegistrationPage when Sign Up is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegistrationPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
