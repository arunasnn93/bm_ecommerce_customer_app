import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Core
    final apiClient = ApiClient();
    
    // Shared Preferences
    final sharedPreferences = await SharedPreferences.getInstance();
    
    // Auth Data Sources
    final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);
    final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences);
    
    // Auth Repository
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    
    // Auth Use Cases
    final sendOtpUseCase = SendOtpUseCase(authRepository);
    final verifyOtpUseCase = VerifyOtpUseCase(authRepository);
    
    // Auth BLoC
    final authBloc = AuthBloc(
      sendOtpUseCase: sendOtpUseCase,
      verifyOtpUseCase: verifyOtpUseCase,
    );
    
    // Register dependencies (you can use a service locator like get_it here)
    // For now, we'll pass them directly to the app
  }
  
  static Future<AuthBloc> getAuthBloc() async {
    // Core
    final apiClient = ApiClient();
    
    // Shared Preferences
    final sharedPreferences = await SharedPreferences.getInstance();
    
    // Auth Data Sources
    final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);
    final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences);
    
    // Auth Repository
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    
    // Auth Use Cases
    final sendOtpUseCase = SendOtpUseCase(authRepository);
    final verifyOtpUseCase = VerifyOtpUseCase(authRepository);
    
    // Auth BLoC
    return AuthBloc(
      sendOtpUseCase: sendOtpUseCase,
      verifyOtpUseCase: verifyOtpUseCase,
    );
  }
}
