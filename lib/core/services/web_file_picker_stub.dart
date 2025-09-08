import '../models/file_data.dart';

/// Stub implementation for non-web platforms
class WebFilePickerImpl {
  static Future<FileData?> pickImage({
    int? maxFileSize,
    List<String>? allowedExtensions,
    bool useCamera = false,
  }) async {
    throw UnsupportedError('Web file picker not available on this platform');
  }

  static Future<FileData?> pickImageWithCamera({
    int? maxFileSize,
    bool useFrontCamera = false,
  }) async {
    throw UnsupportedError('Web file picker not available on this platform');
  }

  static Future<FileData?> pickFile({
    int? maxFileSize,
    List<String>? allowedExtensions,
  }) async {
    throw UnsupportedError('Web file picker not available on this platform');
  }
}
