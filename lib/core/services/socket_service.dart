import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'user_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _userId;
  String? _accessToken;
  
  // Stream controllers for different types of notifications
  final StreamController<Map<String, dynamic>> _notificationController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _orderUpdateController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionStatusController = 
      StreamController<bool>.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  Stream<Map<String, dynamic>> get orderUpdateStream => _orderUpdateController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  
  bool get isConnected => _isConnected;

  /// Initialize Socket.IO connection
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(AppConstants.tokenKey);
      
      // Get user ID from user data
      final user = await UserService.getCurrentUser();
      _userId = user?.id;

      if (_accessToken == null || _userId == null) {
        print('SocketService: No access token or user ID found');
        print('SocketService: Access token: $_accessToken');
        print('SocketService: User ID: $_userId');
        return;
      }

      print('SocketService: Initializing with token: ${_accessToken?.substring(0, 20)}...');
      print('SocketService: User ID: $_userId');
      await _connect();
    } catch (e) {
      print('SocketService: Initialization error: $e');
    }
  }

  /// Connect to Socket.IO server
  Future<void> _connect() async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    try {
      _socket = IO.io(
        'https://api.groshly.com',
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .setAuth({'token': _accessToken})
            .setExtraHeaders({'Authorization': 'Bearer $_accessToken'})
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setTimeout(20000)
            .build(),
      );

      _setupEventListeners();
      
      // Auto-reconnect on connection loss
      _socket!.onConnect((_) {
        print('SocketService: Connected to server');
        _isConnected = true;
        _connectionStatusController.add(true);
      });

      _socket!.onDisconnect((_) {
        print('SocketService: Disconnected from server');
        _isConnected = false;
        _connectionStatusController.add(false);
        
        // Attempt to reconnect after 5 seconds
        Timer(const Duration(seconds: 5), () {
          if (!_isConnected) {
            _connect();
          }
        });
      });

      _socket!.onConnectError((error) {
        print('SocketService: Connection error: $error');
        _isConnected = false;
        _connectionStatusController.add(false);
      });

    } catch (e) {
      print('SocketService: Connection setup error: $e');
      _isConnected = false;
      _connectionStatusController.add(false);
    }
  }

  /// Setup event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Handle connection confirmation
    _socket!.on('connected', (data) {
      print('SocketService: Server confirmed connection: $data');
    });

    // Handle general notifications
    _socket!.on('notification', (data) {
      print('SocketService: Received notification: $data');
      try {
        final notification = Map<String, dynamic>.from(data);
        _notificationController.add(notification);
      } catch (e) {
        print('SocketService: Error parsing notification: $e');
      }
    });

    // Handle order updates specifically
    _socket!.on('order_update', (data) {
      print('SocketService: Received order update: $data');
      try {
        final orderUpdate = Map<String, dynamic>.from(data);
        _orderUpdateController.add(orderUpdate);
      } catch (e) {
        print('SocketService: Error parsing order update: $e');
      }
    });

    // Handle room join confirmation
    _socket!.on('room_joined', (data) {
      print('SocketService: Joined room: $data');
    });

    // Handle room leave confirmation
    _socket!.on('room_left', (data) {
      print('SocketService: Left room: $data');
    });

    // Handle ping/pong for connection health
    _socket!.on('pong', (data) {
      print('SocketService: Received pong: $data');
    });
  }

  /// Join a specific room (e.g., for order tracking)
  void joinRoom(String roomName) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join_room', roomName);
      print('SocketService: Joining room: $roomName');
    }
  }

  /// Leave a specific room
  void leaveRoom(String roomName) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leave_room', roomName);
      print('SocketService: Leaving room: $roomName');
    }
  }

  /// Join order tracking room
  void joinOrderRoom(String orderId) {
    joinRoom('order_$orderId');
  }

  /// Leave order tracking room
  void leaveOrderRoom(String orderId) {
    leaveRoom('order_$orderId');
  }

  /// Send ping to check connection health
  void ping() {
    if (_socket != null && _isConnected) {
      _socket!.emit('ping');
    }
  }

  /// Update authentication token
  Future<void> updateToken(String newToken) async {
    _accessToken = newToken;
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, newToken);
    
    // Reconnect with new token
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
    
    await _connect();
  }

  /// Disconnect from server
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
      _connectionStatusController.add(false);
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _notificationController.close();
    _orderUpdateController.close();
    _connectionStatusController.close();
  }
}
