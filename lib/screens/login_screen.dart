import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/input_field.dart';
import '../components/rounded_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Login to continue',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        InputField(
                          hintText: 'Email',
                          controller: emailController,
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        InputField(
                          hintText: 'Password',
                          controller: passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock,
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        RoundedButton(
                          text: _isLoading ? 'Logging in...' : 'Login',
                          onPressed: _isLoading ? null : loginUser,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot_password');
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account? ',
                              style: TextStyle(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
