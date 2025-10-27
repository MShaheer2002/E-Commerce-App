import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _keyName = 'user_name';
  static const String _keyImage = 'user_image';
  static const String _keyEmail = 'user_email';

  /// Save user info locally
  Future<void> cacheProfile({
    required String name,
    required String imageUrl,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyImage, imageUrl);
    await prefs.setString(_keyEmail, email);
  }

  /// Load user info
  Future<Map<String, String?>> loadCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_name': prefs.getString(_keyName),
      'user_image': prefs.getString(_keyImage),
      'user_email': prefs.getString(_keyEmail),
    };
  }

  /// Clear all cached user info
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyImage);
    await prefs.remove(_keyEmail);
  }
}
