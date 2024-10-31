import 'package:e_agritech_app/components/input_field.dart'; 
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:e_agritech_app/services/firebase_auth_service.dart';
import 'package:e_agritech_app/services/user_service.dart';
import 'package:e_agritech_app/models/user_model.dart';

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

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _locationController.text = "${position.latitude}, ${position.longitude}";
      });
      _showSnackBar('Location updated', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to get location', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
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

          Navigator.pop(context);
        } else {
          _showSnackBar('Registration failed', Colors.red);
        }
      } catch (e) {
        _showSnackBar('Registration error: $e', Colors.red);
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(),
        ),
      ),
      value: value,
      items: items.map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Select $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Registration', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Text(
                  'Register as a Farmer',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
                ),
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: _nameController,
                label: 'Name',
                hint: 'Enter name',
                icon: Icons.person,
                validator: (value) => value?.isEmpty ?? true ? 'Enter name' : null,
              ),
              const SizedBox(height: 10),

              _buildInputField(
                controller: _aadhaarController,
                label: 'Aadhaar',
                hint: 'Enter Aadhaar number',
                icon: Icons.credit_card,
                validator: (value) => value?.isEmpty ?? true ? 'Enter Aadhaar' : null,
              ),
              const SizedBox(height: 10),

              _buildInputField(
                controller: _phoneController,
                label: 'Phone',
                hint: 'Enter phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Enter phone' : null,
              ),
              const SizedBox(height: 10),

              _buildInputField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter email',
                icon: Icons.email,
                validator: (value) => value?.isEmpty ?? true ? 'Enter email' : null,
              ),
              const SizedBox(height: 10),

              _buildInputField(
                controller: _locationController,
                label: 'Location',
                hint: 'Auto-filled',
                icon: Icons.location_on,
                readOnly: true,
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text('Get Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 10),

              _buildDropdown(
                label: 'State',
                items: _states,
                value: _selectedState,
                onChanged: (value) => setState(() => _selectedState = value),
                icon: Icons.map,
              ),
              const SizedBox(height: 10),

              _buildDropdown(
                label: 'Language',
                items: _languages,
                value: _selectedLanguage,
                onChanged: (value) => setState(() => _selectedLanguage = value),
                icon: Icons.language,
              ),
              const SizedBox(height: 10),

              _buildInputField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter password',
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
