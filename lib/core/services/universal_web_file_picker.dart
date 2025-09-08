import 'package:flutter/foundation.dart';
import '../models/file_data.dart';

// Conditional imports for web support
import 'web_file_picker_stub.dart'
    if (dart.library.html) 'web_file_picker_impl.dart';

/// Universal web file picker service that works across all platforms
class UniversalWebFilePicker {
  /// Pick an image file that works on web
  static Future<FileData?> pickImage({
    int? maxFileSize,
    List<String>? allowedExtensions,
    bool useCamera = false,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('Web file picker is only available on web platform');
    }
    
    return await WebFilePickerImpl.pickImage(
      maxFileSize: maxFileSize,
      allowedExtensions: allowedExtensions,
      useCamera: useCamera,
    );
  }

  /// Pick image with camera on mobile web (front or rear camera)
  static Future<FileData?> pickImageWithCamera({
    int? maxFileSize,
    bool useFrontCamera = false,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('Web file picker is only available on web platform');
    }
    
    return await WebFilePickerImpl.pickImageWithCamera(
      maxFileSize: maxFileSize,
      useFrontCamera: useFrontCamera,
    );
  }

  /// Pick any file type that works on web
  static Future<FileData?> pickFile({
    int? maxFileSize,
    List<String>? allowedExtensions,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('Web file picker is only available on web platform');
    }
    
    return await WebFilePickerImpl.pickFile(
      maxFileSize: maxFileSize,
      allowedExtensions: allowedExtensions,
    );
  }
}
