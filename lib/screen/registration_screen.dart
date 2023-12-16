import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/screen/app_utils.dart';
import 'package:untitled/screen/preferences_screen.dart';
import '../widgets/input_field_widgets.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  String genderSelected = "male";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorPrimary, // Make sure this color is defined in your app_utils.dart or similar file
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Jack",
                  style: TextStyle(
                    color: colorWhite, // Make sure this color is defined in your app_utils.dart or similar file
                    fontSize: 28.0,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              const Center(
                child: Text(
                  "Please Enter Information",
                  style: TextStyle(
                    color: colorWhite, // Make sure this color is defined in your app_utils.dart or similar file
                    fontSize: 14.0,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              InputField(
                controller: nameController,
                icon: Icons.person,
                hintText: "Please enter name",
              ),
              const SizedBox(height: 25),
              InputField(
                controller: emailController,
                icon: Icons.email,
                hintText: "Please enter email",
              ),
              const SizedBox(height: 25),
              InputField(
                controller: passwordController,
                icon: Icons.password,
                hintText: "Please enter password",
                obscureText: true,
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 20),
                child: TextFormField(
                  style: const TextStyle(
                    color: colorWhite, // Make sure this color is defined in your app_utils.dart or similar file
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                  controller: birthDateController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.calendar_month,
                      color: colorWhite, // Make sure this color is defined in your app_utils.dart or similar file
                      size: 25.0,
                    ),
                    hintText: "Enter your birthday",
                    hintStyle: TextStyle(
                      color: colorGrey, // Make sure this color is defined in your app_utils.dart or similar file
                      fontSize: 14.0,
                      fontFamily: 'Montserrat',
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorWhite), // Make sure this color is defined in your app_utils.dart or similar file
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorWhite), // Make sure this color is defined in your app_utils.dart or similar file
                    ),
                  ),
                  onTap: () async {
                    DateTime date = DateTime(1900);
                    FocusScope.of(context).requestFocus(FocusNode());
                    date = (await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    ))!;
                    String dateFormatter = date.toIso8601String();
                    DateTime dt = DateTime.parse(dateFormatter);
                    var formatter = DateFormat('dd-MMMM-yyyy');
                    birthDateController.text = formatter.format(dt);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25.0),
                    const Text(
                      "GENDER",
                      style: TextStyle(
                        color: colorWhite, // Make sure this color is defined in your app_utils.dart or similar file
                        letterSpacing: 1,
                        fontSize: 14.0,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            groupValue: genderSelected,
                            activeColor: colorWhite, // Make sure this color is defined in your app_utils.dart or similar file
                            title: const Text(
                              "MALE",
                              style: TextStyle(
                                color: colorWhite, // Make sure this color is defined in your app_utils.dart or similar file
                                fontSize: 14.0,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: 'male',
                            onChanged: (val) {
                              setState(() {
                                genderSelected = val.toString();
                              });
                            },
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            groupValue: genderSelected,
                            activeColor: colorWhite, // Make sure this color is defined in your app_utils.dart or similar file
                            title: const Text(
                              "FEMALE",
                              style: TextStyle(
                                color: colorWhite, // Make sure this color is defined in your app_utils.dart or similar file
                                fontSize: 14.0,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: 'female',
                            onChanged: (val) {
                              setState(() {
                                genderSelected = val.toString();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25.0),
              PrimaryButton(
                text: "Sign Up",
                onPressed: () {
                  if (isValidate()) {
                    navigateToPreferencesScreen(context);
                  }
                },
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: colorWhite, // Make sure this color is defined in your app_utils.dart or similar file
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: colorWhite, // Make sure this color is defined in your app_utils.dart or similar file
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidate() {
    if (nameController.text.isEmpty) {
      showScaffold("Please enter your name");
      return false;
    }
    if (emailController.text.isEmpty) {
      showScaffold("Please enter your email");
      return false;
    }
    if (passwordController.text.isEmpty) {
      showScaffold("Please enter your password");
      return false;
    }
    if (birthDateController.text.isEmpty) {
      showScaffold("Please enter your Birth Date");
      return false;
    }
    return true;
  }

  void navigateToPreferencesScreen(BuildContext context) {
    if (isValidate()) {
      final registrationData = {
        'email': emailController.text,
        'name': nameController.text,
        'password': passwordController.text,
        'birthDate': birthDateController.text,
        'gender': genderSelected,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreferencesScreen(registrationData: registrationData,),
        ),
      );
    }
  }

  void showScaffold(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
