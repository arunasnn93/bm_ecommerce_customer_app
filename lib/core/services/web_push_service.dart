import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:bm_ecommerce_customer_app/core/network/api_client.dart';
import 'package:bm_ecommerce_customer_app/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:js' as js;
import 'dart:html' as html;

class WebPushService {
  static String? _currentSubscription;
  static final ApiClient _apiClient = ApiClient();

  static Future<void> initialize() async {
    if (kDebugMode) {
      print('Web Push Service initialized');
    }
  }

  /// Request notification permission
  static Future<String> requestNotificationPermission() async {
    if (kIsWeb) {
      try {
        print('🔔 Requesting notification permission...');
        
        // Check if notifications are supported
        if (!html.Notification.supported) {
          print('❌ Notifications not supported in this browser');
          return 'not-supported';
        }
        
        // Check current permission status
        final currentPermission = html.Notification.permission;
        print('🔔 Current permission status: $currentPermission');
        
        if (currentPermission == 'granted') {
          print('✅ Permission already granted');
          return 'granted';
        } else if (currentPermission == 'denied') {
          print('❌ Permission permanently denied - user must enable in browser settings');
          return 'denied';
        }
        
        // Request permission
        final permission = await html.Notification.requestPermission();
        print('🔔 Permission result: $permission');
        
        if (permission == 'denied') {
          print('❌ Permission denied - user must enable in browser settings');
        } else if (permission == 'granted') {
          print('✅ Permission granted successfully');
        }
        
        return permission;
      } catch (e) {
        print('❌ Error requesting permission: $e');
        return 'error';
      }
    }
    return 'granted';
  }

  /// Generate web push subscription
  static Future<String?> generateWebPushSubscription() async {
    if (kIsWeb) {
      try {
        print('🔔 Generating web push subscription...');
        
        // First, get the VAPID public key from backend
        final vapidPublicKey = await _getVapidPublicKey();
        if (vapidPublicKey == null) {
          print('❌ Failed to get VAPID public key');
          return null;
        }
        
        // Request notification permission
        final permission = await requestNotificationPermission();
        if (permission != 'granted') {
          print('❌ Notification permission not granted: $permission');
          return null;
        }
        
        // Get service worker registration
        final serviceWorkerRegistration = await html.window.navigator.serviceWorker?.ready;
        if (serviceWorkerRegistration == null) {
          print('❌ Service worker not available');
          return null;
        }
        
        // Subscribe to push notifications
        print('🔔 VAPID Public Key: $vapidPublicKey');
        
        // Convert base64url to ArrayBuffer using browser's native base64url decoding
        final applicationServerKey = await _base64UrlToArrayBufferNative(vapidPublicKey);
        print('🔔 Application Server Key length: ${applicationServerKey.length}');
        
        final subscription = await serviceWorkerRegistration.pushManager?.subscribe({
          'userVisibleOnly': true,
          'applicationServerKey': applicationServerKey,
        });
        
        if (subscription == null) {
          print('❌ Failed to subscribe to push notifications');
          return null;
        }
        
        print('✅ Web push subscription created successfully');
        
        // Convert subscription to JSON string
        final subscriptionJson = jsonEncode({
          'endpoint': subscription.endpoint,
          'keys': {
            'p256dh': _arrayBufferToBase64(subscription.getKey('p256dh')!),
            'auth': _arrayBufferToBase64(subscription.getKey('auth')!),
          }
        });
        
        _currentSubscription = subscriptionJson;
        
        // Send subscription to backend
        await _sendSubscriptionToBackend(subscriptionJson);
        
        return subscriptionJson;
      } catch (e) {
        print('❌ Error generating web push subscription: $e');
        return null;
      }
    }
    return null;
  }

