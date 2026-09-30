class TermsResponse {
  final bool success;
  final String? message;
  final TermsData? data;

  TermsResponse({required this.success, this.message, this.data});

  factory TermsResponse.fromJson(Map<String, dynamic> json) {
    return TermsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? TermsData.fromJson(json['data']) : null,
    );
  }
}

class TermsData {
  final String id;
  final bool isPublic;
  final String description;
  final String createdAt;
  final String updatedAt;

  TermsData({
    required this.id,
    required this.isPublic,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TermsData.fromJson(Map<String, dynamic> json) {
    return TermsData(
      id: json['_id'] ?? '',
      isPublic: json['isPublic'] ?? false,
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
