import 'dart:convert';
import 'package:http/http.dart' as http;

import 'constants/api_constants.dart';
import 'models/register_request.dart';
import 'register_response.dart';

class RegisterService {
  Future<RegisterResponse> registerauth(RegisterRequest requestModel) async {
    String url = "${AppConstant.mabBaseURL}stargazers/register-v1";

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestModel.toJson()),
    );

    // Handle all status codes with the same parser. A non-JSON body (e.g. a
    // gateway error page) throws, and the screen shows a friendly message.
    return RegisterResponse.fromJson(jsonDecode(response.body));
  }
}
