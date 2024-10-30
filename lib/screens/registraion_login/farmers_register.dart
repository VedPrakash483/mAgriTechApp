import 'package:e_agritech_app/components/input_field.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmersRegister extends StatefulWidget {
  const FarmersRegister({Key? key}) : super(key: key);

  @override
  _FarmersRegisterState createState() => _FarmersRegisterState();
}

class _FarmersRegisterState extends State<FarmersRegister> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedState;
  String? _selectedLanguage;
  bool _isFarmingAssistance = true;

  final List<String> _states = [
    'Andhra Pradesh',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
    'Gujarat',
    'Kerala',
    'Madhya Pradesh',
    'Punjab',
    'Rajasthan',
    'Uttar Pradesh',
  ];

  final List<String> _languages = [
    'Hindi',
    'English',
    'Telugu',
    'Tamil',
    'Marathi',
    'Kannada',
    'Gujarati',
    'Malayalam',
  ];

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _locationController.text =
            "${position.latitude}, ${position.longitude}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get location. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement Firebase registration
      print('Name: ${_nameController.text}');
      print('Aadhaar: ${_aadhaarController.text}');
      print('Phone: ${_phoneController.text}');
      print('State: $_selectedState');
      print('Language: $_selectedLanguage');
      print('Location: ${_locationController.text}');
      print('Assistance Type: ${_isFarmingAssistance ? 'Farming' : 'Medical'}');
      print('Password: ${_passwordController.text}');
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.green.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.green.shade50,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.green.shade50,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select an option' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        title: Text(
          'Farmer Registration',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or Image placeholder
                  Icon(
                    Icons.agriculture,
                    size: 80,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to mAgriTech!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    icon: Icons.person,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter your name'
                        : null,
                  ),
      
                  _buildInputField(
                    controller: _aadhaarController,
                    label: 'Aadhaar Number',
                    hint: 'Enter your 12-digit Aadhaar number',
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.length != 12 ? 'Invalid Aadhaar number' : null,
                  ),
                  _buildInputField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter your 10-digit phone number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value?.length != 10 ? 'Invalid phone number' : null,
                  ),
                  _buildDropdown(
                    label: 'State',
                    items: _states,
                    value: _selectedState,
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value;
                      });
                    },
                    icon: Icons.location_city,
                  ),
                  _buildDropdown(
                    label: 'Preferred Language',
                    items: _languages,
                    value: _selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    },
                    icon: Icons.language,
                  ),
                  _buildInputField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'Tap to get current location',
                    icon: Icons.location_on,
                    readOnly: true,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Get Current Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Assistance Type',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Medical',
                                style: GoogleFonts.poppins(),
                              ),
                              Switch(
                                value: _isFarmingAssistance,
                                onChanged: (value) {
                                  setState(() {
                                    _isFarmingAssistance = value;
                                  });
                                },
                                activeColor: Colors.green.shade700,
                              ),
                              Text(
                                'Farming',
                                style: GoogleFonts.poppins(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    icon: Icons.lock,
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
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Register',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
