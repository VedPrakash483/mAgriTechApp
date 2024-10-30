import 'package:e_agritech_app/farmer/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-MediFarmTech',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DashboardScreen(),
    );
  }
}

// lib/
// ├── constants/
// │   ├── app_colors.dart
// │   ├── app_texts.dart
// │   └── app_theme.dart
// ├── models/
// │   ├── user.dart
// │   └── problem.dart
// ├── screens/
// │   ├── launch/
// │   │   └── launch_screen.dart
// │   ├── welcome/
// │   │   └── welcome_screen.dart
// │   ├── auth/
// │   │   ├── login_screen.dart
// │   │   └── register_screen.dart
// │   ├── farmer/
// │   │   ├── farmer_home_screen.dart
// │   │   └── add_problem_screen.dart
// │   └── student/
// │       └── student_home_screen.dart
// ├── services/
// │   ├── auth_service.dart
// │   ├── storage_service.dart
// │   └── database_service.dart
// ├── providers/
// │   ├── auth_provider.dart
// │   └── user_provider.dart
// ├── widgets/
// │   ├── common/
// │   │   ├── custom_button.dart
// │   │   └── custom_text_field.dart
// │   ├── farmer/
// │   └── student/
// └── main.dart