class AppConstants {
  static const String appName = 'Beena Mart';
  static const String appVersion = '1.0.0';
  
  // API Constants
  static const String baseUrl = 'https://api.groshly.com'; // Updated API URL
  static const String apiVersion = '/api';
  
  // Auth API Endpoints
  static const String sendOtpEndpoint = '/auth/send-otp';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String checkUserExistsEndpoint = '/auth/check-user';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  
  // Store API Endpoints
  static const String storeImagesEndpoint = '/api/store-images';
  static const String userProfileEndpoint = '/user/profile';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String mobileNumberKey = 'mobile_number';
  static const String jwtTokenKey = 'jwt_token';
  
  // JWT Constants
  static const Duration tokenExpiryDuration = Duration(days: 60); // 2 months
  static const String jwtSecret = 'your_jwt_secret_key_here'; // In production, use environment variable
  
  // Validation
  static const int mobileNumberLength = 10;
  static const int otpLength = 6;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
