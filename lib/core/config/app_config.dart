enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static Environment environment = Environment.production;
  
  // API Configuration
  static String get baseUrl {
    switch (environment) {
      case Environment.development:
        return 'http://10.0.2.2:3000'; // Android emulator localhost
      case Environment.staging:
        return 'https://staging-api.beenamart.com';
      case Environment.production:
        return 'https://bm-ecommerce-api-production.up.railway.app';
    }
  }
  
  // Supabase Storage Configuration
  static String get supabaseStorageUrl {
    switch (environment) {
      case Environment.development:
        return 'https://fitobjouvvxbpqdcgxvg.supabase.co/storage/v1/object/public'; // Replace with your Supabase project URL
      case Environment.staging:
        return 'https://fitobjouvvxbpqdcgxvg.supabase.co/storage/v1/object/public'; // Replace with your staging Supabase URL
      case Environment.production:
        return 'https://fitobjouvvxbpqdcgxvg.supabase.co/storage/v1/object/public'; // Replace with your production Supabase URL
    }
  }
  
  static String get apiVersion {
    switch (environment) {
      case Environment.development:
        return ''; // No /v1 prefix for localhost:3000
      case Environment.staging:
        return '/v1'; // Add /v1 prefix for staging
      case Environment.production:
        return ''; // No /v1 prefix for production
    }
  }
  
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
  static const Duration connectionTimeout = Duration(seconds: 60); // Increased for production
  static const Duration receiveTimeout = Duration(seconds: 60); // Increased for production
  
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
        return true; // Temporarily enable logging for debugging
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
