import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/auth_models.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';

  final Logger _logger = Logger();

  // Save authentication data
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
    required int expiresIn,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Calculate expiry time
      final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));

      await Future.wait([
        prefs.setString(_accessTokenKey, accessToken),
        prefs.setString(_refreshTokenKey, refreshToken),
        prefs.setString(_userDataKey, jsonEncode(user.toJson())),
        prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String()),
      ]);

      _logger.d('Auth data saved successfully');
    } catch (e) {
      _logger.e('Error saving auth data: $e');
      rethrow;
    }
  }

  // Get access token
  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    } catch (e) {
      _logger.e('Error getting access token: $e');
      return null;
    }
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      _logger.e('Error getting refresh token: $e');
      return null;
    }
  }

  // Get user data
  Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userDataKey);

      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      }

      return null;
    } catch (e) {
      _logger.e('Error getting user data: $e');
      return null;
    }
  }

  // Save user data
  Future<void> saveUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, jsonEncode(user.toJson()));
      _logger.d('User data saved successfully');
    } catch (e) {
      _logger.e('Error saving user data: $e');
      rethrow;
    }
  }

  // Check if token is expired
  Future<bool> isTokenExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString(_tokenExpiryKey);

      if (expiryString == null) return true;

      final expiryTime = DateTime.parse(expiryString);
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      _logger.e('Error checking token expiry: $e');
      return true;
    }
  }

  // Update access token (for refresh flow)
  Future<void> updateAccessToken({
    required String accessToken,
    required int expiresIn,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));

      await Future.wait([
        prefs.setString(_accessTokenKey, accessToken),
        prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String()),
      ]);

      _logger.d('Access token updated successfully');
    } catch (e) {
      _logger.e('Error updating access token: $e');
      rethrow;
    }
  }

  // Clear all auth data (logout)
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.remove(_accessTokenKey),
        prefs.remove(_refreshTokenKey),
        prefs.remove(_userDataKey),
        prefs.remove(_tokenExpiryKey),
      ]);

      _logger.d('Auth data cleared successfully');
    } catch (e) {
      _logger.e('Error clearing auth data: $e');
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();

      return accessToken != null && refreshToken != null;
    } catch (e) {
      _logger.e('Error checking login status: $e');
      return false;
    }
  }
}
