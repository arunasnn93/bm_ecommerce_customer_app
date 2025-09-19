import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/widgets/floating_notification.dart';

class SocketTestPage extends StatefulWidget {
  const SocketTestPage({Key? key}) : super(key: key);

  @override
  State<SocketTestPage> createState() => _SocketTestPageState();
}

class _SocketTestPageState extends State<SocketTestPage> {
  final SocketService _socketService = SocketService();
  final Dio _dio = Dio();
  bool _isConnected = false;
  String _connectionStatus = 'Disconnected';
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
    _checkConnectionStatus();
  }

  void _setupSocketListeners() {
    _socketService.connectionStatusStream.listen((connected) {
      setState(() {
        _isConnected = connected;
        _connectionStatus = connected ? 'Connected' : 'Disconnected';
      });
    });

    _socketService.notificationStream.listen((notification) {
      setState(() {
        _messages.add('Notification: ${notification['title']} - ${notification['message']}');
      });
    });

    _socketService.orderUpdateStream.listen((orderUpdate) {
      setState(() {
        _messages.add('Order Update: ${orderUpdate['message']}');
      });
    });
  }

  Future<void> _checkConnectionStatus() async {
    try {
      final response = await _dio.get(
        'https://api.groshly.com/api/test-socket/connection-status',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAccessToken()}',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isConnected = response.data['isConnected'] ?? false;
          _connectionStatus = _isConnected ? 'Connected' : 'Disconnected';
        });
      }
    } catch (e) {
      print('Error checking connection status: $e');
    }
  }

  Future<String?> _getAccessToken() async {
    // This should get the actual access token from your auth service
    // For now, return null - you'll need to implement this
    return null;
  }

  Future<void> _sendTestNotification() async {
    try {
      final response = await _dio.post(
        'https://api.groshly.com/api/test-socket/test-notification',
        data: {
          'title': 'Test Notification',
          'message': 'This is a test notification from Socket.IO!',
          'type': 'info',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAccessToken()}',
          },
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test notification sent!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending notification: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _sendTestOrderUpdate() async {
    try {
      final response = await _dio.post(
        'https://api.groshly.com/api/test-socket/test-order-update',
        data: {
          'orderId': 'TEST_ORDER_123',
          'status': 'packing',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAccessToken()}',
          },
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test order update sent!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending order update: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showFloatingNotification() {
    // This would be handled by the FloatingNotificationManager
    // For testing, we can show a manual notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Floating notification would appear here'),
        backgroundColor: AppColors.info,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket.IO Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status',
                      style: AppTextStyles.h6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _isConnected ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          _connectionStatus,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _isConnected ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Test Buttons
            Text(
              'Test Actions',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _sendTestNotification,
              child: Text('Send Test Notification'),
            ),
            
            SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _sendTestOrderUpdate,
              child: Text('Send Test Order Update'),
            ),
            
            SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _showFloatingNotification,
              child: Text('Show Floating Notification'),
            ),
            
            SizedBox(height: 16),
            
            // Messages
            Text(
              'Messages',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _messages[index],
                              style: AppTextStyles.bodySmall,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
