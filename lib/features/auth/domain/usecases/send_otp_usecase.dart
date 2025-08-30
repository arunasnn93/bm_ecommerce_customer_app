import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;
  
  SendOtpUseCase(this.repository);
  
  Future<Either<Failure, void>> call(String mobileNumber) async {
    // Validate mobile number
    if (mobileNumber.length != AppConstants.mobileNumberLength) {
      return const Left(ValidationFailure('Please enter a valid 10-digit mobile number'));
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(mobileNumber)) {
      return const Left(ValidationFailure('Mobile number should contain only digits'));
    }
    
    return await repository.sendOtp(mobileNumber);
  }
}

class SendOtpParams extends Equatable {
  final String mobileNumber;
  
  const SendOtpParams(this.mobileNumber);
  
  @override
  List<Object> get props => [mobileNumber];
}
