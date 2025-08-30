import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../config/app_config.dart';

class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    final baseUrl = AppConfig.baseUrl + AppConfig.apiVersion;
    
    print('🔧 API Client Configuration:');
    print('   Base URL: ${AppConfig.baseUrl}');
    print('   API Version: ${AppConfig.apiVersion}');
    print('   Full Base URL: $baseUrl');
    
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConfig.connectionTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (AppConfig.enableLogging) {
            print('🌐 API Request: ${options.method} ${options.path}');
            print('   Headers: ${options.headers}');
            print('   Data: ${options.data}');
          }
          
          // Add auth token if available
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (AppConfig.enableLogging) {
            print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
            print('   Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (AppConfig.enableLogging) {
            print('❌ API Error: ${error.type} ${error.response?.statusCode} ${error.requestOptions.path}');
            print('   Message: ${error.message}');
            print('   Response: ${error.response?.data}');
          }
          
          // Handle common errors
          if (error.response?.statusCode == 401) {
            // Handle unauthorized access
            _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }
  
  void _handleUnauthorized() async {
    // Clear stored token and redirect to login
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    // TODO: Navigate to login screen
  }
  
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        // Return the original DioException to preserve error details
        return error;
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network connection.');
      case DioExceptionType.unknown:
        return Exception('Unknown network error: ${error.message}');
      default:
        return Exception('An unexpected error occurred: ${error.message}');
    }
  }
}
