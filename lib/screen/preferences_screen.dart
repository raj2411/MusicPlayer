import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../widgets/primary_button.dart';
import 'app_utils.dart';
import 'home_screen.dart';

class PreferencesScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const PreferencesScreen({Key? key, required this.registrationData}) : super(key: key);

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {

  final List<String> categories = [
    "Pop",
    "Dance Pop",
    "House",
    "Teen Pop",
    "Electro House",
    "EDM",
    "Pop Rap",
    "Pop Christmas",
    "Pop Rock",
    "R&B",
    "Big Room",
    "Alternative Hip Hop",
    "Urban Contemporary",
    "Progressive Electro House",
    "Indie R&B",
    "Indietronica",
    "Permanent Wave",
    "Synthpop",
    "Contemporary Country",
    "Neo Mellow"
  ];


  final Set<String> selectedCategories = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Preferences'),
        backgroundColor: colorPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categories[index]),
                  trailing: Icon(
                    selectedCategories.contains(categories[index])
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                  onTap: () {
                    setState(() {
                      if (selectedCategories.contains(categories[index])) {
                        selectedCategories.remove(categories[index]);
                      } else {
                        selectedCategories.add(categories[index]);
                      }
                    });
                  },
                );
              },
            ),
          ),
          PrimaryButton(
            text: "Submit Preferences",
              onPressed: () async {
                if (selectedCategories.length >= 3) {
                  String preferences = selectedCategories.join(", ");
                  widget.registrationData['preferences'] = preferences;

                  try {
                    await AuthService().signUp(
                      widget.registrationData['email'],
                      widget.registrationData['password'],
                      widget.registrationData,
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                          (Route<dynamic> route) => false,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Registration error: $e")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select at least 3 preferences")),
                  );
                }
              }

          ),
        ],
      ),
    );
  }
}
