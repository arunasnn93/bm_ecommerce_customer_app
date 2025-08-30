import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';
import '../entities/check_user_response.dart';

class CheckUserExistsUseCase {
  final AuthRepository repository;

  CheckUserExistsUseCase(this.repository);

  Future<Either<Failure, CheckUserResponse>> call(String mobileNumber) async {
    if (mobileNumber.trim().isEmpty) {
      return const Left(ValidationFailure('Mobile number is required'));
    }
    
    if (mobileNumber.length < 10) {
      return const Left(ValidationFailure('Invalid mobile number'));
    }
    
    return await repository.checkUserExists(mobileNumber);
  }
}
