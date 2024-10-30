import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners(); // Notify listeners about the change
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication errors
      throw Exception(e.message);
    } catch (e) {
      // Handle other types of exceptions
      throw Exception('An unknown error occurred.');
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
    notifyListeners(); // Notify listeners about the logout
  }
}
