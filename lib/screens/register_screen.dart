import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/input_field.dart';
import '../components/rounded_button.dart';

class RegisterScreen extends StatefulWidget {
  final String userType;

  const RegisterScreen({
    Key? key,
    required this.userType,
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _locationController;
  late final TextEditingController _aadhaarController;
  late final TextEditingController _languageController;
  late final TextEditingController _stateController;
  late final TextEditingController _specializationController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _locationController = TextEditingController();
    _aadhaarController = TextEditingController();
    _languageController = TextEditingController();
    _stateController = TextEditingController();
    _specializationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    _aadhaarController.dispose();
    _languageController.dispose();
    _stateController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  /// Handles the button press and calls the async registration function
  void _handleRegisterPress() {
    _registerUser();
  }

  /// Handles user registration process
  /// Creates authentication and stores user data in Firestore
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'userType': widget.userType,
        'aadhaar': widget.userType == 'Farmer' ? _aadhaarController.text.trim() : null,
        'preferredLanguage': widget.userType == 'Farmer' ? _languageController.text.trim() : null,
        'state': widget.userType == 'Student' ? _stateController.text.trim() : null,
        'specialization': widget.userType == 'Student' ? _specializationController.text.trim() : null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/${widget.userType.toLowerCase()}_home',
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register as ${widget.userType}'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.person_outline,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 30),
                InputField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (widget.userType == 'Farmer') ...[
                  InputField(
                    controller: _aadhaarController,
                    hintText: 'Aadhaar Number',
                    prefixIcon: Icons.credit_card,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your Aadhaar number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InputField(
                    controller: _languageController,
                    hintText: 'Preferred Language',
                    prefixIcon: Icons.language,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your preferred language';
                      }
                      return null;
                    },
                  ),
                ] else if (widget.userType == 'Student') ...[
                  InputField(
                    controller: _stateController,
                    hintText: 'State',
                    prefixIcon: Icons.location_city,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your state';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InputField(
                    controller: _specializationController,
                    hintText: 'Specialization (e.g., Agriculture or Medicine)',
                    prefixIcon: Icons.school,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your specialization';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                InputField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: _phoneController,
                  hintText: 'Phone Number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: _locationController,
                  hintText: 'Location',
                  prefixIcon: Icons.location_on,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a password';
                    }
                    if (value!.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                RoundedButton(
                  text: _isLoading ? 'Registering...' : 'Register',
                  onPressed: _isLoading ? null : _handleRegisterPress,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Login'),
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
}
