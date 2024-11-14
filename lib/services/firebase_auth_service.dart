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
      notifyListeners(); // Notify listeners after successful registration
      return userCredential.user; // Return the User object to indicate success
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      print("General Registration Error: $e");
      return null; // Return null if an unexpected error occurs
    }
  }

  // Login user with detailed error messages
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred.');
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

  // Handle FirebaseAuthException and return a user-friendly message
  User? _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        throw Exception('Email already exists.');
      case 'invalid-email':
        throw Exception('Invalid email format.');
      case 'weak-password':
        throw Exception('Password is too weak.');
      default:
        throw Exception('Registration failed. Please try again.');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // Update user profile
  Future<void> updateProfile({
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
      await _auth.currentUser?.updateDisplayName(name);
      await _auth.currentUser?.updatePhotoURL('');

      UserModel userModel = UserModel(
        uid: _auth.currentUser?.uid ?? '',
        email: _auth.currentUser?.email ?? '',
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
      notifyListeners(); // Notify listeners after a successful profile update
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // Delete user account
  Future<void> deleteUser() async {
    try {
      await _auth.currentUser?.delete();
      notifyListeners(); // Notify listeners after successful deletion
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // Send verification email
  Future<void> sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // Check if email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }
}