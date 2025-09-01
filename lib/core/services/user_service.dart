import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../features/auth/data/models/user_model.dart';
import 'jwt_service.dart';

class UserService {
  /// Get current user's name from stored data
  static Future<String?> getCurrentUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(AppConstants.userKey);
      
      if (userData == null) return null;
      
      final userJson = jsonDecode(userData) as Map<String, dynamic>;
      
      // Check if it's stored as a nested object (with 'user' key)
      if (userJson.containsKey('user')) {
        final nestedUserData = userJson['user'] as Map<String, dynamic>;
        return nestedUserData['name'] as String?;
      }
      
      // Check if it's stored directly as a user object
      if (userJson.containsKey('name')) {
        return userJson['name'] as String?;
      }
      
      // Try to parse as UserModel
      final userModel = UserModel.fromJson(userJson);
      return userModel.name;
    } catch (e) {
      print('❌ Error getting user name: $e');
      return null;
    }
  }
  
  /// Get current user's full data
  static Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(AppConstants.userKey);
      
      if (userData == null) return null;
      
      final userJson = jsonDecode(userData) as Map<String, dynamic>;
      
      // Check if it's stored as a nested object (with 'user' key)
      if (userJson.containsKey('user')) {
        final nestedUserData = userJson['user'] as Map<String, dynamic>;
        return UserModel.fromJson(nestedUserData);
      }
      
      // Try to parse as UserModel directly
      return UserModel.fromJson(userJson);
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }
  
  /// Get a greeting based on time of day
  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
  
  /// Get personalized welcome message
  static Future<String> getWelcomeMessage() async {
    final userName = await getCurrentUserName();
    final greeting = getTimeBasedGreeting();
    
    if (userName != null && userName.isNotEmpty) {
      // Extract first name from full name
      final firstName = userName.split(' ').first;
      return '$greeting, $firstName!';
    } else {
      return '$greeting!';
    }
  }
  
  /// Get user address from cached user data
  static Future<String?> getUserAddress() async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        return user.address;
      }
      return null;
    } catch (e) {
      print('❌ Error getting user address: $e');
      return null;
    }
  }
}
