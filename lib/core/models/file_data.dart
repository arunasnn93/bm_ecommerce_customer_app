import 'dart:typed_data';

/// Universal file data model that works across all platforms
class FileData {
  final Uint8List bytes;
  final String name;
  final int size;
  final String? mimeType;
  final String? extension;

  const FileData({
    required this.bytes,
    required this.name,
    required this.size,
    this.mimeType,
    this.extension,
  });

  /// Get file extension from filename
  String get fileExtension {
    if (extension != null) return extension!;
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Get MIME type based on file extension
  String get contentType {
    if (mimeType != null) return mimeType!;
    
    switch (fileExtension) {
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

  /// Check if file is an image
  bool get isImage {
    return contentType.startsWith('image/');
  }

  /// Check if file size is within limits (default 10MB)
  bool isSizeValid({int maxSizeInMB = 10}) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return size <= maxSizeInBytes;
  }

  /// Get human readable file size
  String get humanReadableSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  String toString() {
    return 'FileData(name: $name, size: $humanReadableSize, type: $contentType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileData &&
        other.name == name &&
        other.size == size &&
        other.mimeType == mimeType;
  }

  @override
  int get hashCode {
    return name.hashCode ^ size.hashCode ^ mimeType.hashCode;
  }
}
