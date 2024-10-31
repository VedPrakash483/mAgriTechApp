import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'user_registration_selection.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isSliding = false;
  final _random = math.Random();

  // Add animated background bubbles
  final List<Map<String, dynamic>> _bubbles = List.generate(
    15,
    (index) => {
      'position': Offset(
        (index * 50.0) % 300,
        (index * 60.0) % 400,
      ),
      'size': 20.0 + (index % 4) * 15.0,
      'color': Colors.white.withOpacity(0.1 + (index % 3) * 0.1),
    },
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
    ));

    _controller.forward();

    // Animate bubbles
    _animateBubbles();
  }

  void _animateBubbles() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          for (var bubble in _bubbles) {
            bubble['position'] = Offset(
              bubble['position'].dx + (_random.nextDouble() - 0.5) * 2,
              bubble['position'].dy - 1,
            );
            if (bubble['position'].dy < -50) {
              bubble['position'] = Offset(
                bubble['position'].dx,
                MediaQuery.of(context).size.height + 50,
              );
            }
          }
        });
        _animateBubbles();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const UserSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: [
              FadeTransition(
                opacity: animation,
                child: child,
              ),
              SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(-1.0, 0.0),
                ).animate(animation),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ],
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withGreen(
                        (Theme.of(context).primaryColor.green + 40).clamp(0, 255),
                      ),
                ],
              ),
            ),
          ),
          // Animated bubbles
          ...(_bubbles.map((bubble) => Positioned(
                left: bubble['position'].dx,
                top: bubble['position'].dy,
                child: Container(
                  width: bubble['size'],
                  height: bubble['size'],
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bubble['color'],
                  ),
                ),
              ))),
          // Content
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            children: [
                              Hero(
                                tag: 'logo',
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/logo.png',
                                    height: 120,
                                    width: 120,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.9),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ).createShader(bounds),
                                child: Text(
                                  'Welcome to\nE-MediFarmTech',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Connect, Learn, and Grow Together',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: EnhancedSlideToAct(
                          onSlideCompleted: _navigateToNextScreen,
                          text: 'Slide to Start',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EnhancedSlideToAct extends StatefulWidget {
  final VoidCallback onSlideCompleted;
  final String text;

  const EnhancedSlideToAct({
    Key? key,
    required this.onSlideCompleted,
    required this.text,
  }) : super(key: key);

  @override
  State<EnhancedSlideToAct> createState() => _EnhancedSlideToActState();
}

class _EnhancedSlideToActState extends State<EnhancedSlideToAct>
    with SingleTickerProviderStateMixin {
  double _position = 0.0;
  double _startPosition = 0.0;
  bool _isSliding = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    setState(() {
      _isSliding = true;
      _startPosition = details.localPosition.dx;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isSliding) return;

    final containerWidth = context.size!.width;
    final knobWidth = 60.0;
    final maxSlide = containerWidth - knobWidth;

    setState(() {
      _position = (_position + details.localPosition.dx - _startPosition)
          .clamp(0.0, maxSlide);
      _startPosition = details.localPosition.dx;
    });

    if (_position >= maxSlide * 0.9) {
      widget.onSlideCompleted();
      _isSliding = false;
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isSliding) return;

    setState(() {
      _isSliding = false;
      _position = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Sliding progress indicator
          Container(
            width: _position + 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          // Centered text
          Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          // Sliding knob
          GestureDetector(
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: Container(
              margin: EdgeInsets.only(left: _position),
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}