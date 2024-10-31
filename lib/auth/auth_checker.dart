import 'package:e_agritech_app/farmer/dashboard.dart';
import 'package:e_agritech_app/screens/welcome_screen.dart';
import 'package:e_agritech_app/services/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_agritech_app/student/home_page_student.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

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
                // comments by asadalpha
                // Fetch userType from Firestore
                /// using [ FutureBuilder ] for getting one snapshot ------
                // then seeing into users collection for userType

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.done) {
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        var userType = userSnapshot.data!.get('userType');
                        if (userType == "Farmer") {
                          return HomePageFarmer();
                        } else if (userType == "Student") {
                          return HomePageStudent();
                        } else {
                          return WelcomeScreen();
                        }
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
              return Center(
                  child: CircularProgressIndicator()); // Loading auth state
            }
          },
        );
      },
    );
  }
}
