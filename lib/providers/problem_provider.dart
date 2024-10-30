import 'package:flutter/material.dart';
import 'package:e_agritech_app/services/user_service.dart';
import '/models/problem_model.dart';

class ProblemProvider with ChangeNotifier {
  final UserService _userService = UserService();

  Future<List<ProblemModel>> fetchProblems() async {
    return await _userService.getProblems();
  }

  Future<void> createProblem({
    required String farmerId,
    required String assistanceType,
    required String description,
    String? audioUrl,
    String? imageUrl,
    required String categoryTag,
    required String location,
  }) async {
    await _userService.addProblem(
      farmerId: farmerId,
      assistanceType: assistanceType,
      description: description,
      audioUrl: audioUrl,
      imageUrl: imageUrl,
      categoryTag: categoryTag,
      location: location,
    );
    notifyListeners();
  }
}
