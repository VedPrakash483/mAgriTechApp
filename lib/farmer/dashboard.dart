import 'package:e_agritech_app/farmer/add_problem_page.dart';
import 'package:e_agritech_app/farmer/problem_detail_screen.dart';
import 'package:e_agritech_app/models/problem_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_agritech_app/models/user_model.dart'; // Import UserModel

class HomePageFarmer extends StatefulWidget {
  const HomePageFarmer({super.key});

  @override
  _HomePageFarmerState createState() => _HomePageFarmerState();
}

class _HomePageFarmerState extends State<HomePageFarmer> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String farmerId;
  UserModel? userModel;  // Nullable UserModel instance

  @override
  void initState() {
    super.initState();
    _initializeFarmerId();
  }

  Future<void> _initializeFarmerId() async {
    // Get the authenticated user's UID
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        farmerId = currentUser.uid;
      });
      // Fetch the user data after setting the farmerId
      await _fetchUserModel(farmerId);
    } else {
      farmerId = '';
    }
  }

  Future<void> _fetchUserModel(String uid) async {
    try {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // Convert document data to UserModel
        setState(() {
          userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: AppBar(
      title: const Text('Farmer Dashboard', style: TextStyle(fontSize: 22)),
      elevation: 2,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF66BB6A),
              Color(0xFF43A047)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ),
    body: farmerId.isEmpty || userModel == null
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('problems')
                .where('farmerId', isEqualTo: farmerId)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
 if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                print("No problems found for farmerId: $farmerId"); // Debugging: No problems found
                return const Center(
                    child: Text('No problems found',
                        style: TextStyle(fontSize: 16, color: Colors.grey)));
              }

              List<ProblemModel> problems = snapshot.data!.docs
                  .map((doc) => ProblemModel.fromMap(
                      doc.data() as Map<String, dynamic>))
                  .toList();

              return Column(
                children: [
                  _buildSummaryCards(problems),
                  Expanded(child: _buildProblemsList(problems)),
                ],
              );
            },
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        if (userModel != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddProblemScreen(
                      farmerId: farmerId,
                      userModel: userModel!,
                    )),
          );
        }
      },
      backgroundColor: const Color(0xFF388E3C),
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );
}

  Widget _buildSummaryCards(List<ProblemModel> problems) {
    int completed = problems.where((p) => p.status == 'completed').length;
    int ongoing = problems.where((p) => p.status == 'ongoing').length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildAnimatedSummaryCard(
              'Completed', completed, const Color(0xFF66BB6A)),
          const SizedBox(width: 16),
          _buildAnimatedSummaryCard(
              'Ongoing', ongoing, const Color(0xFFFFA726)),
        ],
      ),
    );
  }

  Widget _buildAnimatedSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Inside your HomePageFarmer class
  Widget _buildProblemsList(List<ProblemModel> problems) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: problems.length,
      itemBuilder: (context, index) {
        final problem = problems[index];
        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Hero(
              tag: 'problem_${problem}',
              child: Icon(
                problem.status == 'completed'
                    ? Icons.check_circle
                    : Icons.pending,
                color: problem.status == 'completed'
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
            title: Text(
              problem.assistanceType,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  problem.description,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    // Uncomment if you want to show location
                    // Text(
                    //   problem.location,
                    //   style: TextStyle(color: Colors.grey[600]),
                    // ),
                  ],
                ),
              ],
            ),
            trailing: Chip(
              label: Text(
                problem.categoryTag,
                style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
              ),
              backgroundColor: const Color(0xFFE8F5E9),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProblemDetailScreen(problem: problem),
                ),
              );
            },
          ),
        );
      },
    );
  }
}