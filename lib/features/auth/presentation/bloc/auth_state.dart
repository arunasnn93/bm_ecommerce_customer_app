part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentSuccessfully extends AuthState {}

class CheckUserExistsLoading extends AuthState {}

class CheckUserExistsSuccess extends AuthState {
  final CheckUserResponse userData;
  
  const CheckUserExistsSuccess(this.userData);
  
  @override
  List<Object> get props => [userData];
}

class CheckUserExistsFailure extends AuthState {
  final String message;
  
  const CheckUserExistsFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

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

class LogoutSuccess extends AuthState {}
