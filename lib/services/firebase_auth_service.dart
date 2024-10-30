import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user_service.dart';
import '/models/user_model.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  FirebaseAuthService() {
    _enablePersistence();
  }

  // Enable user state persistence
  Future<void> _enablePersistence() async {
    await _auth.setPersistence(Persistence.LOCAL);
  }

  // Getter to fetch the current user
  User? get currentUser => _auth.currentUser;

  // Register user
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

  // Login user
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

  // Sign out user
  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
      notifyListeners(); // Notify listeners after sign out
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }
}
