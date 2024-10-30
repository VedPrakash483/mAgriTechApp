import 'package:e_agritech_app/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentRegister extends StatefulWidget {
  const StudentRegister({Key? key}) : super(key: key);

  @override
  _StudentRegisterState createState() => _StudentRegisterState();
}

class _StudentRegisterState extends State<StudentRegister> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  
  // comments by asad
  // first make a instance of FirebaseAuthService
  /// then make a function of [signUpStudent]
  // then call that function in button click event


  final FirebaseAuthService _authService = FirebaseAuthService();

  String? _selectedState;
  String? _selectedSpecialization;

  final List<String> _states = [
    'Select State',
    'Andhra Pradesh',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
    // Add more states as needed
  ];

  final List<String> _specializations = [
    'Select Specialization',
    'Agriculture',
    'Medicine',
  ];

  void signUpStudent() async {
    if (_formKey.currentState!.validate()) {
      // Display loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        await _authService.registerUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          userType: "student",
        );

        Navigator.of(context).pop(); 

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to next page or reset form
        _formKey.currentState?.reset();
        _selectedState = null;
        _selectedSpecialization = null;
      } catch (e) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedState,
                hint: const Text('Select State'),
                items: _states.map((String state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a state' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedSpecialization,
                hint: const Text('Select Specialization'),
                items: _specializations.map((String specialization) {
                  return DropdownMenuItem<String>(
                    value: specialization,
                    child: Text(specialization),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialization = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a specialization' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your password' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: signUpStudent,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
