import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/check_user_exists_usecase.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/check_user_response.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final CheckUserExistsUseCase checkUserExistsUseCase;
  
  AuthBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.checkUserExistsUseCase,
  }) : super(AuthInitial()) {
    on<SendOtpRequested>(_onSendOtpRequested);
    on<CheckUserExistsRequested>(_onCheckUserExistsRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }
  
  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await sendOtpUseCase(event.mobileNumber);
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(OtpSentSuccessfully()),
    );
  }
  
  Future<void> _onCheckUserExistsRequested(
    CheckUserExistsRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(CheckUserExistsLoading());
    
    final result = await checkUserExistsUseCase(event.mobileNumber);
    
    result.fold(
      (failure) => emit(CheckUserExistsFailure(failure.message)),
      (userData) => emit(CheckUserExistsSuccess(userData)),
    );
  }
  
  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await verifyOtpUseCase(event.mobileNumber, event.otp, name: event.name, address: event.address);
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authResult) => emit(AuthSuccess(authResult)),
    );
  }
  
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // For now, we'll just emit initial state
    // In real implementation, this would call logout use case
    emit(AuthInitial());
  }
}
