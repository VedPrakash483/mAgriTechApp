class UserModel {
  final String uid;
  final String email;
  final String name;
  final String userType; // Student or Farmer
  final String? aadhaarNumber;
  final String? preferredLanguage;
  final String? phone;
  final String? location;
  final String? state;
  final String? specialization;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.userType,
    this.aadhaarNumber,
    this.preferredLanguage,
    this.phone,
    this.location,
    this.state,
    this.specialization,
  });

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

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      userType: map['userType'],
      aadhaarNumber: map['aadhaarNumber'],
      preferredLanguage: map['preferredLanguage'],
      phone: map['phone'],
      location: map['location'],
      state: map['state'],
      specialization: map['specialization'],
    );
  }
}
