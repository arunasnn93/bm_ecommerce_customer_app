import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../../../core/models/file_data.dart';
import '../../../../core/services/universal_file_picker.dart';
import '../../../../core/services/universal_upload_service.dart';

/// Universal order service that works across all platforms
class UniversalOrderService {
  /// Create order with items and optional image upload
  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    FileData? imageData,
    Map<String, String>? additionalFields,
  }) async {
    try {
      // Validate items
      if (items.isEmpty) {
        throw OrderException('Items list cannot be empty');
      }

      // Validate image if provided
      if (imageData != null) {
        if (!imageData.isImage) {
          throw OrderException('Uploaded file must be an image');
        }
        
        if (!imageData.isSizeValid(maxSizeInMB: 10)) {
          throw OrderException('Image size must be less than 10MB');
        }
      }

      // Upload order
      final result = await UniversalUploadService.uploadOrder(
        items: items,
        imageData: imageData,
        additionalFields: additionalFields,
      );

      return result;
    } catch (e) {
      if (e is OrderException) rethrow;
      throw OrderException('Failed to create order: $e');
    }
  }

  /// Pick and upload image for order
  static Future<FileData?> pickOrderImage() async {
    try {
      return await UniversalFilePicker.pickImage(
        maxFileSize: 10 * 1024 * 1024, // 10MB
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      );
    } catch (e) {
      throw OrderException('Failed to pick image: $e');
    }
  }

  /// Pick and upload any file for order
  static Future<FileData?> pickOrderFile() async {
    try {
      return await UniversalFilePicker.pickFile(
        maxFileSize: 10 * 1024 * 1024, // 10MB
      );
    } catch (e) {
      throw OrderException('Failed to pick file: $e');
    }
  }

  /// Validate order items
  static void validateOrderItems(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      throw OrderException('Order must contain at least one item');
    }

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      
      if (!item.containsKey('name') || item['name'] == null || item['name'].toString().isEmpty) {
        throw OrderException('Item ${i + 1} must have a name');
      }
      
      if (!item.containsKey('quantity') || item['quantity'] == null) {
        throw OrderException('Item ${i + 1} must have a quantity');
      }
      
      final quantity = item['quantity'];
      if (quantity is! int || quantity <= 0) {
        throw OrderException('Item ${i + 1} quantity must be a positive integer');
      }
      
      if (!item.containsKey('price') || item['price'] == null) {
        throw OrderException('Item ${i + 1} must have a price');
      }
      
      final price = item['price'];
      if (price is! num || price < 0) {
        throw OrderException('Item ${i + 1} price must be a non-negative number');
      }
    }
  }

  /// Create order item map
  static Map<String, dynamic> createOrderItem({
    required String name,
    required int quantity,
    required double price,
    String? description,
    String? category,
    Map<String, dynamic>? metadata,
  }) {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Get platform-specific error message
  static String getPlatformErrorMessage(dynamic error) {
    if (kIsWeb) {
      if (error.toString().contains('FileUploadInputElement')) {
        return 'File picker is not supported in this browser. Please try a different browser.';
      }
      if (error.toString().contains('CORS')) {
        return 'Network error: Please check your internet connection and try again.';
      }
    }
    
    if (error.toString().contains('permission')) {
      return 'Permission denied: Please allow file access and try again.';
    }
    
    if (error.toString().contains('size')) {
      return 'File too large: Please select a smaller file (max 10MB).';
    }
    
    if (error.toString().contains('network')) {
      return 'Network error: Please check your internet connection and try again.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
}

/// Exception class for order-related errors
class OrderException implements Exception {
  final String message;
  
  const OrderException(this.message);
  
  @override
  String toString() => 'OrderException: $message';
}
