import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // Import the uuid package
import '/models/user_model.dart';
import '/models/problem_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save initial user information to Firestore upon registration
  Future<void> saveUserInfo(UserModel userModel) async {
    await _firestore.collection('users').doc(userModel.uid).set(userModel.toMap());
    print("User  info saved successfully for ${userModel.email}");
  }

  // Get user information by UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null; // Return null if user not found
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
    // Generate a unique problemId
    String problemId = Uuid().v4(); // Generate a unique ID

    ProblemModel problem = ProblemModel(
      problemId: problemId, // Pass the generated problemId
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