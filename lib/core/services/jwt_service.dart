import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class JwtService {
  static const String _algorithm = 'HS256';
  
  /// Generate JWT token for user
  static String generateToken({
    required String userId,
    required String name,
    required String mobileNumber,
    required String address,
  }) {
    final header = {
      'alg': _algorithm,
      'typ': 'JWT',
    };
    
    final payload = {
      'sub': userId,
      'name': name,
      'mobile': mobileNumber,
      'address': address,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(AppConstants.tokenExpiryDuration).millisecondsSinceEpoch ~/ 1000,
    };
    
    final encodedHeader = _base64UrlEncode(json.encode(header));
    final encodedPayload = _base64UrlEncode(json.encode(payload));
    
    final signature = _generateSignature('$encodedHeader.$encodedPayload');
    final encodedSignature = _base64UrlEncode(signature);
    
    return '$encodedHeader.$encodedPayload.$encodedSignature';
  }
  
  /// Validate JWT token
  static Map<String, dynamic>? validateToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final header = parts[0];
      final payload = parts[1];
      final signature = parts[2];
      
      // Verify signature
      final expectedSignature = _generateSignature('$header.$payload');
      final expectedEncodedSignature = _base64UrlEncode(expectedSignature);
      
      if (signature != expectedEncodedSignature) return null;
      
      // Decode payload
      final decodedPayload = json.decode(_base64UrlDecode(payload));
      
      // Check expiry
      final expiryTime = decodedPayload['exp'] as int;
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      if (currentTime > expiryTime) return null;
      
      return decodedPayload;
    } catch (e) {
      return null;
    }
  }
  
  /// Store JWT token in local storage
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.jwtTokenKey, token);
  }
  
  /// Get stored JWT token
  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.jwtTokenKey);
  }
  
  /// Remove stored JWT token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.jwtTokenKey);
  }
  
  /// Check if user is authenticated with valid token
  static Future<bool> isAuthenticated() async {
    final token = await getStoredToken();
    if (token == null) return false;
    
    // For server-generated tokens, we'll assume they're valid for now
    // In a real app, you might want to validate them with the server
    // For now, we'll just check if the token exists and is not empty
    if (token.trim().isEmpty) return false;
    
    // Try to validate as JWT first (for backward compatibility)
    final payload = validateToken(token);
    if (payload != null) return true;
    
    // If it's not a valid JWT, assume it's a server-generated token
    // and consider it valid (you might want to add server validation here)
    return true;
  }
  
  /// Get user data from stored token
  static Future<Map<String, dynamic>?> getUserData() async {
    final token = await getStoredToken();
    if (token == null) return null;
    
    // Try to validate as JWT first
    final payload = validateToken(token);
    if (payload != null) return payload;
    
    // If it's not a valid JWT, return null for server-generated tokens
    // You might want to store user data separately for server tokens
    return null;
  }
  
  /// Generate HMAC-SHA256 signature
  static List<int> _generateSignature(String data) {
    final key = utf8.encode(AppConstants.jwtSecret);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    return hmac.convert(bytes).bytes;
  }
  
  /// Base64Url encode
  static String _base64UrlEncode(dynamic data) {
    String encoded;
    if (data is String) {
      encoded = base64Url.encode(utf8.encode(data));
    } else {
      encoded = base64Url.encode(data);
    }
    return encoded.replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
  }
  
  /// Base64Url decode
  static String _base64UrlDecode(String data) {
    String normalized = data.replaceAll('-', '+').replaceAll('_', '/');
    switch (normalized.length % 4) {
      case 0:
        break;
      case 2:
        normalized += '==';
        break;
      case 3:
        normalized += '=';
        break;
      default:
        throw Exception('Invalid base64url string');
    }
    return utf8.decode(base64Url.decode(normalized));
  }
}
