import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static Future<void> saveName(String firstName, String lastName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
  }

  static Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('firstName');
  }

  static Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastName');
  }

  static Future<void> saveStargazerIdAndCreatedAt(
    String id,
    String createdAt,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stargazerId', id);
    await prefs.setString('stargazerCreatedAt', createdAt);
  }

  static Future<String?> getStargazerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('stargazerId');
  }

  static Future<String?> getStargazerCreatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('stargazerCreatedAt');
  }
}
