import '../../../../core/models/file_data.dart';

/// Stub implementation for non-web platforms
Future<FileData?> _pickImageWebImpl() async {
  throw UnsupportedError('Web implementation not available on this platform');
}
