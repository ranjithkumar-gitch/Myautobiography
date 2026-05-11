import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models/register_request.dart';
import 'register_response.dart';

class RegisterService {
  Future<RegisterResponse> registerauth(RegisterRequest requestModel) async {
    String url = "https://dev-mab.clearfocus.in/api/stargazers/register-v1";
    print("now printing register data");
    print(url);
    print(requestModel.toJson());

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestModel.toJson()),
      );

      print("response.body requestModel ${jsonEncode(requestModel.toJson())}");
      print("response.body register ${response.body}");
      print("response.body statusCode ${response.statusCode}");

      // Handle all status codes with the same parser
      return RegisterResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      print('registerauth exception: $e');
      rethrow;
    }
  }
}
