class EmailCheckResponse {
  final bool success;
  final String? message;

  /// The registration code emailed to the user.
  final String? resetToken;

  EmailCheckResponse({required this.success, this.message, this.resetToken});

  factory EmailCheckResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return EmailCheckResponse(
      success: json['success'] ?? false,
      message: json['message'],
      resetToken: data is Map ? data['resetToken']?.toString() : null,
    );
  }
}
