import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_agritech_app/models/problem_model.dart';
import 'package:e_agritech_app/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddProblemScreen extends StatefulWidget {
  final String farmerId;
  final UserModel userModel;

  const AddProblemScreen(
      {super.key, required this.farmerId, required this.userModel});

  @override
  _AddProblemScreenState createState() => _AddProblemScreenState();
}

class _AddProblemScreenState extends State<AddProblemScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String _assistanceType = '';
  String _description = '';
  String _categoryTag = '';
  File? _imageFile;
  bool _isLoading = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // file is uploaded with jpg as a image extension
  Future<String?> _uploadFile(File file) async {
    try {
      final fileName =
          'prob_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _submitProblem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();

      try {
        // Upload image if it exists
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadFile(_imageFile!);
        }

        // Prepare ProblemModel object
        final problem = ProblemModel(
          farmerId: widget.farmerId,
          assistanceType: _assistanceType,
          description: _description,
          imageUrl: imageUrl,
          categoryTag: _categoryTag,
          location:
              widget.userModel.state, // Assume userModel.state holds location
          status: 'ongoing',
          timestamp: Timestamp.now(),
        );

        // Save to Firestore
        await _firestore.collection('problems').add(problem.toMap());

        // On successful submission, navigate back
        Navigator.pop(context);
      } catch (e) {
        print('Error submitting problem: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to submit problem. Please try again.')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _isLoading ? null : _submitProblem,
      child: Text(
        'Submit',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Report Problem',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                FadeInRight(
                  duration: const Duration(milliseconds: 1000),
                  child: _buildAssistanceTypeSelection(),
                ),
                const SizedBox(height: 20),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: _buildDescriptionInput(),
                ),
                const SizedBox(height: 20),
                FadeInDown(
                  delay: const Duration(milliseconds: 400),
                  child: _buildCategoryDropdown(),
                ),
                const SizedBox(height: 20),
                FadeInDown(
                  delay: const Duration(milliseconds: 600),
                  child: _buildMediaUpload(),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: _buildSubmitButton(),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssistanceTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What type of assistance do you need?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                'Medicine',
                Icons.medical_services,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTypeButton(
                'Agriculture',
                Icons.agriculture,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(String type, IconData icon) {
    bool isSelected = _assistanceType == type;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () => setState(() => _assistanceType = type),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isSelected ? Colors.green : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  type,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Problem Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Describe your problem...',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
          onSaved: (value) => _description = value!,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      items: <String>['Category 1', 'Category 2', 'Category 3']
          .map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) => setState(() => _categoryTag = value!),
      decoration: const InputDecoration(
        labelText: 'Select a Category',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildMediaUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Media',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Upload Image'),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Record audio function (can be implemented later)
              },
              icon: const Icon(Icons.mic),
              label: const Text('Record Audio'),
            ),
          ],
        ),
        if (_imageFile != null) ...[
          const SizedBox(height: 10),
          Image.file(_imageFile!, height: 100),
        ],
      ],
    );
  }
}
