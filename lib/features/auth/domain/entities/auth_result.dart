import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthResult extends Equatable {
  final User user;
  final String token;
  final DateTime expiresAt;
  
  const AuthResult({
    required this.user,
    required this.token,
    required this.expiresAt,
  });
  
  @override
  List<Object> get props => [user, token, expiresAt];
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  AuthResult copyWith({
    User? user,
    String? token,
    DateTime? expiresAt,
  }) {
    return AuthResult(
      user: user ?? this.user,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
