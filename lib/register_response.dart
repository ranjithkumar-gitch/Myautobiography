class RegisterResponse {
  final bool success;
  final String statusResult;
  final int statusCode;
  final RegisterData? data;
  final String? message;
  final String? errorCode;
  final String? requestId;

  RegisterResponse({
    required this.success,
    required this.statusResult,
    required this.statusCode,
    this.data,
    this.message,
    this.errorCode,
    this.requestId,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      statusResult: json['statusResult'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
      message: json['message'],
      errorCode: json['errorCode'],
      requestId: json['requestId'],
    );
  }
}

class RegisterData {
  final String id;
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dob;
  final String displayName;
  final String createdAt;
  final String updatedAt;

  RegisterData({
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

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      id: json['id'] ?? '',
      role: json['role'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dob: json['dob'] ?? '',
      displayName: json['displayName'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
