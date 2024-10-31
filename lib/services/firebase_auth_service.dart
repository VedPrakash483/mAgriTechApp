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

  // Register user with detailed error messages
  Future<User?> registerUser({
    required String email,
    required String password,
    required String name,
    required String userType,
     String? aadhaarNumber,
    String? preferredLanguage,
    required String? phone,
    String? location,
     String? state,
    required String? specialization,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a new user model with the user data and uid
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

      // Save user information to Firestore
      await _userService.saveUserInfo(userModel);

      notifyListeners(); // Notify listeners after successful registration
      return userCredential.user; // Return the User object to indicate success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw FirebaseAuthException(
              message: 'Email already exists.', code: e.code);
        case 'invalid-email':
          throw FirebaseAuthException(
              message: 'Invalid email format.', code: e.code);
        case 'weak-password':
          throw FirebaseAuthException(
              message: 'Password is too weak.', code: e.code);
        default:
          throw FirebaseAuthException(
              message: 'Registration failed. Please try again.', code: e.code);
      }
    } catch (e) {
      print("General Registration Error: $e");
      return null; // Return null if an unexpected error occurs
    }
  }

  // Login user with detailed error messages
  Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners(); // Notify listeners after successful login
      return null; // Return null to indicate success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-email':
          return 'Invalid email format.';
        default:
          return 'Login failed. Please try again.';
      }
    } catch (e) {
      print("General Login Error: $e");
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign out user with error handling
  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
      notifyListeners(); // Notify listeners after successful sign out
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }
}
