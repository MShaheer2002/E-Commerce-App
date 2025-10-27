import 'package:flutter/material.dart';
import 'package:e_commerce_app/core/cache.dart';

class CacheProvider extends ChangeNotifier {
  final CacheService _cache = CacheService();

  String? _name;
  String? _email;
  String? _imageUrl;
  bool _isLoaded = false;

  String? get name => _name;
  String? get email => _email;
  String? get imageUrl => _imageUrl;
  bool get isLoaded => _isLoaded;

  /// Load cached profile only once
  Future<void> loadCachedProfile() async {
    if (_isLoaded) return; // prevent reloading every time

    final data = await _cache.loadCachedProfile();
    _name = data['user_name'];
    _email = data['user_email'];
    _imageUrl = data['user_image'];
    _isLoaded = true;
    notifyListeners();
  }

  /// Save to cache and update state
  Future<void> updateProfile({
    required String name,
    required String email,
    required String imageUrl,
  }) async {
    await _cache.cacheProfile(name: name, email: email, imageUrl: imageUrl);
    _name = name;
    _email = email;
    _imageUrl = imageUrl;
    _isLoaded = true;
    notifyListeners();
  }

  /// Clear local cache + reset state
  Future<void> clearProfile() async {
    await _cache.clearCache();
    _name = null;
    _email = null;
    _imageUrl = null;
    _isLoaded = false;
    notifyListeners();
  }
}
