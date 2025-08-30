enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static Environment environment = Environment.development;
  
  // API Configuration
  static String get baseUrl {
    switch (environment) {
      case Environment.development:
        return 'http://10.0.2.2:3000'; // Android emulator localhost
      case Environment.staging:
        return 'https://staging-api.beenamart.com';
      case Environment.production:
        return 'https://api.beenamart.com';
    }
  }
  
  static String get apiVersion => ''; // Remove /v1 prefix for localhost:3000
  
  // Feature Flags
  static bool get useDemoMode {
    switch (environment) {
      case Environment.development:
        return false; // Use real API in development for testing
      case Environment.staging:
        return false; // Use real API in staging
      case Environment.production:
        return false; // Use real API in production
    }
  }
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // OTP Configuration
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;
  static const int maxOtpAttempts = 3;
  
  // Logging
  static bool get enableLogging {
    switch (environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }
  
  // Debug Information
  static String get appInfo {
    return '''
    Environment: ${environment.name}
    Base URL: $baseUrl
    Demo Mode: $useDemoMode
    Logging: $enableLogging
    ''';
  }
}
