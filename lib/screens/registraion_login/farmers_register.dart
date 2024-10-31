import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:e_agritech_app/screens/registraion_login/farmers_login.dart';
import 'package:e_agritech_app/services/firebase_auth_service.dart';
import 'package:e_agritech_app/services/user_service.dart';
import 'package:e_agritech_app/models/user_model.dart';
import 'package:e_agritech_app/components/custom_button.dart';
import 'package:e_agritech_app/components/custom_dropdown.dart';
import 'package:e_agritech_app/components/custom_test_field.dart';

class FarmersRegister extends StatefulWidget {
  const FarmersRegister({Key? key}) : super(key: key);

  @override
  _FarmersRegisterState createState() => _FarmersRegisterState();
}

class _FarmersRegisterState extends State<FarmersRegister> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _selectedState;
  String? _selectedLanguage;

  final _states = [
    'Andhra Pradesh', 'Maharashtra', 'Karnataka', 'Tamil Nadu',
    'Gujarat', 'Kerala', 'Madhya Pradesh', 'Punjab',
    'Rajasthan', 'Uttar Pradesh',
  ];
  final _languages = [
    'Hindi', 'English', 'Telugu', 'Tamil', 'Marathi', 'Kannada', 'Gujarati', 'Malayalam',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _aadhaarController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permission denied', Colors.red);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied', Colors.red);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      setState(() {
        _locationController.text = "${position.latitude}, ${position.longitude}";
      });
      _showSnackBar('Location updated successfully', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to get location: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
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

  String? _validateAadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Aadhaar number';
    }
    if (value.length != 12) {
      return 'Aadhaar number must be 12 digits';
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
        // Register the farmer with Firebase Authentication
        final user = await FirebaseAuthService().registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          userType: "Farmer",
          aadhaarNumber: _aadhaarController.text.trim(),
          preferredLanguage: _selectedLanguage,
          phone: _phoneController.text.trim(),
          location: _locationController.text.trim(),
          state: _selectedState,
        );

        if (user != null) {
          // Save the user data in Firestore
          final registeredUser = UserModel(
            uid: user.uid,
            email: _emailController.text.trim(),
            name: _nameController.text.trim(),
            userType: "Farmer",
            aadhaarNumber: _aadhaarController.text.trim(),
            preferredLanguage: _selectedLanguage,
            phone: _phoneController.text.trim(),
            location: _locationController.text.trim(),
            state: _selectedState,
          );
          await UserService().saveUserInfo(registeredUser);

          _showSnackBar('Registration successful!', Colors.green);

          // Navigate to login page after successful registration
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FarmersLogin()),
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
                      Icons.eco,
                      size: 64,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Farmer Registration',
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
                    controller: _aadhaarController,
                    label: 'Aadhaar Number',
                    hint: 'Enter your 12-digit Aadhaar number',
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    validator: _validateAadhaar,
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
                  
                  CustomTextField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'Your location will be auto-filled',
                    icon: Icons.location_on,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  
                  CustomButton(
                    text: 'Get Current Location',
                    onPressed: _getCurrentLocation,
                    icon: Icons.my_location,
                    isLoading: _isLoading && _locationController.text.isEmpty,
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
                    label: 'Preferred Language',
                    items: _languages,
                    value: _selectedLanguage,
                    onChanged: (value) => setState(() => _selectedLanguage = value),
                    icon: Icons.language,
                    validator: (value) =>
                      value == null ? 'Please select your language' : null,
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
                          MaterialPageRoute(builder: (context) => const FarmersLogin()),
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