import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants/api_constants.dart';
import 'models/terms_response.dart';

class TermsService {
  static Future<TermsResponse> fetchTerms() async {
    final url = '${AppConstant.mabBaseURLTerms}auth/terms-v2';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    );
    return TermsResponse.fromJson(jsonDecode(response.body));
  }
}
