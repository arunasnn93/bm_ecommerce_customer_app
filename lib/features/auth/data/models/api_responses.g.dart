// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
      'error': instance.error,
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

SendOtpResponse _$SendOtpResponseFromJson(Map<String, dynamic> json) =>
    SendOtpResponse(
      mobile: json['mobile'] as String,
    );

Map<String, dynamic> _$SendOtpResponseToJson(SendOtpResponse instance) =>
    <String, dynamic>{
      'mobile': instance.mobile,
    };

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
      id: json['id'] as String,
      mobile: json['mobile'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      isNewUser: json['isNewUser'] as bool,
    );

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mobile': instance.mobile,
      'name': instance.name,
      'role': instance.role,
      'isNewUser': instance.isNewUser,
    };

SessionResponse _$SessionResponseFromJson(Map<String, dynamic> json) =>
    SessionResponse(
      properties: json['properties'] as Map<String, dynamic>,
      user: json['user'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SessionResponseToJson(SessionResponse instance) =>
    <String, dynamic>{
      'properties': instance.properties,
      'user': instance.user,
    };

VerifyOtpResponse _$VerifyOtpResponseFromJson(Map<String, dynamic> json) =>
    VerifyOtpResponse(
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      session:
          SessionResponse.fromJson(json['session'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerifyOtpResponseToJson(VerifyOtpResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'session': instance.session,
    };
