part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentSuccessfully extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthResult authResult;
  
  const AuthSuccess(this.authResult);
  
  @override
  List<Object> get props => [authResult];
}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object> get props => [message];
}
