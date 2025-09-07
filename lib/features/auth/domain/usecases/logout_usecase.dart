import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/logout_service.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() async {
    try {
      // Call repository logout (handles remote logout and local cache clearing)
      final result = await _repository.logout();
      
      // Additional cleanup using logout service
      await LogoutService.clearAllSessionData();
      
      return result;
    } catch (e) {
      // Even if repository logout fails, clear local data
      await LogoutService.clearAllSessionData();
      return Left(CacheFailure(e.toString()));
    }
  }
}
