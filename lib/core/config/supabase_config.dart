import 'package:flutter/foundation.dart';

/// Supabase configuration for real-time notifications
class SupabaseConfig {
  // TODO: Replace these with your actual Supabase project credentials
  // You can find these in your Supabase project settings
  static const String supabaseUrl = 'https://fitobjouvvxbpqdcgxvg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpdG9iam91dnZ4YnBxZGNneHZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU4OTMyMDEsImV4cCI6MjA3MTQ2OTIwMX0.Z1aE0WGGbe3xtXg6D-ThU4z0EnC9ncsOA1C_4rq4DxA';
  
  /// Check if Supabase is properly configured
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty && 
           supabaseAnonKey.isNotEmpty &&
           supabaseUrl.contains('supabase.co') &&
           supabaseAnonKey.startsWith('eyJ');
  }
  
  /// Get configuration status for debugging
  static Map<String, dynamic> get configStatus {
    return {
      'isConfigured': isConfigured,
      'url': supabaseUrl,
      'hasAnonKey': supabaseAnonKey.isNotEmpty && supabaseAnonKey != 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpdG9iam91dnZ4YnBxZGNneHZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU4OTMyMDEsImV4cCI6MjA3MTQ2OTIwMX0.Z1aE0WGGbe3xtXg6D-ThU4z0EnC9ncsOA1C_4rq4DxA',
      'platform': kIsWeb ? 'web' : 'mobile',
    };
  }
}
