import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_agritech_app/farmer/dashboard.dart';
import 'package:e_agritech_app/screens/welcome_screen.dart';
import 'package:e_agritech_app/services/firebase_auth_service.dart';
import 'package:e_agritech_app/student/home_page_student.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  Future<String?> _getUserType(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.get('userType') as String?;
      }
    } catch (e) {
      debugPrint("Error fetching userType: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseAuthService>(
      builder: (context, auth, child) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              User? user = snapshot.data;
              if (user == null) {
                return WelcomeScreen();
              } else {
                return FutureBuilder<String?>(
                  future: _getUserType(user.uid),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.done) {
                      if (userSnapshot.hasData) {
                        final userType = userSnapshot.data;
                        if (userType == "Farmer") {
                          return HomePageFarmer();
                        } else if (userType == "Student") {
                          return HomePageStudent();
                        } else {
                          return WelcomeScreen();
                        }
                      } else if (userSnapshot.hasError) {
                        return Center(child: Text("Error loading profile"));
                      } else {
                        return WelcomeScreen();
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}
