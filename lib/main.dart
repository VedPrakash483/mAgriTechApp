import 'package:e_agritech_app/farmer/dashboard.dart';
import 'package:e_agritech_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'services/firebase_auth_service.dart'; // Make sure this is correct
import 'providers/auth_provider.dart'; // Import your auth provider if you have one

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DefaultFirebaseOptions.currentPlatform;
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseAuthService()), // Ensure this is correct
        // Add other providers as needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-MediFarmTech',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}
