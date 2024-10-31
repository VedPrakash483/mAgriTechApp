import 'package:e_agritech_app/services/firebase_auth_service.dart';
import 'package:flutter/material.dart';

class HomePageStudent extends StatefulWidget {
  const HomePageStudent({super.key});

  @override
  State<HomePageStudent> createState() => _HomePageStudentState();
}

class _HomePageStudentState extends State<HomePageStudent> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  void signOut() async {
    try {
      await _authService.signOutUser();
    } catch (e) {
      debugPrint("Errot :$e");
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
      drawer: const Sidebar(),
      body: Column(
        children: [
          const FilteredProblemFeed(),
          Expanded(
            child: ProblemList(),
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              image: DecorationImage(
                image: NetworkImage('https://placeholder.com/background'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
            accountName: const Text("Asad",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            accountEmail: const Text("Specialization: Developer"),
            currentAccountPicture: Hero(
              tag: 'profile',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text("A",
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _buildAnimatedListTiles(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedListTiles() {
    final items = [
      {'title': 'Settings', 'icon': Icons.settings},
      {'title': 'Achievements', 'icon': Icons.emoji_events},
      {'title': 'Feedback', 'icon': Icons.feedback},
    ];

    return items
        .map((item) => _AnimatedListTile(
              title: item['title'] as String,
              icon: item['icon'] as IconData,
            ))
        .toList();
  }
}

class _AnimatedListTile extends StatefulWidget {
  final String title;
  final IconData icon;

  const _AnimatedListTile({
    required this.title,
    required this.icon,
  });

  @override
  _AnimatedListTileState createState() => _AnimatedListTileState();
}

class _AnimatedListTileState extends State<_AnimatedListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: _isHovered ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: () {},
        onHover: (isHovered) => setState(() => _isHovered = isHovered),
        child: ListTile(
          leading: Icon(widget.icon,
              color: _isHovered ? Colors.blueAccent : Colors.grey),
          title: Text(widget.title),
        ),
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
  final List<Map<String, String>> problems = [
    {
      "title": "Medical Assistance Needed",
      "type": "Medical",
      "urgency": "High",
      "location": "2.5 km away"
    },
    {
      "title": "Emergency Support Required",
      "type": "Emergency",
      "urgency": "Critical",
      "location": "1.2 km away"
    },
    {
      "title": "General Assistance",
      "type": "General",
      "urgency": "Medium",
      "location": "3.8 km away"
    },
  ];

  ProblemList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: problems.length,
      itemBuilder: (context, index) {
        return ProblemCard(
          problemData: problems[index],
          index: index,
        );
      },
    );
  }
}

class ProblemCard extends StatefulWidget {
  final Map<String, String> problemData;
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

        ///  elevation: 10,
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
                        widget.problemData['title']!,
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
                Row(
                  children: [
                    _buildChip(
                      widget.problemData['type']!,
                      Icons.medical_services,
                      Colors.blue,
                    ),
                    const SizedBox(width: 6),
                    _buildChip(
                      widget.problemData['urgency']!,
                      Icons.warning,
                      Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    _buildChip(
                      widget.problemData['location']!,
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
      //padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class ProblemDetailsScreen extends StatefulWidget {
  final Map<String, String> problemData;

  const ProblemDetailsScreen({super.key, required this.problemData});

  @override
  State<ProblemDetailsScreen> createState() => _ProblemDetailsScreenState();
}

class _ProblemDetailsScreenState extends State<ProblemDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problemData['title']!),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(),
              const SizedBox(height: 24),
              _buildDescriptionSection(),
              const SizedBox(height: 24),
              _buildSolutionSection(),
              const SizedBox(height: 24),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                Icons.medical_services, 'Type', widget.problemData['type']!),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.warning, 'Urgency', widget.problemData['urgency']!),
            const SizedBox(height: 12),
            _buildInfoRow(
                Icons.location_on, 'Location', widget.problemData['location']!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Detailed description of the problem goes here. This section provides comprehensive information about the situation and requirements.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Solution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.text_fields, 'Text'),
                _buildActionButton(Icons.mic, 'Voice'),
                _buildActionButton(Icons.attach_file, 'Attach'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton([IconData? icon, String? label]) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.check_circle,
              color: Colors.blueAccent,
              size: 24,
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildRequestVisitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          _showRequestConfirmation();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person_pin_circle, size: 24),
            SizedBox(width: 8),
            Text(
              "Request Visit",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAnimatedDialog(
          AlertDialog(
            title: const Text("Confirm Request"),
            content: const Text(
              "Are you sure you want to request a visit for this problem?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showSuccessSnackbar();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text("Confirm"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDialog(Widget child) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Visit request sent successfully!"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Add a custom page route for smooth transitions
class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

// Add a custom loading indicator
class CustomLoadingIndicator extends StatefulWidget {
  const CustomLoadingIndicator({super.key});

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _animation,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          ),
        ),
      ),
    );
  }
}
