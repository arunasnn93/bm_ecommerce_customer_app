import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_text_styles.dart';
import 'core/config/app_config.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/store/presentation/bloc/store_bloc.dart';
import 'features/orders/presentation/bloc/orders_bloc.dart';
import 'features/offers/presentation/bloc/offers_bloc.dart';
import 'shared/services/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  
  // Print configuration for debugging
  print('🚀 App Configuration:');
  print('   Environment: ${AppConfig.environment.name}');
  print('   Base URL: ${AppConfig.baseUrl}');
  print('   Demo Mode: ${AppConfig.useDemoMode}');
  print('   Logging: ${AppConfig.enableLogging}');
  print('   Full API URL: ${AppConfig.baseUrl}${AppConfig.apiVersion}');
  
  runApp(const BeenaMartApp());
}

class BeenaMartApp extends StatelessWidget {
  const BeenaMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthBloc>(
      future: DependencyInjection.getAuthBloc(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }
        
        final authBloc = snapshot.data!;
        
        return FutureBuilder<StoreBloc>(
          future: DependencyInjection.getStoreBloc(),
          builder: (context, storeSnapshot) {
            if (storeSnapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
            
            if (storeSnapshot.hasError) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text('Error: ${storeSnapshot.error}'),
                  ),
                ),
              );
            }
            
            final storeBloc = storeSnapshot.data!;
            
            return FutureBuilder<OrdersBloc>(
              future: DependencyInjection.getOrdersBloc(),
              builder: (context, ordersSnapshot) {
                if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                  return const MaterialApp(
                    home: Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                
                if (ordersSnapshot.hasError) {
                  return MaterialApp(
                    home: Scaffold(
                      body: Center(
                        child: Text('Error: ${ordersSnapshot.error}'),
                      ),
                    ),
                  );
                }
                
                final ordersBloc = ordersSnapshot.data!;
                
                return FutureBuilder<OffersBloc>(
                  future: DependencyInjection.getOffersBloc(),
                  builder: (context, offersSnapshot) {
                    if (offersSnapshot.connectionState == ConnectionState.waiting) {
                      return const MaterialApp(
                        home: Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                    
                    if (offersSnapshot.hasError) {
                      return MaterialApp(
                        home: Scaffold(
                          body: Center(
                            child: Text('Error: ${offersSnapshot.error}'),
                          ),
                        ),
                      );
                    }
                    
                    final offersBloc = offersSnapshot.data!;
                    
                                        return MultiBlocProvider(
                      providers: [
                        BlocProvider<AuthBloc>.value(value: authBloc),
                        BlocProvider<StoreBloc>.value(value: storeBloc),
                        BlocProvider<OrdersBloc>.value(value: ordersBloc),
                        BlocProvider<OffersBloc>.value(value: offersBloc),
                      ],
                      child: MaterialApp(
                        title: 'Beena Mart',
                        debugShowCheckedModeBanner: false,
                        theme: ThemeData(
                          primarySwatch: Colors.green,
                          primaryColor: AppColors.primary,
                          scaffoldBackgroundColor: AppColors.background,
                          appBarTheme: AppBarTheme(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            centerTitle: true,
                            titleTextStyle: AppTextStyles.h5.copyWith(
                              color: AppColors.surface,
                              fontWeight: FontWeight.bold,
                            ),
                            iconTheme: const IconThemeData(color: AppColors.surface),
                          ),
                          elevatedButtonTheme: ElevatedButtonThemeData(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                          ),
                          inputDecorationTheme: InputDecorationTheme(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          colorScheme: ColorScheme.fromSeed(
                            seedColor: AppColors.primary,
                            brightness: Brightness.light,
                          ),
                          useMaterial3: true,
                        ),
                        home: const SplashPage(),
                        routes: {
                          '/splash': (context) => const SplashPage(),
                          '/login': (context) => const LoginPage(),
                          '/home': (context) => const HomePage(),
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
