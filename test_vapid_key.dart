import 'dart:convert';
import 'dart:typed_data';

void main() {
  // Test the VAPID key conversion
  final vapidKey = 'BMktJfomnQ5T6fc2zq0Ju3rjD3rFuO62vKJ_HjEUiMGOqczAYALxFF0FVrQ6OP-UsBrdXL27JtJlsDqaHUT5viw';
  
  print('Testing VAPID key conversion...');
  print('Original key: $vapidKey');
  
  try {
    final result = _urlBase64ToUint8Array(vapidKey);
    print('✅ Conversion successful! Length: ${result.length}');
    print('First 10 bytes: ${result.take(10).toList()}');
  } catch (e) {
    print('❌ Conversion failed: $e');
  }
}

Uint8List _urlBase64ToUint8Array(String base64String) {
  try {
    // Remove any existing padding
    String cleanBase64 = base64String.replaceAll('=', '');
    
    // Add proper padding
    while (cleanBase64.length % 4 != 0) {
      cleanBase64 += '=';
    }
    
    // Convert URL-safe base64 to regular base64
    final regularBase64 = cleanBase64
        .replaceAll('-', '+')
        .replaceAll('_', '/');
    
    print('Clean base64: $cleanBase64');
    print('Regular base64: $regularBase64');
    
    return Uint8List.fromList(base64Decode(regularBase64));
  } catch (e) {
    print('❌ Error converting base64: $e');
    print('❌ Input string: $base64String');
    rethrow;
  }
}
