import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/check_user_exists_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/store/data/datasources/store_remote_data_source.dart';
import '../../features/store/data/repositories/store_repository_impl.dart';
import '../../features/store/domain/usecases/get_store_images_usecase.dart';
import '../../features/store/presentation/bloc/store_bloc.dart';
import '../../features/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/usecases/create_order.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';

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
    final checkUserExistsUseCase = CheckUserExistsUseCase(authRepository);
    
    // Auth BLoC
    final authBloc = AuthBloc(
      sendOtpUseCase: sendOtpUseCase,
      verifyOtpUseCase: verifyOtpUseCase,
      checkUserExistsUseCase: checkUserExistsUseCase,
    );
    
    // Store Data Sources
    final storeRemoteDataSource = StoreRemoteDataSourceImpl(apiClient);
    
    // Store Repository
    final storeRepository = StoreRepositoryImpl(storeRemoteDataSource);
    
    // Store Use Cases
    final getStoreImagesUseCase = GetStoreImagesUseCase(storeRepository);
    
    // Store BLoC
    final storeBloc = StoreBloc(getStoreImagesUseCase: getStoreImagesUseCase);
    
    // Orders Data Sources
    final ordersRemoteDataSource = OrdersRemoteDataSourceImpl(apiClient);
    
    // Orders Repository
    final ordersRepository = OrdersRepositoryImpl(ordersRemoteDataSource);
    
    // Orders Use Cases
    final createOrderUseCase = CreateOrder(ordersRepository);
    
    // Orders BLoC
    final ordersBloc = OrdersBloc(
      createOrder: createOrderUseCase,
      ordersRepository: ordersRepository,
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
    final checkUserExistsUseCase = CheckUserExistsUseCase(authRepository);
    
    // Auth BLoC
    return AuthBloc(
      sendOtpUseCase: sendOtpUseCase,
      verifyOtpUseCase: verifyOtpUseCase,
      checkUserExistsUseCase: checkUserExistsUseCase,
    );
  }
  
  static Future<StoreBloc> getStoreBloc() async {
    // Core
    final apiClient = ApiClient();
    
    // Store Data Sources
    final storeRemoteDataSource = StoreRemoteDataSourceImpl(apiClient);
    
    // Store Repository
    final storeRepository = StoreRepositoryImpl(storeRemoteDataSource);
    
    // Store Use Cases
    final getStoreImagesUseCase = GetStoreImagesUseCase(storeRepository);
    
    // Store BLoC
    return StoreBloc(getStoreImagesUseCase: getStoreImagesUseCase);
  }
  
  static Future<OrdersBloc> getOrdersBloc() async {
    // Core
    final apiClient = ApiClient();
    
    // Orders Data Sources
    final ordersRemoteDataSource = OrdersRemoteDataSourceImpl(apiClient);
    
    // Orders Repository
    final ordersRepository = OrdersRepositoryImpl(ordersRemoteDataSource);
    
    // Orders Use Cases
    final createOrderUseCase = CreateOrder(ordersRepository);
    
    // Orders BLoC
    return OrdersBloc(
      createOrder: createOrderUseCase,
      ordersRepository: ordersRepository,
    );
  }
}
