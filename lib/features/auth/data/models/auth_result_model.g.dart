// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResultModel _$AuthResultModelFromJson(Map<String, dynamic> json) =>
    AuthResultModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$AuthResultModelToJson(AuthResultModel instance) =>
    <String, dynamic>{
      'user': instance.user,
      'token': instance.token,
      'expires_at': instance.expiresAt.toIso8601String(),
    };
