import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants/api_constants.dart';
import 'models/terms_response.dart';

class TermsService {
  static Future<TermsResponse> fetchTerms() => _fetch('auth/terms-v2');

  static Future<TermsResponse> fetchPrivacyPolicy() => _fetch('auth/policy-v2');

  static Future<TermsResponse> _fetch(String path) async {
    final url = '${AppConstant.mabBaseURLTerms}$path';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    );
    return TermsResponse.fromJson(jsonDecode(response.body));
  }
}
