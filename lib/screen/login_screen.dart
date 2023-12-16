import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/screen/app_utils.dart';
import 'package:untitled/screen/registration_screen.dart';
import '../widgets/input_field_widgets.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 100,),
              const Text(
                "Login",
                style: TextStyle(
                  color: colorWhite,
                  fontSize: 28.0,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50,),
              InputField(
                controller: emailController,
                icon: Icons.email,
                hintText: "Enter your email",
              ),
              const SizedBox(height: 25,),
              InputField(
                controller: passwordController,
                icon: Icons.lock,
                hintText: "Enter your password",
                obscureText: true,
              ),
              const SizedBox(height: 40,),
              PrimaryButton(
                text: "Login",
                onPressed: () async {
                  if (isValidate()) {
                    try {
                      await _auth.signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      // On successful login, navigate to the home screen
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
                    } on FirebaseAuthException catch (e) {

                      showScaffold(context, e.message ?? "Login failed");
                    } catch (e) {

                      showScaffold(context, "An unexpected error occurred");
                    }
                  }
                },
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: colorWhite,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to registration screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: colorWhite,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidate(){
    if (emailController.text.isEmpty){
      showScaffold(context, "Please enter your email");
      return false;
    }
    if (passwordController.text.isEmpty){
      showScaffold(context, "Please enter your password");
      return false;
    }
    return true;
  }

  void showScaffold(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
