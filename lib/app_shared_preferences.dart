import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefServices {
  static SharedPreferences? prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static const _stargazerId = 'stargazerId';
  static const _stargazerCreatedAt = 'stargazerCreatedAt';

  static Future setStargazerId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stargazerId, id);
  }

  static Future<String?> getStargazerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_stargazerId);
  }

  static Future setStargazerCreatedAt(String createdAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stargazerCreatedAt, createdAt);
  }

  static Future<String?> getStargazerCreatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_stargazerCreatedAt);
  }
}
