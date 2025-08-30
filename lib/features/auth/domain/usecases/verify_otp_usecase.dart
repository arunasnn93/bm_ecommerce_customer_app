import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../repositories/auth_repository.dart';
import '../entities/auth_result.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;
  
  VerifyOtpUseCase(this.repository);
  
  Future<Either<Failure, AuthResult>> call(String mobileNumber, String otp, {String? name, String? address}) async {
    // Validate mobile number
    if (mobileNumber.length != AppConstants.mobileNumberLength) {
      return const Left(ValidationFailure('Please enter a valid 10-digit mobile number'));
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(mobileNumber)) {
      return const Left(ValidationFailure('Mobile number should contain only digits'));
    }
    
    // Validate OTP
    if (otp.length != AppConstants.otpLength) {
      return const Left(ValidationFailure('Please enter a valid 6-digit OTP'));
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(otp)) {
      return const Left(ValidationFailure('OTP should contain only digits'));
    }
    
    // Validate name if provided (for first-time users)
    if (name != null && name.trim().isEmpty) {
      return const Left(ValidationFailure('Name is required for first-time users'));
    }
    
    // Validate address if provided (for first-time users)
    if (address != null && address.trim().isEmpty) {
      return const Left(ValidationFailure('Address is required for first-time users'));
    }
    
    return await repository.verifyOtp(mobileNumber, otp, name: name, address: address);
  }
}

class VerifyOtpParams extends Equatable {
  final String mobileNumber;
  final String otp;
  
  const VerifyOtpParams({
    required this.mobileNumber,
    required this.otp,
  });
  
  @override
  List<Object> get props => [mobileNumber, otp];
}
