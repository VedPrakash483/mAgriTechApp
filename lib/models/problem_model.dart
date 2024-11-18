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
  late final List<Map<String, dynamic>> solutions; // Changed to plural for clarity

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
    List<Map<String, dynamic>>? solutions, // Allow null input
  }) : this.solutions = solutions ?? []; // Default to empty list if null

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
      'solutions': solutions, // Ensure this is correctly referenced
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
      solutions: (map['solutions'] is List)
          ? List<Map<String, dynamic>>.from(map['solutions'])
          : [], // Ensure this is a List, default to empty if not
    );
  }
}