import 'package:e_agritech_app/auth/auth_checker.dart';
import 'package:e_agritech_app/firebase_options.dart';
import 'package:e_agritech_app/screens/registraion_login/student_login.dart';
import 'package:e_agritech_app/screens/user_login_selection.dart';
import 'package:e_agritech_app/student/home_page_student.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/firebase_auth_service.dart';

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
        ChangeNotifierProvider(
            create: (_) => FirebaseAuthService()), // Ensure this is correct
        // Add other providers as needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-MediFarmTech',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        home: const AuthChecker(),
      ),
    );
  }
}
