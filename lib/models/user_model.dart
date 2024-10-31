class UserModel {
  final String uid;
  final String? email;
  final String name;
  final String userType; // Either 'Student' or 'Farmer'
  final String? aadhaarNumber;
  final String? preferredLanguage;
  final String? phone;
  final String? location;
  final String? state;
  final String? specialization;

  // Constructor
  UserModel({
    required this.uid,
    required this.name,
    required this.userType,
    this.email,
    this.aadhaarNumber,
    this.preferredLanguage,
    this.phone,
    this.location,
    this.state,
    this.specialization,
  });

  // Convert the UserModel instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'userType': userType,
      'aadhaarNumber': aadhaarNumber,
      'preferredLanguage': preferredLanguage,
      'phone': phone,
      'location': location,
      'state': state,
      'specialization': specialization,
    };
  }

  // Create a UserModel instance from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      userType: map['userType'] as String,
      aadhaarNumber: map['aadhaarNumber'] as String?,
      preferredLanguage: map['preferredLanguage'] as String?,
      phone: map['phone'] as String?,
      location: map['location'] as String?,
      state: map['state'] as String?,
      specialization: map['specialization'] as String?,
    );
  }
}
