import 'package:cloud_firestore/cloud_firestore.dart';

class ProblemModel {
  final String problemId; // Unique identifier for the problem
  final String farmerId;
  final String assistanceType; // Medical or Farm
  final String description;
  final String? audioUrl; 
  final String? imageUrl;
  final String categoryTag;
  final String? location;
  String solution; // Change this to a non-final field
  final String status;
  final Timestamp timestamp;

  ProblemModel({
    required this.problemId,
    required this.farmerId,
    required this.assistanceType,
    required this.description,
    this.audioUrl,
    this.imageUrl,
    required this.categoryTag,
    this.location,
    this.solution = '', // Default to an empty string if not provided
    required this.status,
    required this.timestamp,
  });

  // Convert the ProblemModel instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'problemId': problemId,
      'farmerId': farmerId,
      'assistanceType': assistanceType,
      'description': description,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'categoryTag': categoryTag,
      'location': location,
      'solution': solution, // Include solution in the map
      'status': status,
      'timestamp': timestamp,
    };
  }

  // Create a ProblemModel instance from a Map
  factory ProblemModel.fromMap(Map<String, dynamic> map) {
    return ProblemModel(
      problemId: map['problemId'] as String,
      farmerId: map['farmerId'] as String,
      assistanceType: map['assistanceType'] as String,
      description: map['description'] as String,
      audioUrl: map['audioUrl'] as String?,
      imageUrl: map['imageUrl'] as String?,
      categoryTag: map['categoryTag'] as String,
      location: map['location'] as String?,
      solution: map['solution'] as String? ?? '', // Ensure this is a string, default to empty if not
      status: map['status'] as String,
      timestamp: map['timestamp'] as Timestamp,
    );
  }
}