import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:wifi/new_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: "lib/.env");

  // Initialize Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase initialization failed/skipped: $e");
  }

  // Auto sign in using env credentials
  await _signInToFirebase();

  runApp(const MyApp());
}

Future<void> _signInToFirebase() async {
  try {
    final auth = FirebaseAuth.instance;

    final email = dotenv.env['FIREBASE_EMAIL'];
    final password = dotenv.env['FIREBASE_PASSWORD'];

    if (email == null || email.isEmpty || password == null || password.isEmpty) {
      debugPrint("Missing Firebase credentials in .env");
      return;
    }

    if (auth.currentUser == null) {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint("Signed in as: ${auth.currentUser?.email}");
    } else {
      debugPrint("Already signed in as: ${auth.currentUser?.email}");
    }
  } catch (e) {
    debugPrint("Firebase Auth failed: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Provisioner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const New_Screen(),
    );
  }
}