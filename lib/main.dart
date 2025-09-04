import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure you have run `flutterfire configure`
import 'widgets/auth_gate.dart';

// --- HOW TO RUN THIS APP ---
//
// 1. **Firebase Project Setup**:
//    - Go to https://console.firebase.google.com/ and create a new Firebase project.
//    - **Enable Authentication**: Go to 'Build' > 'Authentication', click 'Get started', and enable the 'Email/Password' provider.
//
// 2. **Firestore Database**:
//    - In your Firebase project, navigate to 'Build' > 'Firestore Database'.
//    - Click 'Create database'. Start in **TEST MODE** for now.
//
// 3. **Connect Flutter App to Firebase**:
//    - Install the Firebase CLI and run `flutterfire configure` in your project root.
//    - This command will generate the `lib/firebase_options.dart` file.
//
// 4. **Add Dependencies**:
//    - Ensure your `pubspec.yaml` file includes `firebase_core`, `cloud_firestore`, and `firebase_auth`.
//
// 5. **Seed Initial Data**:
//    - `dart run lib/utils/firestore_seed.dart`
//
// 6. **Run the App**:
//    - `flutter run`
//
// --- HIPAA & Security Note ---
// - For production, you MUST implement stricter Firestore rules. The final step of this plan
//   provides a basic secure rule (`allow read, write: if request.auth != null;`).

Future<void> main() async {
  // Ensure that Flutter bindings are initialized before calling native code.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the generated options file.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SurgeryUnitApp());
}

class SurgeryUnitApp extends StatelessWidget {
  const SurgeryUnitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surgery Unit Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      // Set AuthGate as the entry point of the app.
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
