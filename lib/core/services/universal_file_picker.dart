import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/file_data.dart';
import 'universal_web_file_picker.dart';

/// Platform-agnostic file picker service
class UniversalFilePicker {
  /// Pick an image file that works on all platforms
  static Future<FileData?> pickImage({
    int? maxFileSize,
    List<String>? allowedExtensions,
    ImageSource? source, // Camera or gallery preference for mobile
  }) async {
    try {
      if (kIsWeb) {
        return await _pickImageWeb(
          maxFileSize: maxFileSize,
          allowedExtensions: allowedExtensions,
        );
      } else {
        return await _pickImageMobile(
          maxFileSize: maxFileSize,
          allowedExtensions: allowedExtensions,
          source: source,
        );
      }
    } catch (e) {
      throw FilePickerException('Failed to pick image: $e');
    }
  }

  /// Pick any file type that works on all platforms
  static Future<FileData?> pickFile({
    int? maxFileSize,
    List<String>? allowedExtensions,
  }) async {
    try {
      if (kIsWeb) {
        return await _pickFileWeb(
          maxFileSize: maxFileSize,
          allowedExtensions: allowedExtensions,
        );
      } else {
        return await _pickFileMobile(
          maxFileSize: maxFileSize,
          allowedExtensions: allowedExtensions,
        );
      }
    } catch (e) {
      throw FilePickerException('Failed to pick file: $e');
    }
  }

  /// Web implementation for image picking
  static Future<FileData?> _pickImageWeb({
    int? maxFileSize,
    List<String>? allowedExtensions,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('Web implementation not available on this platform');
    }
    
    return await UniversalWebFilePicker.pickImage(
      maxFileSize: maxFileSize,
      allowedExtensions: allowedExtensions,
    );
  }

  /// Web implementation for file picking
  static Future<FileData?> _pickFileWeb({
    int? maxFileSize,
    List<String>? allowedExtensions,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('Web implementation not available on this platform');
    }
    
    return await UniversalWebFilePicker.pickFile(
      maxFileSize: maxFileSize,
      allowedExtensions: allowedExtensions,
    );
  }

  /// Mobile implementation for image picking
  static Future<FileData?> _pickImageMobile({
    int? maxFileSize,
    List<String>? allowedExtensions,
    ImageSource? source,
  }) async {
    // If a specific source is provided, use image_picker for camera/gallery
    if (source != null) {
      return await _pickImageWithImagePicker(source, maxFileSize);
    }

    // Otherwise, use file picker for file selection
    FilePickerResult? result;
    
    if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
      // Use custom type with specific extensions
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: allowedExtensions,
      );
    } else {
      // Use image type for general image picking
      result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
    }

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      Uint8List bytes;
      
      // Try to get bytes from file.bytes first, fallback to reading from path
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null && !kIsWeb) {
        // Read bytes from file path (mobile only)
        final ioFile = io.File(file.path!);
        bytes = await ioFile.readAsBytes();
      } else {
        throw FilePickerException('Failed to read file bytes - no bytes or path available');
      }

      // Check file size if specified
      if (maxFileSize != null && bytes.length > maxFileSize) {
        throw FilePickerException(
          'File size exceeds limit of ${(maxFileSize / (1024 * 1024)).toStringAsFixed(1)}MB'
        );
      }

      return FileData(
        bytes: bytes,
        name: file.name,
        size: bytes.length,
        mimeType: _getMimeTypeFromExtension(file.extension),
        extension: file.extension,
      );
    }

    return null;
  }

  /// Pick image using image_picker (camera/gallery)
  static Future<FileData?> _pickImageWithImagePicker(
    ImageSource source,
    int? maxFileSize,
  ) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      
      // Check file size if specified
      if (maxFileSize != null && bytes.length > maxFileSize) {
        throw FilePickerException(
          'File size exceeds limit of ${(maxFileSize / (1024 * 1024)).toStringAsFixed(1)}MB'
        );
      }

      return FileData(
        bytes: bytes,
        name: pickedFile.name,
        size: bytes.length,
        mimeType: pickedFile.mimeType ?? 'image/jpeg',
        extension: pickedFile.path.split('.').last.toLowerCase(),
      );
    }

    return null;
  }

  /// Mobile implementation for file picking
  static Future<FileData?> _pickFileMobile({
    int? maxFileSize,
    List<String>? allowedExtensions,
  }) async {
    // For file picking on mobile, use appropriate FileType
    FilePickerResult? result;
    
    if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
      // Use custom type with specific extensions
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: allowedExtensions,
      );
    } else {
      // Use any type for general file picking
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
    }

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      Uint8List bytes;
      
      // Try to get bytes from file.bytes first, fallback to reading from path
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null && !kIsWeb) {
        // Read bytes from file path (mobile only)
        final ioFile = io.File(file.path!);
        bytes = await ioFile.readAsBytes();
      } else {
        throw FilePickerException('Failed to read file bytes - no bytes or path available');
      }

      // Check file size if specified
      if (maxFileSize != null && bytes.length > maxFileSize) {
        throw FilePickerException(
          'File size exceeds limit of ${(maxFileSize / (1024 * 1024)).toStringAsFixed(1)}MB'
        );
      }

      return FileData(
        bytes: bytes,
        name: file.name,
        size: bytes.length,
        mimeType: _getMimeTypeFromExtension(file.extension),
        extension: file.extension,
      );
    }

    return null;
  }


  /// Get MIME type from file extension
  static String? _getMimeTypeFromExtension(String? extension) {
    if (extension == null) return null;
    
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}

/// Exception class for file picker errors
class FilePickerException implements Exception {
  final String message;
  
  const FilePickerException(this.message);
  
  @override
  String toString() => 'FilePickerException: $message';
}

