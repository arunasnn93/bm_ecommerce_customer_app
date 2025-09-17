import 'dart:convert';
import 'dart:typed_data';

void main() {
  // Test the base64url conversion
  final vapidKey = 'BMktJfomnQ5T6fc2zq0Ju3rjD3rFuO62vKJ_HjEUiMGOqczAYALxFF0FVrQ6OP-UsBrdXL27JtJlsDqaHUT5viw';
  
  print('Testing base64url conversion...');
  print('Original key: $vapidKey');
  
  try {
    final result = _base64UrlToArrayBuffer(vapidKey);
    print('✅ Conversion successful! Length: ${result.length}');
    print('First 10 bytes: ${result.take(10).toList()}');
    
    // Verify it's the correct length for a VAPID key (should be 65 bytes)
    if (result.length == 65) {
      print('✅ Correct VAPID key length (65 bytes)');
    } else {
      print('❌ Incorrect VAPID key length: ${result.length} bytes');
    }
  } catch (e) {
    print('❌ Conversion failed: $e');
  }
}

Uint8List _base64UrlToArrayBuffer(String base64url) {
  try {
    // Remove any existing padding
    String cleanBase64 = base64url.replaceAll('=', '');
    
    // Add proper padding for base64 decoding
    while (cleanBase64.length % 4 != 0) {
      cleanBase64 += '=';
    }
    
    // Convert URL-safe base64 to regular base64
    final regularBase64 = cleanBase64
        .replaceAll('-', '+')
        .replaceAll('_', '/');
    
    print('🔔 Converting base64url to ArrayBuffer:');
    print('   Original: $base64url');
    print('   Clean: $cleanBase64');
    print('   Regular: $regularBase64');
    
    final result = Uint8List.fromList(base64Decode(regularBase64));
    print('   Result length: ${result.length}');
    
    return result;
  } catch (e) {
    print('❌ Error converting base64url: $e');
    print('❌ Input string: $base64url');
    rethrow;
  }
}
