import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';
import '../../domain/entities/check_user_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, void>> sendOtp(String mobileNumber) async {
    try {
      await remoteDataSource.sendOtp(mobileNumber);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, AuthResult>> verifyOtp(String mobileNumber, String otp, {String? name, String? address}) async {
    try {
      final authResultModel = await remoteDataSource.verifyOtp(mobileNumber, otp, name: name, address: address);
      
      // Cache the authentication result
      await localDataSource.cacheAuthResult(authResultModel);
      
      return Right(authResultModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // First try to get from cache
      final cachedAuthResult = await localDataSource.getCachedAuthResult();
      if (cachedAuthResult != null && DateTime.now().isBefore(cachedAuthResult.expiresAt)) {
        return Right(cachedAuthResult.user.toEntity());
      }
      
      // If not in cache or expired, try remote
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser.toEntity());
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCachedAuthResult();
      return const Right(null);
    } catch (e) {
      // Even if remote logout fails, clear local cache
      await localDataSource.clearCachedAuthResult();
      return const Right(null);
    }
  }
  
  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final cachedAuthResult = await localDataSource.getCachedAuthResult();
      if (cachedAuthResult != null && DateTime.now().isBefore(cachedAuthResult.expiresAt)) {
        return const Right(true);
      }
      
      // If cached result is expired, try remote check
      final isRemoteAuthenticated = await remoteDataSource.isAuthenticated();
      return Right(isRemoteAuthenticated);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, AuthResult>> refreshToken() async {
    try {
      final authResultModel = await remoteDataSource.refreshToken();
      await localDataSource.cacheAuthResult(authResultModel);
      return Right(authResultModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckUserResponse>> checkUserExists(String mobileNumber) async {
    try {
      final result = await remoteDataSource.checkUserExists(mobileNumber);
      
      // Convert data model to domain entity
      final domainEntity = CheckUserResponse(
        exists: result.exists,
        user: result.user != null 
          ? UserInfo(
              id: result.user!.id,
              mobile: result.user!.mobile,
              name: result.user!.name,
              address: result.user!.address,
            )
          : null,
      );
      
      return Right(domainEntity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
