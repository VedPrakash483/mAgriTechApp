import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/user_model.dart';
import '/models/problem_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save initial user information to Firestore upon registration
  Future<void> saveUserInfo({
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
    UserModel userModel = UserModel(
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

    await _firestore.collection('users').doc(uid).set(userModel.toMap());
    print("User info saved successfully for $email");
  }

  // Save problem posted by farmer
  Future<void> addProblem({
    required String farmerId,
    required String assistanceType, // Medical or Farm
    required String description,
    String? audioUrl,
    String? imageUrl,
    required String categoryTag,
    required String location,
  }) async {
    ProblemModel problem = ProblemModel(
      farmerId: farmerId,
      assistanceType: assistanceType,
      description: description,
      audioUrl: audioUrl,
      imageUrl: imageUrl,
      categoryTag: categoryTag,
      location: location,
      status: 'Ongoing',
      timestamp: Timestamp.now(),
    );

    await _firestore.collection('problems').add(problem.toMap());
    print("Problem added by farmer $farmerId with category $categoryTag");
  }

  // Get all problems for students to view and filter
  Future<List<ProblemModel>> getProblems() async {
    QuerySnapshot snapshot = await _firestore.collection('problems').get();
    return snapshot.docs.map((doc) => ProblemModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}
