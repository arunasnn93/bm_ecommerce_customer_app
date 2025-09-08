# Universal File Upload Implementation Guide

## Overview

This implementation provides a universal file upload solution that works seamlessly across all platforms (Android, iOS, and Web) without the "MultipartFile is only supported where dart:io is available" error.

## Key Features

✅ **Platform Agnostic**: Works on Android, iOS, and Web  
✅ **Web Compatible**: Uses `MultipartFile.fromBytes()` instead of `fromPath()`  
✅ **Universal File Picker**: Platform-specific file selection with consistent API  
✅ **Error Handling**: Comprehensive error handling and user feedback  
✅ **File Validation**: Size limits, type validation, and MIME type detection  
✅ **Clean Architecture**: Well-separated concerns and maintainable code  

## Architecture

### 1. FileData Model (`lib/core/models/file_data.dart`)
Universal file representation that works across all platforms:
```dart
class FileData {
  final Uint8List bytes;      // File content as bytes
  final String name;          // Original filename
  final int size;             // File size in bytes
  final String? mimeType;     // MIME type
  final String? extension;    // File extension
}
```

### 2. Universal File Picker (`lib/core/services/universal_file_picker.dart`)
Platform-agnostic file selection service:
- **Web**: Uses `dart:html` FileUploadInputElement
- **Mobile**: Uses `file_picker` package
- **Conditional Imports**: Automatically selects correct implementation

### 3. Universal Upload Service (`lib/core/services/universal_upload_service.dart`)
Web-compatible multipart upload using `http.MultipartFile.fromBytes()`:
```dart
final multipartFile = http.MultipartFile.fromBytes(
  'image',
  imageData.bytes,
  filename: imageData.name,
  contentType: MediaType.parse(imageData.contentType),
);
```

### 4. Universal Image Picker Widget (`lib/features/orders/presentation/widgets/universal_image_picker.dart`)
Ready-to-use UI component with:
- Image preview
- File validation
- Error handling
- Loading states
- Remove functionality

## Usage Examples

### Basic File Picking
```dart
// Pick an image
final imageData = await UniversalFilePicker.pickImage(
  maxFileSize: 10 * 1024 * 1024, // 10MB
  allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
);

// Pick any file
final fileData = await UniversalFilePicker.pickFile(
  maxFileSize: 5 * 1024 * 1024, // 5MB
);
```

### Upload with Universal Service
```dart
// Upload order with items and image
final result = await UniversalUploadService.uploadOrder(
  items: [
    {'name': 'Product 1', 'quantity': 2},
    {'name': 'Product 2', 'quantity': 1},
  ],
  imageData: selectedImage,
  additionalFields: {
    'delivery_address': '123 Main St',
    'notes': 'Special instructions',
  },
);
```

### Using the Widget
```dart
UniversalImagePicker(
  selectedImage: _selectedImage,
  onImageSelected: (imageData) {
    setState(() {
      _selectedImage = imageData;
    });
  },
  label: 'Upload Image',
  hint: 'Tap to select an image file (JPG, PNG, GIF, WebP)',
  maxFileSizeInMB: 10,
)
```

## Platform-Specific Implementation

### Web Implementation (`lib/core/services/universal_file_picker_web.dart`)
```dart
// Uses dart:html FileUploadInputElement
final input = html.FileUploadInputElement()
  ..accept = 'image/*'
  ..multiple = false;

// Reads file as bytes using FileReader
final reader = html.FileReader();
reader.readAsArrayBuffer(file);
```

### Mobile Implementation
```dart
// Uses file_picker package
final result = await FilePicker.platform.pickFiles(
  type: FileType.image,
  allowMultiple: false,
);

final bytes = result.files.first.bytes;
```

## Error Handling

### File Picker Errors
```dart
try {
  final imageData = await UniversalFilePicker.pickImage();
} catch (e) {
  if (e is FilePickerException) {
    // Handle file picker specific errors
    print('File picker error: ${e.message}');
  }
}
```

