import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Import Flutter Material for ChangeNotifier
import 'user_service.dart';
import '/models/user_model.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<User?> registerUser({
    required String email,
    required String password,
    required String name,
    required String userType,
    String? aadhaarNumber,
    String? preferredLanguage,
    String? phone,
    String? location,
    String? state,
    String? specialization,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel userModel = UserModel(
        uid: userCredential.user?.uid ?? '',
        email: email,
        name: name,
        userType: userType,
        aadhaarNumber: aadhaarNumber,
        preferredLanguage: preferredLanguage,
        phone: phone,
        location: location,
        state: state,
        specialization: specialization,
      );

      await _userService.saveUserInfo(userModel);

      print("Registration successful for user: ${userCredential.user?.email} as $userType");
      notifyListeners(); // Notify listeners after registration
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuth Registration Error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("General Registration Error: $e");
      return null;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners(); // Notify listeners after login
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuth Login Error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("General Login Error: $e");
      return null;
    }
  }

  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
      print("User signed out successfully");
      notifyListeners(); // Notify listeners after sign out
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }
}
