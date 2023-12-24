import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled/screen/home_screen.dart';
import 'package:untitled/screen/login_screen.dart';
import 'firebase_options.dart';  // Auto-generated file for configuring Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Firebase and catch any errors
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (error) {
    print('Firebase initialization failed: $error');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Check if the snapshot has error
          if (snapshot.hasError) {
            print('Error in auth state changes: ${snapshot.error}');
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }

          // Check connection state
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return LoginScreen();  // User not logged in, show login screen
            }
            return HomeScreen();  // User logged in, show home screen
          }

          // Waiting for connection state to be active
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
