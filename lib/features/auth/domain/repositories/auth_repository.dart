import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Sends OTP to the provided mobile number
  Future<Either<Failure, void>> sendOtp(String mobileNumber);
  
  /// Verifies OTP and returns authentication result
  Future<Either<Failure, AuthResult>> verifyOtp(String mobileNumber, String otp, {String? name, String? address});
  
  /// Gets current user if authenticated
  Future<Either<Failure, User?>> getCurrentUser();
  
  /// Logs out the current user
  Future<Either<Failure, void>> logout();
  
  /// Checks if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();
  
  /// Refreshes authentication token
  Future<Either<Failure, AuthResult>> refreshToken();
}
