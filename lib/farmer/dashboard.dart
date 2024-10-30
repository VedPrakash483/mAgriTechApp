import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_agritech_app/models/problem_model.dart';
import 'package:e_agritech_app/farmer/add_problem_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String farmerId =
      "current_farmer_id"; // Replace with actual farmer ID logic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        elevation: 0,
        backgroundColor: Colors.teal[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('problems')
            .where('farmerId', isEqualTo: farmerId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(child: CircularProgressIndicator());
          // }

          // if (snapshot.hasError) {
          //   return Center(child: Text('Error: ${snapshot.error}'));
          // }

          List<ProblemModel> problems = snapshot.data!.docs
              .map((doc) =>
                  ProblemModel.fromMap(doc.data() as Map<String, dynamic>))
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
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddProblemScreen(farmerId: farmerId)),
          );
        },
        backgroundColor: Colors.teal[600],
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
          _buildAnimatedSummaryCard('Completed', completed, Colors.green[400]!),
          const SizedBox(width: 16),
          _buildAnimatedSummaryCard('Ongoing', ongoing, Colors.orange[400]!),
        ],
      ),
    );
  }

  Widget _buildAnimatedSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
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

  Widget _buildProblemsList(List<ProblemModel> problems) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: problems.length,
      itemBuilder: (context, index) {
        final problem = problems[index];
        return Card(
          elevation: 4,
          shadowColor: Colors.teal[100],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            title: Text(problem.assistanceType,
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(problem.description,
                    style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    Text(
                      problem.location,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Chip(
              label: Text(problem.categoryTag),
              backgroundColor: Colors.teal[50],
            ),
            onTap: () {
              // Implement navigation with Hero animation
            },
          ),
        );
      },
    );
  }
}
