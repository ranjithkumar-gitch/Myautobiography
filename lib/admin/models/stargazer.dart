class Stargazer {
  final String id;
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime dob;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Stargazer({
    required this.id,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Stargazer.fromJson(Map<String, dynamic> json) {
    return Stargazer(
      id: json['id'] as String,
      role: json['role'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      dob: DateTime.parse(json['dob'] as String),
      displayName: json['displayName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
