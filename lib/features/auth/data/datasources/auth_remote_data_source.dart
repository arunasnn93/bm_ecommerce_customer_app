import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/jwt_service.dart';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';
import '../models/api_requests.dart';
import '../models/api_responses.dart';
import 'auth_demo_data_source.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String mobileNumber);
  Future<AuthResultModel> verifyOtp(String mobileNumber, String otp, {String? name, String? address});
  Future<CheckUserResponse> checkUserExists(String mobileNumber);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<AuthResultModel> refreshToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final AuthDemoDataSource _demoDataSource;
  
  AuthRemoteDataSourceImpl(this.apiClient) : _demoDataSource = AuthDemoDataSource();
  
  @override
  Future<void> sendOtp(String mobileNumber) async {
    // Use demo mode if configured
    if (AppConfig.useDemoMode) {
      print('🔧 Demo Mode: Using simulated OTP send for $mobileNumber');
      return await _demoDataSource.sendOtp(mobileNumber);
    }
    
    try {
      final request = SendOtpRequest(mobile: mobileNumber);
      final requestBody = request.toJson();
      
      // Log the API call details
      print('🌐 API Call Details:');
      print('   Base URL: ${AppConfig.baseUrl}');
      print('   Endpoint: ${AppConstants.sendOtpEndpoint}');
      print('   Full URL: ${AppConfig.baseUrl}${AppConfig.apiVersion}${AppConstants.sendOtpEndpoint}');
      print('   Request Body: $requestBody');
      print('   Mobile Number: $mobileNumber');
      
      final response = await apiClient.post(
        AppConstants.sendOtpEndpoint,
        data: requestBody,
      );
      
      // Log the response
      print('📡 API Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');
      
      // Parse the response
      final apiResponse = ApiResponse<SendOtpResponse>.fromJson(
        response.data,
        (json) => SendOtpResponse.fromJson(json),
      );
      
      if (!apiResponse.success) {
        print('❌ API Error: ${apiResponse.message}');
        throw Exception(apiResponse.message);
      }
      
      print('✅ API Success: ${apiResponse.message}');
      print('   Response Data: ${apiResponse.data?.toJson()}');
      
      // Store request ID for OTP verification (optional)
      // You might want to store this in local storage
      
    } catch (e) {
      print('💥 API Error: $e');
      
      if (e is DioException) {
        print('   DioException Type: ${e.type}');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Error Message: ${e.message}');
        print('   Response Data: ${e.response?.data}');
        print('   Response Headers: ${e.response?.headers}');
        
        if (e.response?.statusCode == 400) {
          // Log the detailed error response
          print('   🔍 Detailed 400 Error Response:');
          print('      Data: ${e.response?.data}');
          print('      Message: ${e.response?.data?['message']}');
          print('      Error: ${e.response?.data?['error']}');
          throw Exception('Invalid OTP. Please check and try again.');
        } else if (e.response?.statusCode == 401) {
          throw Exception('OTP expired. Please request a new one.');
        } else if (e.response?.statusCode == 404) {
          throw Exception('Invalid mobile number or OTP.');
        } else if (e.response?.statusCode == 500) {
          throw Exception('Server error. Please try again.');
        } else {
          throw Exception('Network error. Please check your connection.');
        }
      }
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }
  
  @override
  Future<AuthResultModel> verifyOtp(String mobileNumber, String otp, {String? name, String? address}) async {
    // Use demo mode if configured
    if (AppConfig.useDemoMode) {
      return await _demoDataSource.verifyOtp(mobileNumber, otp);
    }
    
    try {
      final request = VerifyOtpRequest(
        mobile: mobileNumber,
        otp: otp,
        name: name,
        address: address,
        fcmToken: null, // TODO: Add FCM token when implementing push notifications
      );
      
      final requestBody = request.toJson();
      
      // Log the API call details
      print('🌐 Verify OTP API Call Details:');
      print('   Base URL: ${AppConfig.baseUrl}');
      print('   Endpoint: ${AppConstants.verifyOtpEndpoint}');
      print('   Full URL: ${AppConfig.baseUrl}${AppConfig.apiVersion}${AppConstants.verifyOtpEndpoint}');
      print('   Request Body: $requestBody');
      print('   Request Body Type: ${requestBody.runtimeType}');
      print('   Mobile Number: $mobileNumber');
      print('   Name: $name');
      print('   Address: $address');
      print('   OTP: $otp');
      
      final response = await apiClient.post(
        AppConstants.verifyOtpEndpoint,
        data: requestBody,
      );
      
      // Log the response
      print('📡 API Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');
      
      // Parse the response
      final apiResponse = ApiResponse<VerifyOtpResponse>.fromJson(
        response.data,
        (json) => VerifyOtpResponse.fromJson(json),
      );
      
      if (!apiResponse.success) {
        print('❌ API Error: ${apiResponse.message}');
        throw Exception(apiResponse.message);
      }
      
      print('✅ API Success: ${apiResponse.message}');
      print('   Response Data: ${apiResponse.data?.toJson()}');
      
      // Extract user data from response
      final verifyOtpResponse = apiResponse.data!;
      final userResponse = verifyOtpResponse.user;
      
      // Create UserModel from UserResponse
      final userModel = UserModel(
        id: userResponse.id,
        name: userResponse.name,
        mobileNumber: userResponse.mobile,
        email: null, // Not provided in this response
        profileImage: null, // Not provided in this response
        createdAt: DateTime.now(), // Not provided in this response
        updatedAt: DateTime.now(), // Not provided in this response
      );
      
      // Use server-generated access token instead of generating our own JWT
      final accessToken = verifyOtpResponse.accessToken ?? 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Store the access token
      await JwtService.storeToken(accessToken);
      
      // Create AuthResultModel
      final authResult = AuthResultModel(
        user: userModel,
        token: accessToken,
        expiresAt: DateTime.now().add(AppConstants.tokenExpiryDuration),
      );
      
      return authResult;
      
    } catch (e) {
      print('💥 API Error: $e');
      
      if (e is DioException) {
        print('   DioException Type: ${e.type}');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Error Message: ${e.message}');
        print('   Response Data: ${e.response?.data}');
        print('   Response Headers: ${e.response?.headers}');
        
        if (e.response?.statusCode == 400) {
          // Log the detailed error response
          print('   🔍 Detailed 400 Error Response:');
          print('      Raw Data: ${e.response?.data}');
          print('      Data Type: ${e.response?.data.runtimeType}');
          if (e.response?.data is Map) {
            print('      Message: ${e.response?.data['message']}');
            print('      Error: ${e.response?.data['error']}');
            print('      Details: ${e.response?.data['details']}');
          }
          throw Exception('Invalid OTP. Please check and try again.');
        } else if (e.response?.statusCode == 401) {
          throw Exception('OTP expired. Please request a new one.');
        } else if (e.response?.statusCode == 404) {
          throw Exception('Invalid mobile number or OTP.');
        } else if (e.response?.statusCode == 500) {
          throw Exception('Server error. Please try again.');
        } else {
          throw Exception('Network error. Please check your connection.');
        }
      }
      throw Exception('Failed to verify OTP: ${e.toString()}');
    }
  }
  
  @override
  Future<CheckUserResponse> checkUserExists(String mobileNumber) async {
    try {
      final request = CheckUserRequest(mobile: mobileNumber);
      final requestBody = request.toJson();

      final response = await apiClient.post(
        AppConstants.checkUserExistsEndpoint,
        data: requestBody,
      );

      final apiResponse = ApiResponse<CheckUserResponse>.fromJson(
        response.data,
        (json) => CheckUserResponse.fromJson(json),
      );

      if (!apiResponse.success) {
        print('❌ API Error: ${apiResponse.message}');
        throw Exception(apiResponse.message);
      }

      print('✅ API Success: ${apiResponse.message}');
      print('   Response Data: ${apiResponse.data?.toJson()}');

      return apiResponse.data!;
    } catch (e) {
      print('💥 API Error: $e');
      if (e is DioException) {
        print('   DioException Type: ${e.type}');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Error Message: ${e.message}');
        print('   Response Data: ${e.response?.data}');
        if (e.response?.statusCode == 400) {
          throw Exception('Invalid mobile number format');
        } else if (e.response?.statusCode == 404) {
          throw Exception('User not found');
        } else if (e.response?.statusCode == 500) {
          throw Exception('Server error. Please try again.');
        } else {
          throw Exception('Network error. Please check your connection.');
        }
      }
      throw Exception('Failed to check user exists: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // For demo purposes, we'll simulate getting current user
      // In real implementation, this would make an actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return null for demo (no user logged in)
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }
  
  @override
  Future<void> logout() async {
    try {
      // For demo purposes, we'll simulate logout
      // In real implementation, this would make an actual API call
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
  
  @override
  Future<bool> isAuthenticated() async {
    try {
      // For demo purposes, we'll simulate checking authentication
      // In real implementation, this would check token validity
      await Future.delayed(const Duration(milliseconds: 300));
      return false; // For demo, always return false
    } catch (e) {
      throw Exception('Failed to check authentication: $e');
    }
  }
  
  @override
  Future<AuthResultModel> refreshToken() async {
    try {
      // For demo purposes, we'll simulate token refresh
      // In real implementation, this would make an actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      throw Exception('Token refresh not implemented in demo');
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }
}
