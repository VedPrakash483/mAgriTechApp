import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_agritech_app/services/firebase_auth_service.dart';
import 'package:e_agritech_app/models/user_model.dart'; // Import the UserModel for type usage
import 'package:e_agritech_app/providers/auth_provider.dart'; // Import your AuthProvider if you have one

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

  String? _selectedState;
  String? _selectedSpecialization;
  bool _isLoading = false;

  final List<String> _states = [
    'Select State',
    'Andhra Pradesh',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
  ];

  final List<String> _specializations = [
    'Select Specialization',
    'Agriculture',
    'Medicine',
  ];

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = await Provider.of<FirebaseAuthService>(context, listen: false).registerUser(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        userType: 'Student',
        phone: _phoneController.text,
        state: _selectedState,
        specialization: _selectedSpecialization,
      );

      setState(() => _isLoading = false);

      if (user != null) {
        // Navigate to Student Home Page or display success message
        print('Student registration successful');
        Navigator.pushReplacementNamed(context, '/studentHome'); // Example navigation
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed, try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Registration',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Register as a Student',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _nameController,
                labelText: 'Name',
                icon: Icons.person,
              ),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildDropdown(
                label: 'Select State',
                items: _states,
                value: _selectedState,
                onChanged: (value) => setState(() => _selectedState = value),
              ),
              _buildDropdown(
                label: 'Select Specialization',
                items: _specializations,
                value: _selectedSpecialization,
                onChanged: (value) =>
                    setState(() => _selectedSpecialization = value),
              ),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.green[700], // Use backgroundColor instead of primary
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: (value) =>
        value!.isEmpty ? 'Please enter your $labelText' : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(label),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
        validator: (value) =>
        value == null || value == 'Select State' || value == 'Select Specialization'
            ? 'Please select $label'
            : null,
      ),
    );
  }
}
