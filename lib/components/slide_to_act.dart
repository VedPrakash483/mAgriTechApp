import 'package:flutter/material.dart';

class SlideToActButton extends StatefulWidget {
  final VoidCallback onSlideCompleted;
  final String text;

  const SlideToActButton({
    super.key,
    required this.onSlideCompleted,
    required this.text,
  });

  @override
  State<SlideToActButton> createState() => _SlideToActButtonState();
}

class _SlideToActButtonState extends State<SlideToActButton>
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