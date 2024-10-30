import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registers a user based on role (Student/Farmer)
  Future<User?> registerUser({
    required String email,
    required String password,
    required String name,
    required String userType, // 'Student' or 'Farmer'
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

      await UserService().saveUserInfo(
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

      print("Registration successful for user: ${userCredential.user?.email} as $userType");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Registration Error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("Registration Error: $e");
      return null;
    }
  }

  // Simple login method
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Login Error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // Signs out the user
  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
      print("User signed out successfully");
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }
}
