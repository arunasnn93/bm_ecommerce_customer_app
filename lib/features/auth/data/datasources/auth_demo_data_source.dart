import 'dart:async';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';

class AuthDemoDataSource {
  // Simulate network delay
  static const Duration _networkDelay = Duration(seconds: 1);
  
  // Demo user data
  static const Map<String, dynamic> _demoUser = {
    'id': '1',
    'name': 'Demo User',
    'mobile_number': '9876543210',
    'email': 'demo@beenamart.com',
    'profile_image': null,
    'created_at': '2024-01-01T00:00:00.000Z',
    'updated_at': '2024-01-01T00:00:00.000Z',
  };
  
  Future<void> sendOtp(String mobileNumber) async {
    await Future.delayed(_networkDelay);
    
    // Simulate success response
    // In real implementation, this would be an API call
    print('Demo: OTP sent to $mobileNumber');
  }
  
  Future<AuthResultModel> verifyOtp(String mobileNumber, String otp, {String? name, String? address}) async {
    await Future.delayed(_networkDelay);
    
    // Validate OTP (any 6-digit OTP works in demo)
    if (otp.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(otp)) {
      throw Exception('Invalid OTP format');
    }
    
    // Simulate successful verification
    final userData = Map<String, dynamic>.from(_demoUser);
    userData['mobile_number'] = mobileNumber;
    final user = UserModel.fromJson(userData);
    final authResult = AuthResultModel(
      user: user,
      token: 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
    
    print('Demo: OTP verified successfully for $mobileNumber');
    return authResult;
  }
  
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return null to simulate no logged-in user
    return null;
  }
  
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Demo: User logged out successfully');
  }
  
  Future<bool> isAuthenticated() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Always return false in demo mode
    return false;
  }
  
  Future<AuthResultModel> refreshToken() async {
    await Future.delayed(_networkDelay);
    
    // Simulate token refresh
    final user = UserModel.fromJson(_demoUser);
    final authResult = AuthResultModel(
      user: user,
      token: 'demo_refreshed_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
    
    print('Demo: Token refreshed successfully');
    return authResult;
  }
}
