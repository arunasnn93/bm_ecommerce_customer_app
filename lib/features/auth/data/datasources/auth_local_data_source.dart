import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthResult(AuthResultModel authResult);
  Future<AuthResultModel?> getCachedAuthResult();
  Future<void> clearCachedAuthResult();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  AuthLocalDataSourceImpl(this.sharedPreferences);
  
  @override
  Future<void> cacheAuthResult(AuthResultModel authResult) async {
    final authData = {
      'user': authResult.user.toJson(),
      'token': authResult.token,
      'expires_at': authResult.expiresAt.toIso8601String(),
    };
    
    await sharedPreferences.setString(AppConstants.tokenKey, authResult.token);
    await sharedPreferences.setString(AppConstants.userKey, jsonEncode(authData));
  }
  
  @override
  Future<AuthResultModel?> getCachedAuthResult() async {
    try {
      final userData = sharedPreferences.getString(AppConstants.userKey);
      if (userData != null) {
        final authData = jsonDecode(userData) as Map<String, dynamic>;
        return AuthResultModel.fromJson(authData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> clearCachedAuthResult() async {
    await sharedPreferences.remove(AppConstants.tokenKey);
    await sharedPreferences.remove(AppConstants.userKey);
  }
  
  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }
  
  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userData = sharedPreferences.getString(AppConstants.userKey);
      if (userData != null) {
        final userJson = jsonDecode(userData) as Map<String, dynamic>;
        return UserModel.fromJson(userJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> clearCachedUser() async {
    await sharedPreferences.remove(AppConstants.userKey);
  }
}
