import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stargazer.dart';
import '../models/star_request.dart';
import 'admin_auth_service.dart';

class StargazerService {
  static const _baseUrl = 'https://dev-mab.clearfocus.in';

  String _apiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Map<String, dynamic> _listPayload({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return {
      if (searchQuery != null && searchQuery.trim().isNotEmpty)
        'search': searchQuery.trim(),
      if (startDate != null) 'startDate': _apiDate(startDate),
      if (endDate != null) 'endDate': _apiDate(endDate),
    };
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await AdminAuthService.getToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception('Auth token missing. Please login again.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Stargazer>> fetchStargazers({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/stargazers/list-v1');
    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode(
        _listPayload(
          searchQuery: searchQuery,
          startDate: startDate,
          endDate: endDate,
        ),
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List<dynamic> list = body['data']['stargazers'];
        return list.map((e) => Stargazer.fromJson(e)).toList();
      }
      throw Exception(body['message'] ?? 'API returned success=false');
    } else {
      throw Exception(
        'Failed to load stargazers: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> deleteStargazer(String id) async {
    final uri = Uri.parse('$_baseUrl/api/stargazers/delete-v1');
    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['success'] == true) return;
      throw Exception(body['message'] ?? 'Delete failed');
    } else {
      throw Exception(
        'Failed to delete stargazer: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<List<StarRequest>> fetchStarRequests({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/stargazers/star-requests/list-v1');
    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode(
        _listPayload(
          searchQuery: searchQuery,
          startDate: startDate,
          endDate: endDate,
        ),
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List<dynamic> list = body['data']['requests'];
        return list.map((e) => StarRequest.fromJson(e)).toList();
      }
      throw Exception(body['message'] ?? 'API returned success=false');
    } else {
      throw Exception(
        'Failed to load star requests: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> deleteStarRequest(String id) async {
    final uri = Uri.parse('$_baseUrl/api/stargazers/star-requests/delete-v1');
    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['success'] == true) return;
      throw Exception(body['message'] ?? 'Delete failed');
    } else {
      throw Exception(
        'Failed to delete star request: ${response.statusCode} ${response.body}',
      );
    }
  }
}
