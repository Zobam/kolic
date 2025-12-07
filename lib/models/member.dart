class Member {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String phoneNumber;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'phoneNumber': phoneNumber,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map, String id) {
    return Member(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      dateOfBirth:
          DateTime.tryParse(map['dateOfBirth'] ?? '') ?? DateTime.now(),
      gender: map['gender'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}
