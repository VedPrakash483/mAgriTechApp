import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_agritech_app/models/problem_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddProblemScreen extends StatefulWidget {
  final String farmerId;

  const AddProblemScreen({super.key, required this.farmerId});

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
  final bool _isRecording = false;
  String? _audioPath;
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

  // Future<void> _pickImage() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  //   if (image != null) {
  //     setState(() {
  //       _imageFile = File(image.path);
  //     });
  //   }
  // }

  // Future<String?> _uploadFile(File file, String path) async {
  //   try {
  //     final ref = _storage.ref().child(path);
  //     await ref.putFile(file);
  //     return await ref.getDownloadURL();
  //   } catch (e) {
  //     print('Error uploading file: $e');
  //     return null;
  //   }
  // }

  Future<void> _submitProblem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();

      try {
        // Upload image if it exists
        // String? imageUrl;
        // if (_imageFile != null) {
        //   imageUrl = await _uploadFile(
        //     _imageFile!,
        //     'problems/images/${DateTime.now().millisecondsSinceEpoch}.jpg',
        //   );
        // }

        // Upload audio if it exists
        // String? audioUrl;
        // if (_audioPath != null) {
        //   audioUrl = await _uploadFile(
        //     File(_audioPath!),
        //     'problems/audio/${DateTime.now().millisecondsSinceEpoch}.m4a',
        //   );
        // }

        // Fetch current location
        //final position = await Geolocator.getCurrentPosition();
        //final location = '${position.latitude}, ${position.longitude}';

        // Prepare ProblemModel object
        final problem = ProblemModel(
          farmerId: widget.farmerId,
          assistanceType: _assistanceType,
          description: _description,
          //audioUrl: audioUrl,
          //imageUrl: imageUrl,
          categoryTag: _categoryTag,
          //location: location,
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
          SnackBar(
              content: Text('Failed to submit problem. Please try again.')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
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
                'Medical\nAssistance',
                Icons.medical_services,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTypeButton(
                'Farm\nAssistance',
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

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.teal],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitProblem,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          'Submit Problem',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
              onPressed: () {},
              icon: const Icon(Icons.image),
              label: const Text('Upload Image'),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Record audio function
              },
              icon: const Icon(Icons.mic),
              label: const Text('Record Audio'),
            ),
          ],
        ),
      ],
    );
  }
}
