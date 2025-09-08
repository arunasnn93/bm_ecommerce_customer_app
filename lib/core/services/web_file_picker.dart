import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import '../models/file_data.dart';

/// Web-specific file picker implementation
class WebFilePicker {
  /// Pick an image file on web
  static Future<FileData?> pickImage() async {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
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
  static Future<FileData?> pickFile() async {
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

  /// Get file extension from filename
  static String? _getExtensionFromName(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : null;
  }
}
