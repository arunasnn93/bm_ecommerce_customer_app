import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LogoutService {
  static Future<void> clearAllSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear authentication token
      await prefs.remove(AppConstants.tokenKey);
      
      // Clear user data
      await prefs.remove('user_data');
      await prefs.remove('user_name');
      await prefs.remove('user_mobile');
      await prefs.remove('user_address');
      
      // Clear any cached data
      await prefs.remove('cached_offers');
      await prefs.remove('cached_orders');
      await prefs.remove('cached_store_images');
      
      // Clear any other app-specific data
      await prefs.remove('last_login_time');
      await prefs.remove('app_settings');
      
      // Clear all keys (more thorough approach)
      await prefs.clear();
    } catch (e) {
      // Don't throw error, as logout should still proceed
      // Logout should succeed even if some data clearing fails
    }
  }
  
  static Future<void> clearUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear user preferences but keep app settings
      await prefs.remove('user_preferences');
      await prefs.remove('notification_settings');
      await prefs.remove('theme_preferences');
    } catch (e) {
      // Silently handle errors
    }
  }
}