### Upload Errors
```dart
try {
  final result = await UniversalUploadService.uploadOrder(...);
} catch (e) {
  if (e is UploadException) {
    // Handle upload specific errors
    print('Upload error: ${e.message}');
  }
}
```

### Platform-Specific Error Messages
```dart
final errorMessage = UniversalOrderService.getPlatformErrorMessage(error);
// Returns user-friendly error messages based on platform
```

## File Validation

### Size Validation
```dart
if (!imageData.isSizeValid(maxSizeInMB: 10)) {
  throw OrderException('File size exceeds 10MB limit');
}
```

### Type Validation
```dart
if (!imageData.isImage) {
  throw OrderException('File must be an image');
}
```

### MIME Type Detection
```dart
final contentType = imageData.contentType; // 'image/jpeg', 'image/png', etc.
final extension = imageData.fileExtension; // 'jpg', 'png', etc.
```

## Dependencies

### Required Dependencies
```yaml
dependencies:
  http: ^1.1.0                    # For multipart uploads
  http_parser: ^4.0.2            # For MediaType parsing
  file_picker: ^8.0.0+1          # For mobile file picking
```

### Conditional Imports
The implementation uses conditional imports to automatically select the correct platform-specific code:
```dart
import 'universal_file_picker_stub.dart'
    if (dart.library.html) 'universal_file_picker_web.dart';
```

## Integration with Existing Code

### Updated PlaceOrderPage
The existing `PlaceOrderPage` has been updated to use the universal file picker:
- Replaced `File?` with `FileData?`
- Replaced `ImagePickerWidget` with `UniversalImagePicker`
- Updated upload logic to use `UniversalUploadService`

### Backward Compatibility
The new implementation maintains backward compatibility with existing order models and API endpoints.

## Testing

### Mobile Testing
```bash
flutter run --debug
# Test on Android/iOS devices
```

### Web Testing
```bash
flutter run -d chrome --web-renderer canvaskit
# Test file upload in web browser
```

### Build Testing
```bash
# Test mobile build
flutter build apk --debug

# Test web build
flutter build web --release
```

## Best Practices

### 1. File Size Limits
Always set appropriate file size limits:
```dart
final maxSize = 10 * 1024 * 1024; // 10MB
```

### 2. File Type Validation
Validate file types on both client and server:
```dart
if (!imageData.isImage) {
  throw Exception('Only image files are allowed');
}
```

### 3. Error Handling
Provide user-friendly error messages:
```dart
try {
  // Upload logic
} catch (e) {
  final message = UniversalOrderService.getPlatformErrorMessage(e);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
```

### 4. Loading States
Show loading indicators during file operations:
```dart
setState(() {
  _isLoading = true;
});

try {
  await uploadFile();
} finally {
  setState(() {
    _isLoading = false;
  });
}
```

## Troubleshooting

### Common Issues

1. **"MultipartFile is only supported where dart:io is available"**
   - Solution: Use `MultipartFile.fromBytes()` instead of `fromPath()`

2. **File picker not working on web**
   - Solution: Ensure conditional imports are properly set up

3. **File size validation failing**
   - Solution: Check file size limits and validation logic

4. **MIME type detection incorrect**
   - Solution: Verify file extension mapping in `FileData.contentType`

### Debug Tips

1. **Enable debug logging**:
   ```dart
   print('File data: ${imageData.toString()}');
   ```

2. **Check platform detection**:
   ```dart
   print('Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
   ```

3. **Validate file bytes**:
   ```dart
   print('File size: ${imageData.bytes.length} bytes');
   ```

## Future Enhancements

- [ ] Support for multiple file uploads
- [ ] Image compression and resizing
- [ ] Progress indicators for large uploads
- [ ] Drag and drop support for web
- [ ] Camera integration for mobile
- [ ] File preview for non-image files

## Conclusion

This universal file upload implementation provides a robust, platform-agnostic solution for handling file uploads in Flutter applications. It eliminates the common "dart:io not available" error while maintaining a clean, maintainable codebase that works seamlessly across all platforms.

The implementation follows Flutter best practices and provides comprehensive error handling, making it production-ready for your Beena Mart customer application.
