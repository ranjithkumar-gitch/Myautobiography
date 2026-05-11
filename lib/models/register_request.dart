class RegisterRequest {
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dob;
  final String displayName;

  RegisterRequest({
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'dob': dob,
    'displayName': displayName,
  };
}
