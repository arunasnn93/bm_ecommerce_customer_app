part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SendOtpRequested extends AuthEvent {
  final String mobileNumber;

  const SendOtpRequested(this.mobileNumber);

  @override
  List<Object> get props => [mobileNumber];
}

class CheckUserExistsRequested extends AuthEvent {
  final String mobileNumber;
  
  const CheckUserExistsRequested(this.mobileNumber);
  
  @override
  List<Object> get props => [mobileNumber];
}

class VerifyOtpRequested extends AuthEvent {
  final String mobileNumber;
  final String otp;
  final String? name;
  final String? address;

  const VerifyOtpRequested({
    required this.mobileNumber,
    required this.otp,
    this.name,
    this.address,
  });

  @override
  List<Object> get props => [mobileNumber, otp, name ?? '', address ?? ''];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
