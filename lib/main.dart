import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/dashboard_screen.dart';
// import 'firebase_options.dart'; // Uncomment this line if you use `flutterfire configure`

// --- HOW TO RUN THIS APP ---
//
// 1. **Firebase Project Setup**:
//    - Go to https://console.firebase.google.com/ and create a new Firebase project.
//
// 2. **Firestore Database**:
//    - In your Firebase project, navigate to 'Build' > 'Firestore Database'.
//    - Click 'Create database'.
//    - Start in **TEST MODE**. This is crucial for the prototype to work without authentication.
//    - Choose a server location.
//
// 3. **Connect Flutter App to Firebase**:
//    - In your Firebase project settings, add a new app for both Android and iOS.
//    - Follow the on-screen instructions to download the configuration files:
//      - For Android: `google-services.json` goes into the `android/app/` directory.
//      - For iOS: `GoogleService-Info.plist` goes into the `ios/Runner/` directory.
//    - The easiest way to do this is by installing the Firebase CLI and running `flutterfire configure`
//      in your project root. This will automatically fetch the config files and generate
//      `lib/firebase_options.dart`.
//
// 4. **Add Dependencies**:
//    - Make sure your `pubspec.yaml` file includes `firebase_core` and `cloud_firestore`.
//      dependencies:
//        flutter:
//          sdk: flutter
//        firebase_core: ^2.24.2
//        cloud_firestore: ^4.14.0
//
// 5. **Seed Initial Data**:
//    - Before running the app, you must populate Firestore with the initial room data.
//    - Open your terminal in the project root and run the following command:
//      `dart run lib/utils/firestore_seed.dart`
//    - This script will create 40 documents in a 'rooms' collection, all set to 'cleaned'.
//
// 6. **Run the App**:
//    - After completing the steps above, you can run the app on an emulator or physical device:
//      `flutter run`
//
// 7. **Testing Real-Time Sync**:
//    - Run the app on two separate devices/emulators.
//    - Make a change on one device (e.g., tap a room, change its status to 'occupied').
//    - Observe the change reflected instantly on the other device's dashboard. The room color
//      on the main grid should update automatically. You can also change data directly in the
//      Firebase Console and watch both apps update.
//
// --- HIPAA & Security Note ---
// - This prototype uses an anonymized `patient_id`. In a real-world scenario, all Patient
//   Health Information (PHI) must be handled with extreme care, following all HIPAA regulations.
// - The Firestore rules are set to test mode (public access). For production, you MUST implement
//   Firebase Authentication and secure your database with proper rules to ensure only authorized
//   staff can access the data.

Future<void> main() async {
  // Ensure that Flutter bindings are initialized before calling native code.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase. This must be done before any Firebase services are used.
  // If you used `flutterfire configure`, you should have a `firebase_options.dart` file.
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // Uncomment this line
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
        // Define a consistent theme for cards and app bar
        cardTheme: CardTheme(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 4,
          shadowColor: Colors.black54,
        ),
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
