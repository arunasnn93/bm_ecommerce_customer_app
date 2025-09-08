import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/file_data.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';

/// Universal upload service that works on all platforms
class UniversalUploadService {
  /// Upload order with items and optional image
  static Future<Map<String, dynamic>> uploadOrder({
    required List<Map<String, dynamic>> items,
    FileData? imageData,
    Map<String, String>? additionalFields,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.apiVersion}/api/orders');
      
      // Debug logging
      print('🔧 UniversalUploadService URL Construction:');
      print('   AppConfig.baseUrl: ${AppConfig.baseUrl}');
      print('   AppConfig.apiVersion: ${AppConfig.apiVersion}');
      print('   Final URL: $uri');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      
      // Add items as JSON
      request.fields['items'] = _encodeItemsToJson(items);
      
      // Add additional fields with proper formatting
      if (additionalFields != null) {
        additionalFields.forEach((key, value) {
          if (key == 'delivery_phone') {
            // Format phone number using helper function
            final formattedPhone = _formatPhoneNumber(value);
            request.fields[key] = formattedPhone;
            print('   📞 Phone formatting: "$value" -> "$formattedPhone"');
          } else {
            request.fields[key] = value;
          }
        });
      }
      
      // Add image if provided
      if (imageData != null) {
        final multipartFile = http.MultipartFile.fromBytes(
          'image',
          imageData.bytes,
          filename: imageData.name,
          contentType: MediaType.parse(imageData.contentType),
        );
        request.files.add(multipartFile);
      }
      
      // Add authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseResponse(response.body);
      } else {
        throw UploadException(
          'Upload failed with status ${response.statusCode}: ${response.body}'
        );
      }
    } catch (e) {
      if (e is UploadException) rethrow;
      throw UploadException('Upload failed: $e');
    }
  }

  /// Upload multiple files
  static Future<Map<String, dynamic>> uploadFiles({
    required List<FileData> files,
    Map<String, String>? additionalFields,
    String endpoint = '/upload',
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.apiVersion}$endpoint');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', uri);
      
      // Add files
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final multipartFile = http.MultipartFile.fromBytes(
          'file_$i',
          file.bytes,
          filename: file.name,
          contentType: MediaType.parse(file.contentType),
        );
        request.files.add(multipartFile);
      }
      
      // Add additional fields
      if (additionalFields != null) {
        additionalFields.forEach((key, value) {
          request.fields[key] = value;
        });
      }
      
      // Add authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseResponse(response.body);
      } else {
        throw UploadException(
          'Upload failed with status ${response.statusCode}: ${response.body}'
        );
      }
    } catch (e) {
      if (e is UploadException) rethrow;
      throw UploadException('Upload failed: $e');
    }
  }

  /// Upload single file
  static Future<Map<String, dynamic>> uploadFile({
    required FileData file,
    Map<String, String>? additionalFields,
    String endpoint = '/upload',
  }) async {
    return uploadFiles(
      files: [file],
      additionalFields: additionalFields,
      endpoint: endpoint,
    );
  }

  /// Encode items list to JSON string
  static String _encodeItemsToJson(List<Map<String, dynamic>> items) {
    // Use proper JSON encoding
    return jsonEncode(items);
  }

  /// Parse response body
  static Map<String, dynamic> _parseResponse(String body) {
    try {
      // Parse JSON response from API
      final Map<String, dynamic> parsedResponse = jsonDecode(body);
      
      print('🔍 Raw API Response: $body');
      print('📋 Parsed Response: $parsedResponse');
      
      return parsedResponse;
    } catch (e) {
      print('❌ JSON Parse Error: $e');
      print('📄 Raw Response Body: $body');
      
      // If JSON parsing fails, return the raw body for debugging
      return {
        'success': false,
        'message': 'Failed to parse JSON response: $e',
        'data': body,
        'raw_response': body,
      };
    }
  }

  /// Format phone number for API compatibility
  /// Removes +, spaces, and country code 91 to match API expectations
  static String _formatPhoneNumber(String phoneNumber) {
    return phoneNumber
        .replaceAll('+', '')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('91', ''); // Remove India country code
  }
}

/// Exception class for upload errors
class UploadException implements Exception {
  final String message;
  
  const UploadException(this.message);
  
  @override
  String toString() => 'UploadException: $message';
}
