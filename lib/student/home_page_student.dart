import 'package:e_agritech_app/services/firebase_auth_service.dart';
import 'package:e_agritech_app/services/user_service.dart';
import 'package:e_agritech_app/student/problem_details_screen.dart';
import 'package:e_agritech_app/student/sidebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/models/user_model.dart';
import '/models/problem_model.dart';

class HomePageStudent extends StatefulWidget {
  const HomePageStudent({super.key});

  @override
  State<HomePageStudent> createState() => _HomePageStudentState();
}

class _HomePageStudentState extends State<HomePageStudent> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserService _userService = UserService();

  UserModel? currentUser;
  List<ProblemModel> problems = [];
  bool isLoading = true;
  String? errorMessage;
  @override
  void initState() {
    super.initState();
    fetchUserAndProblems();
  }

  Future<void> fetchUserAndProblems() async {
    try {
      // Get current Firebase user
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) {
        setState(() {
          errorMessage = "No user is currently logged in.";
          isLoading = false;
        });
        return;
      }

      // Fetch user model from Firestore
      final userModel = await _userService.getUserById(firebaseUser.uid);
      if (userModel == null) {
        setState(() {
          errorMessage = "User data not found.";
          isLoading = false;
        });
        return;
      }

      setState(() {
        currentUser = userModel;
      });

      // Fetch all problems from Firestore
      List<ProblemModel> allProblems = await _userService.getProblems();

      // Filter problems based on student's state
      // Filter problems based on student's state and preferred assistance type
      List<ProblemModel> filteredProblems = allProblems.where((problem) {
        // Check if location and state are not null
        if (problem.location == null || userModel.state == null) return false;

        // Match state (case-insensitive)
        bool stateMatch =
            problem.location!.toLowerCase() == userModel.state!.toLowerCase();

        // Optional: Add a preferred assistance type filter if you have it in the user model
        // If not, you can remove this condition or modify as needed
        bool assistanceTypeMatch = problem.assistanceType ==
            userModel.specialization; //userModel.specialization == null ||

        return stateMatch && assistanceTypeMatch;
      }).toList();

      setState(() {
        problems = filteredProblems;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching data: $e";
        isLoading = false;
      });
    }
  }

  void signOut() async {
    try {
      await _authService.signOutUser();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              signOut();
            },
          ),
        ],
      ),
      drawer: currentUser != null ? Sidebar(userModel: currentUser!) : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Column(
                  children: [
                    const FilteredProblemFeed(),
                    Expanded(
                      child: problems.isEmpty
                          ? const Center(
                              child: Text("No problems found for your state"))
                          : ProblemList(problems: problems),
                    ),
                  ],
                ),
    );
  }
}

class FilteredProblemFeed extends StatefulWidget {
  const FilteredProblemFeed({super.key});

  @override
  State<FilteredProblemFeed> createState() => _FilteredProblemFeedState();
}

class _FilteredProblemFeedState extends State<FilteredProblemFeed> {
  String _selectedFilter = 'Proximity';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Filtered Problem Feed",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          _buildAnimatedFilter(),
        ],
      ),
    );
  }

  Widget _buildAnimatedFilter() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: PopupMenuButton<String>(
            initialValue: _selectedFilter,
            onSelected: (String value) {
              setState(() => _selectedFilter = value);
              // Implement filter functionality based on _selectedFilter
            },
            child: Chip(
              avatar: const Icon(Icons.filter_list, size: 20),
              label: Text(_selectedFilter),
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
            itemBuilder: (BuildContext context) {
              return ['Proximity', 'Urgency', 'Category'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        );
      },
    );
  }
}

class ProblemList extends StatelessWidget {
  final List<ProblemModel> problems;

  const ProblemList({super.key, required this.problems});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: problems.length,
      itemBuilder: (context, index) {
        final problem = problems[index];
        return ProblemCard(
          problemData: problem,
          index: index,
        );
      },
    );
  }
}

class ProblemCard extends StatefulWidget {
  final ProblemModel problemData;
  final int index;

  const ProblemCard({
    super.key,
    required this.problemData,
    required this.index,
  });

  @override
  State<ProblemCard> createState() => _ProblemCardState();
}

class _ProblemCardState extends State<ProblemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProblemDetailsScreen(problemData: widget.problemData),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.problemData.categoryTag,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildFavoriteButton(),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6, // Space between chips
                  runSpacing: 4, // Space between rows of chips
                  children: [
                    _buildChip(
                      widget.problemData.assistanceType,
                      Icons.medical_services,
                      Colors.blue,
                    ),
                    _buildChip(
                      widget.problemData.status,
                      Icons.warning,
                      Colors.orange,
                    ),
                    _buildChip(
                      widget.problemData.location ?? 'Unknown',
                      Icons.location_on,
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        setState(() => _isFavorite = !_isFavorite);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isFavorite ? Colors.red.withOpacity(0.1) : Colors.transparent,
        ),
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 12, color: color),
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: color),
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }
}