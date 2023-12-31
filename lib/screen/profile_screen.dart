import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  TextEditingController nameController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  String genderSelected = "male"; // You can set the default gender here
  bool isEditing = false; // Track if the user is in editing mode

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with user information
    nameController.text = user?.displayName ?? "";
    // You can similarly initialize birthDateController with user's birthdate
    // and genderSelected with user's gender.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          // Display the "Edit" button only when not in editing mode
          if (!isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
          // Display the "Save" button when in editing mode
          if (isEditing)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                // Save changes here
                updateUserInformation();
                setState(() {
                  isEditing = false;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name:'),
            if (!isEditing)
              Text(
                nameController.text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (isEditing)
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                ),
              ),
            SizedBox(height: 20),
            Text('Email: ${user?.email ?? 'N/A'}'),
            SizedBox(height: 20),
            Text('Birthdate:'),
            if (!isEditing)
              Text(
                birthDateController.text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (isEditing)
              TextFormField(
                controller: birthDateController,
                decoration: InputDecoration(
                  hintText: 'Enter your birthdate',
                ),
              ),
            SizedBox(height: 20),
            Text('Gender:'),
            if (!isEditing)
              Text(
                genderSelected,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (isEditing)
              Row(
                children: [
                  Radio(
                    value: 'male',
                    groupValue: genderSelected,
                    onChanged: (value) {
                      setState(() {
                        genderSelected = value.toString();
                      });
                    },
                  ),
                  Text('Male'),
                  Radio(
                    value: 'female',
                    groupValue: genderSelected,
                    onChanged: (value) {
                      setState(() {
                        genderSelected = value.toString();
                      });
                    },
                  ),
                  Text('Female'),
                ],
              ),
            SizedBox(height: 20),
            // Preferences section
            Text('Preferences:'),
            if (!isEditing)
            // Display user's preferences
              Text(
                user?.metadata?.creationTime.toString() ?? 'N/A',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (isEditing)
            // Allow the user to change preferences here
            // You can use a similar approach as your PreferencesScreen
            // to display and update preferences.
            // You can create a button to open a preferences dialog or screen.
              ElevatedButton(
                onPressed: () {
                  // Implement logic to edit preferences here
                  // For example, open a dialog with checkboxes to edit preferences.
                },
                child: Text('Edit Preferences'),
              ),
          ],
        ),
      ),
    );
  }

  void updateUserInformation() {
    // You can implement the logic to update user information here.
    // Use nameController.text, birthDateController.text, and genderSelected
    // to update the user's profile.

    // For example:
    final updatedName = nameController.text;
    final updatedBirthdate = birthDateController.text;
    final updatedGender = genderSelected;

    // Update the user's profile using Firebase Auth or your preferred method.
    // For Firebase Auth:
    try {
      User? user = FirebaseAuth.instance.currentUser;
      user!.updateProfile(displayName: updatedName);
      // You can update other user information here as needed.
      // Update the user's birthdate and gender in Firestore or your database.

      // After updating, show a success message to the user.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      // Handle errors here
      print('Failed to update profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }
}
