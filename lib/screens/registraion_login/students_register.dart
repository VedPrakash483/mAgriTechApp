import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_agritech_app/screens/registraion_login/student_login.dart';
import 'package:e_agritech_app/services/firebase_auth_service.dart';
import 'package:e_agritech_app/services/user_service.dart';
import 'package:e_agritech_app/models/user_model.dart';
import 'package:e_agritech_app/components/custom_button.dart';
import 'package:e_agritech_app/components/custom_dropdown.dart';
import 'package:e_agritech_app/components/custom_test_field.dart';

class StudentRegister extends StatefulWidget {
  const StudentRegister({Key? key}) : super(key: key);

  @override
  _StudentRegisterState createState() => _StudentRegisterState();
}

class _StudentRegisterState extends State<StudentRegister> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _selectedState;
  String? _selectedSpecialization;

  final _states = [
    'Andhra Pradesh',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
  ];

  final _specializations = [
    'Agriculture',
    'Medicine',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Register the student with Firebase Authentication
        final user = await FirebaseAuthService().registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          userType: "Student",
          phone: _phoneController.text.trim(),
          state: _selectedState,
          specialization: _selectedSpecialization,
        );

        if (user != null) {
          // Save the user data in Firestore
          final registeredUser = UserModel(
            uid: user.uid,
            email: _emailController.text.trim(),
            name: _nameController.text.trim(),
            userType: "Student",
            phone: _phoneController.text.trim(),
            state: _selectedState,
            specialization: _selectedSpecialization,
          );
          await UserService().saveUserInfo(registeredUser);

          _showSnackBar('Registration successful!', Colors.green);

          // Navigate to login page after successful registration
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const StudentsLogin()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already registered';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password accounts are not enabled';
            break;
          default:
            errorMessage = 'Registration failed: ${e.message}';
        }
        _showSnackBar(errorMessage, Colors.red);
      } catch (e) {
        _showSnackBar('Registration error: $e', Colors.red);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'logo',
                    child: Icon(
                      Icons.school,
                      size: 64,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Student Registration',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    icon: Icons.person,
                    validator: (value) => 
                      value?.isEmpty ?? true ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter your mobile number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'Enter your email address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomDropdown(
                    label: 'State',
                    items: _states,
                    value: _selectedState,
                    onChanged: (value) => setState(() => _selectedState = value),
                    icon: Icons.map,
                    validator: (value) =>
                      value == null ? 'Please select your state' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomDropdown(
                    label: 'Specialization',
                    items: _specializations,
                    value: _selectedSpecialization,
                    onChanged: (value) => setState(() => _selectedSpecialization = value),
                    icon: Icons.school,
                    validator: (value) =>
                      value == null ? 'Please select your specialization' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    icon: Icons.lock,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 24),
                  
                  CustomButton(
                    text: 'Register',
                    onPressed: _register,
                    isLoading: _isLoading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const StudentsLogin()),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
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
    );
  }
}