class StarRequestStargazer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String displayName;

  const StarRequestStargazer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.displayName,
  });

  String get fullName => '$firstName $lastName';

  factory StarRequestStargazer.fromJson(Map<String, dynamic> json) {
    return StarRequestStargazer(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
    );
  }
}

class StarRequest {
  final String id;
  final String stargazerId;
  final String status;
  final StarRequestStargazer stargazer;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StarRequest({
    required this.id,
    required this.stargazerId,
    required this.status,
    required this.stargazer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StarRequest.fromJson(Map<String, dynamic> json) {
    return StarRequest(
      id: json['id'] as String,
      stargazerId: json['stargazerId'] as String,
      status: json['status'] as String,
      stargazer: StarRequestStargazer.fromJson(
        json['stargazer'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
