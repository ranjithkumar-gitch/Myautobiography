class RequestAsStarResponse {
  final bool success;
  final String statusResult;
  final int statusCode;
  final RequestAsStarData? data;
  final String? message;
  final String? errorCode;
  final String? requestId;

  RequestAsStarResponse({
    required this.success,
    required this.statusResult,
    required this.statusCode,
    this.data,
    this.message,
    this.errorCode,
    this.requestId,
  });

  factory RequestAsStarResponse.fromJson(Map<String, dynamic> json) {
    return RequestAsStarResponse(
      success: json['success'] ?? false,
      statusResult: json['statusResult'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: json['data'] != null
          ? RequestAsStarData.fromJson(json['data'])
          : null,
      message: json['message'],
      errorCode: json['errorCode'],
      requestId: json['requestId'],
    );
  }
}

class RequestAsStarData {
  final String id;
  final String stargazerId;
  final String status;
  final StargazerInfo? stargazer;
  final String createdAt;
  final String updatedAt;

  RequestAsStarData({
    required this.id,
    required this.stargazerId,
    required this.status,
    this.stargazer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RequestAsStarData.fromJson(Map<String, dynamic> json) {
    return RequestAsStarData(
      id: json['id'] ?? '',
      stargazerId: json['stargazerId'] ?? '',
      status: json['status'] ?? '',
      stargazer: json['stargazer'] != null
          ? StargazerInfo.fromJson(json['stargazer'])
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class StargazerInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String displayName;

  StargazerInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.displayName,
  });

  factory StargazerInfo.fromJson(Map<String, dynamic> json) {
    return StargazerInfo(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
    );
  }
}
