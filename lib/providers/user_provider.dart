import 'package:flutter/material.dart';
import 'package:e_agritech_app/services/user_service.dart';
import '/models/user_model.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  Future<void> registerUser({
    required String uid,
    required String email,
    required String name,
    required String userType,
    String? aadhaarNumber,
    String? preferredLanguage,
    String? phone,
    String? location,
    String? state,
    String? specialization,
  }) async {
    // Create a user model instance
    UserModel newUser = UserModel(
      uid: uid,
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

    // Save user info
    await _userService.saveUserInfo(newUser);

    // Notify listeners about the change
    notifyListeners();
  }

  Future<UserModel?> getUser(String uid) async {
    return await _userService.getUserById(uid);
  }
}
