import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../data/user_model.dart';
import 'login_screen.dart'; // Import your user model file

class RegistrationListPage extends StatefulWidget {
  @override
  _RegistrationListPageState createState() => _RegistrationListPageState();
}

class _RegistrationListPageState extends State<RegistrationListPage> {
  late Box<RegistrationData> registrationBox;

  @override
  void initState() {
    super.initState();
    _openHiveBox();
  }

  // Open the Hive box
  Future<void> _openHiveBox() async {
    registrationBox = await Hive.openBox<RegistrationData>('registrationBox');
    setState(() {});
  }

  // Delete the registration from the Hive box
  void _deleteRegistration(int index) async {
    await registrationBox.deleteAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registration deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registered Users'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Your logout logic here
              // For example, clear the session or navigate to the login screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Logged out successfully!')),
              );
              // Navigate to the login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: registrationBox.listenable(),
        builder: (context, Box<RegistrationData> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No users registered yet.'));
          }
          // Fetching all the data from the Hive box
          var registrations = box.values.toList();

          return ListView.builder(
            itemCount: registrations.length,
            itemBuilder: (context, index) {
              RegistrationData registration = registrations[index];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            if (registration.image != null)
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    image: MemoryImage(registration.image!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            SizedBox(height: 10),
                            Text(
                              'First Name: ${registration.firstName}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Last Name: ${registration.lastName}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Contact No: ${registration.contactNo}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Email: ${registration.email}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Address: ${registration.address}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Password: ${registration.password}',
                              style: TextStyle(fontSize: 16),
                            ),

                          ],
                        ),
                      ),
                      // Delete Icon positioned at the top-right corner
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRegistration(index),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
