import 'package:cloud_firestore/cloud_firestore.dart';

class ProblemModel {
  final String farmerId;
  final String assistanceType; // Medical or Farm
  final String description;
  final String? audioUrl; 
  final String? imageUrl;
  final String categoryTag;
  final String? location;
  final String status;
  final Timestamp timestamp;
  late final String solution; // Changed to a single string for the solution

  ProblemModel({
    required this.farmerId,
    required this.assistanceType,
    required this.description,
    this.audioUrl,
    this.imageUrl,
    required this.categoryTag,
    this.location,
    required this.status,
    required this.timestamp,
    this.solution = '', // Default to an empty string if not provided
  });

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'assistanceType': assistanceType,
      'description': description,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'categoryTag': categoryTag,
      'location': location,
      'status': status,
      'timestamp': timestamp,
      'solution': solution, // Store the solution as a single string
    };
  }

  factory ProblemModel.fromMap(Map<String, dynamic> map) {
    return ProblemModel(
      farmerId: map['farmerId'],
      assistanceType: map['assistanceType'],
      description: map['description'],
      audioUrl: map['audioUrl'],
      imageUrl: map['imageUrl'],
      categoryTag: map['categoryTag'],
      location: map['location'],
      status: map['status'],
      timestamp: map['timestamp'],
      solution: map['solution'] ?? '', // Ensure this is a string, default to empty if not
    );
  }
}