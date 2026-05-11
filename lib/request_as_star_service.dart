import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/request_as_star_response.dart';

class RequestAsStarService {
  static Future<RequestAsStarResponse> requestAsStar({
    required String stargazerId,
  }) async {
    final url =
        'https://dev-mab.clearfocus.in/api/stargazers/request-as-star-v1';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'stargazerId': stargazerId}),
    );
    return RequestAsStarResponse.fromJson(jsonDecode(response.body));
  }
}
