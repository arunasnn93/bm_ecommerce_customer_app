import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/services/user_service.dart';

class SocketDebugPage extends StatefulWidget {
  const SocketDebugPage({Key? key}) : super(key: key);

  @override
  State<SocketDebugPage> createState() => _SocketDebugPageState();
}

class _SocketDebugPageState extends State<SocketDebugPage> {
  final SocketService _socketService = SocketService();
  bool _isConnected = false;
  String _connectionStatus = 'Unknown';
  String? _accessToken;
  String? _userId;
  List<String> _debugLogs = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupSocketListeners();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = await UserService.getCurrentUser();
    setState(() {
      _accessToken = prefs.getString(AppConstants.tokenKey);
      _userId = user?.id;
    });
    _addLog('Loaded user data - Token: ${_accessToken?.substring(0, 20)}..., User ID: $_userId');
  }

  void _setupSocketListeners() {
    _socketService.connectionStatusStream.listen((connected) {
      setState(() {
        _isConnected = connected;
        _connectionStatus = connected ? 'Connected' : 'Disconnected';
      });
      _addLog('Connection status changed: $_connectionStatus');
    });

    _socketService.notificationStream.listen((notification) {
      _addLog('Received notification: ${notification['title']} - ${notification['message']}');
    });

    _socketService.orderUpdateStream.listen((orderUpdate) {
      _addLog('Received order update: ${orderUpdate['message']}');
    });
  }

  void _addLog(String message) {
    setState(() {
      _debugLogs.add('${DateTime.now().toIso8601String()}: $message');
    });
  }

  Future<void> _initializeSocket() async {
    _addLog('Initializing Socket.IO...');
    try {
      await _socketService.initialize();
      _addLog('Socket.IO initialization completed');
    } catch (e) {
      _addLog('Socket.IO initialization error: $e');
    }
  }

  Future<void> _disconnectSocket() async {
    _addLog('Disconnecting Socket.IO...');
    _socketService.disconnect();
    _addLog('Socket.IO disconnected');
  }

  Future<void> _testConnection() async {
    _addLog('Testing connection...');
    _addLog('Current status: $_connectionStatus');
    _addLog('Is connected: $_isConnected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket.IO Debug'),
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
                    SizedBox(height: 8),
                    Text(
                      'User ID: ${_userId ?? "Not found"}',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      'Token: ${_accessToken?.substring(0, 30) ?? "Not found"}...',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Action Buttons
            Text(
              'Actions',
              style: AppTextStyles.h6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _initializeSocket,
                    child: Text('Initialize Socket'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _disconnectSocket,
                    child: Text('Disconnect'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _testConnection,
              child: Text('Test Connection'),
            ),
            
            SizedBox(height: 16),
            
            // Debug Logs
            Text(
              'Debug Logs',
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
                child: _debugLogs.isEmpty
                    ? Center(
                        child: Text(
                          'No debug logs yet',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _debugLogs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _debugLogs[index],
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