  /// Get VAPID public key from backend
  static Future<String?> _getVapidPublicKey() async {
    try {
      final response = await _apiClient.get('/api/web-push/vapid-key');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data']['publicKey'];
        }
      }
      print('❌ Failed to get VAPID public key from backend');
      return null;
    } catch (e) {
      print('❌ Error getting VAPID public key: $e');
      return null;
    }
  }

  /// Send subscription to backend
  static Future<void> _sendSubscriptionToBackend(String subscription) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString(AppConstants.tokenKey);

      if (jwtToken == null) {
        print('No JWT token found, cannot send subscription to backend.');
        return;
      }

      final response = await _apiClient.post('/api/web-push/subscribe', data: {
        'subscription': jsonDecode(subscription),
      });

      if (response.statusCode == 201) {
        print('✅ Web push subscription saved successfully to backend.');
      } else {
        print('❌ Failed to save subscription to backend: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending subscription to backend: $e');
    }
  }

  /// Send test notification
  static Future<bool> sendTestNotification() async {
    try {
      final response = await _apiClient.post('/api/web-push/test');
      if (response.statusCode == 201) {
        print('✅ Test notification sent successfully');
        return true;
      } else {
        print('❌ Failed to send test notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending test notification: $e');
      return false;
    }
  }

  /// Setup push notification listener
  static Future<void> setupPushNotificationListener() async {
    if (kIsWeb) {
      try {
        print('🔔 Setting up web push notification listener...');
        
        // Register service worker
        await html.window.navigator.serviceWorker?.register('/firebase-messaging-sw.js');
        
        // Listen for push events
        html.window.navigator.serviceWorker?.addEventListener('message', (event) {
          print('🔔 Message received from service worker: $event');
          
          // Handle notification here - simplified for now
          print('🔔 Service worker message received');
        });
        
        print('✅ Web push notification listener set up successfully');
      } catch (e) {
        print('❌ Error setting up push notification listener: $e');
      }
    }
  }

  /// Get current subscription
  static String? getCurrentSubscription() => _currentSubscription;

  /// Convert base64url to ArrayBuffer using browser's native base64url decoding
  static Future<Uint8List> _base64UrlToArrayBufferNative(String base64url) async {
    try {
      if (kIsWeb) {
        // Use browser's native base64url decoding
        final jsContext = js.context;
        
        // Create a simple JavaScript function to decode base64url
        final jsCode = '''
          function decodeBase64Url(base64url) {
            // Convert base64url to regular base64
            const base64 = base64url.replace(/-/g, '+').replace(/_/g, '/');
            
            // Add padding if needed
            const padded = base64 + '='.repeat((4 - base64.length % 4) % 4);
            
            // Convert to binary string
            const binaryString = atob(padded);
            
            // Convert to Uint8Array
            const uint8Array = new Uint8Array(binaryString.length);
            for (let i = 0; i < binaryString.length; i++) {
              uint8Array[i] = binaryString.charCodeAt(i);
            }
            
            return uint8Array;
          }
        ''';
        
        // Execute the JavaScript function
        jsContext.callMethod('eval', [jsCode]);
        final decodeFunction = jsContext['decodeBase64Url'];
        final result = decodeFunction.callMethod('call', [null, base64url]);
        
        // Convert JavaScript Uint8Array to Dart Uint8List
        final length = result['length'] as int;
        final dartUint8List = Uint8List(length);
        for (int i = 0; i < length; i++) {
          dartUint8List[i] = result[i] as int;
        }
        
        print('🔔 Native base64url conversion successful! Length: ${dartUint8List.length}');
        return dartUint8List;
      } else {
        // Fallback to Dart conversion for non-web platforms
        return _base64UrlToArrayBuffer(base64url);
      }
    } catch (e) {
      print('❌ Error in native base64url conversion: $e');
      // Fallback to Dart conversion
      return _base64UrlToArrayBuffer(base64url);
    }
  }

  /// Convert base64url to ArrayBuffer (for applicationServerKey)
  static Uint8List _base64UrlToArrayBuffer(String base64url) {
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

  /// Convert URL-safe base64 to Uint8Array (base64url without padding)
  static Uint8List _urlBase64ToUint8Array(String base64String) {
    try {
      // Remove any existing padding
      String cleanBase64 = base64String.replaceAll('=', '');
      
      // Add proper padding for base64 decoding
      while (cleanBase64.length % 4 != 0) {
        cleanBase64 += '=';
      }
      
      // Convert URL-safe base64 to regular base64
      final regularBase64 = cleanBase64
          .replaceAll('-', '+')
          .replaceAll('_', '/');
      
      print('🔔 Converting base64url to Uint8Array:');
      print('   Original: $base64String');
      print('   Clean: $cleanBase64');
      print('   Regular: $regularBase64');
      
      final result = Uint8List.fromList(base64Decode(regularBase64));
      print('   Result length: ${result.length}');
      
      return result;
    } catch (e) {
      print('❌ Error converting base64url: $e');
      print('❌ Input string: $base64String');
      rethrow;
    }
  }

  /// Convert ArrayBuffer to base64
  static String _arrayBufferToBase64(dynamic buffer) {
    final bytes = Uint8List.view(buffer);
    return base64Encode(bytes);
  }
}
