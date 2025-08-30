import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_result.dart';
import 'user_model.dart';

part 'auth_result_model.g.dart';

@JsonSerializable()
class AuthResultModel {
  final UserModel user;
  final String token;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  
  const AuthResultModel({
    required this.user,
    required this.token,
    required this.expiresAt,
  });
  
  factory AuthResultModel.fromJson(Map<String, dynamic> json) => _$AuthResultModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthResultModelToJson(this);
  
  factory AuthResultModel.fromEntity(AuthResult authResult) {
    return AuthResultModel(
      user: UserModel.fromEntity(authResult.user),
      token: authResult.token,
      expiresAt: authResult.expiresAt,
    );
  }
  
  AuthResult toEntity() {
    return AuthResult(
      user: user.toEntity(),
      token: token,
      expiresAt: expiresAt,
    );
  }
}
