import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import '../models/file_data.dart';

/// Web-specific file picker implementation
class WebFilePickerImpl {
  /// Pick an image file on web
  static Future<FileData?> pickImage({
    int? maxFileSize,
    List<String>? allowedExtensions,
    bool useCamera = false,
  }) async {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = false;

    // Enable camera capture on mobile devices
    if (useCamera && _isMobileDevice()) {
      input.setAttribute('capture', 'environment'); // Use rear camera
    }

    // Create a hidden input element
    input.style.display = 'none';
    html.document.body?.append(input);

    try {
      // Trigger file picker
      input.click();

      // Wait for file selection
      final completer = Completer<FileData?>();
      
      input.onChange.listen((event) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          
          // Validate file size if specified
          if (maxFileSize != null && file.size > maxFileSize) {
            completer.completeError(
              'File size exceeds limit of ${(maxFileSize / (1024 * 1024)).toStringAsFixed(1)}MB'
            );
            return;
          }
          
          // Validate file extension if specified
          if (allowedExtensions != null) {
            final extension = _getExtensionFromName(file.name);
            if (extension == null || !allowedExtensions.contains(extension.toLowerCase())) {
              completer.completeError(
                'File type not allowed. Allowed types: ${allowedExtensions.join(', ')}'
              );
              return;
            }
          }
          
          _readFileAsBytes(file).then((bytes) {
            final fileData = FileData(
              bytes: bytes,
              name: file.name,
              size: file.size,
              mimeType: file.type,
              extension: _getExtensionFromName(file.name),
            );
            completer.complete(fileData);
          }).catchError((error) {
            completer.completeError(error);
          });
        } else {
          completer.complete(null);
        }
      });

      return await completer.future;
    } finally {
      // Clean up
      input.remove();
    }
  }

  /// Pick any file on web
  static Future<FileData?> pickFile({
    int? maxFileSize,
    List<String>? allowedExtensions,
  }) async {
    final input = html.FileUploadInputElement()
      ..multiple = false;

    // Create a hidden input element
    input.style.display = 'none';
    html.document.body?.append(input);

    try {
      // Trigger file picker
      input.click();

      // Wait for file selection
      final completer = Completer<FileData?>();
      
      input.onChange.listen((event) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          
          // Validate file size if specified
          if (maxFileSize != null && file.size > maxFileSize) {
            completer.completeError(
              'File size exceeds limit of ${(maxFileSize / (1024 * 1024)).toStringAsFixed(1)}MB'
            );
            return;
          }
          
          // Validate file extension if specified
          if (allowedExtensions != null) {
            final extension = _getExtensionFromName(file.name);
            if (extension == null || !allowedExtensions.contains(extension.toLowerCase())) {
              completer.completeError(
                'File type not allowed. Allowed types: ${allowedExtensions.join(', ')}'
              );
              return;
            }
          }
          
          _readFileAsBytes(file).then((bytes) {
            final fileData = FileData(
              bytes: bytes,
              name: file.name,
              size: file.size,
              mimeType: file.type,
              extension: _getExtensionFromName(file.name),
            );
            completer.complete(fileData);
          }).catchError((error) {
            completer.completeError(error);
          });
        } else {
          completer.complete(null);
        }
      });

      return await completer.future;
    } finally {
      // Clean up
      input.remove();
    }
  }

  /// Read file as bytes using FileReader
  static Future<Uint8List> _readFileAsBytes(html.File file) async {
    final completer = Completer<Uint8List>();
    final reader = html.FileReader();

    reader.onLoad.listen((event) {
      final result = reader.result;
      if (result is List<int>) {
        completer.complete(Uint8List.fromList(result));
      } else {
        completer.completeError('Failed to read file as bytes');
      }
    });

    reader.onError.listen((event) {
      completer.completeError('File read error: ${reader.error}');
    });

    reader.readAsArrayBuffer(file);
    return completer.future;
  }

  /// Pick image with camera (front or rear) on mobile web
  static Future<FileData?> pickImageWithCamera({
    int? maxFileSize,
    bool useFrontCamera = false,
  }) async {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = false;

    // Enable camera capture on mobile devices
    if (_isMobileDevice()) {
      // Use 'user' for front camera, 'environment' for rear camera
      input.setAttribute('capture', useFrontCamera ? 'user' : 'environment');
    }

    // Create a hidden input element
    input.style.display = 'none';
    html.document.body?.append(input);

    try {
      // Trigger file picker
      input.click();

      // Wait for file selection
      final completer = Completer<FileData?>();
      
      input.onChange.listen((event) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          
          // Validate file size if specified
          if (maxFileSize != null && file.size > maxFileSize) {
            completer.completeError(
              'File size exceeds limit of ${(maxFileSize / (1024 * 1024)).toStringAsFixed(1)}MB'
            );
            return;
          }
          
          _readFileAsBytes(file).then((bytes) {
            final fileData = FileData(
              bytes: bytes,
              name: file.name,
              size: file.size,
              mimeType: file.type,
              extension: _getExtensionFromName(file.name),
            );
            completer.complete(fileData);
          }).catchError((error) {
            completer.completeError(error);
          });
        } else {
          completer.complete(null);
        }
      });

      return await completer.future;
    } finally {
      // Clean up
      input.remove();
    }
  }

  /// Check if the current device is a mobile device
  static bool _isMobileDevice() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('mobile') || 
           userAgent.contains('android') || 
           userAgent.contains('iphone') || 
           userAgent.contains('ipad') || 
           userAgent.contains('tablet');
  }

  /// Get file extension from filename
  static String? _getExtensionFromName(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : null;
  }
}
