// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendOtpRequest _$SendOtpRequestFromJson(Map<String, dynamic> json) =>
    SendOtpRequest(
      mobile: json['mobile'] as String,
    );

Map<String, dynamic> _$SendOtpRequestToJson(SendOtpRequest instance) =>
    <String, dynamic>{
      'mobile': instance.mobile,
    };

VerifyOtpRequest _$VerifyOtpRequestFromJson(Map<String, dynamic> json) =>
    VerifyOtpRequest(
      mobile: json['mobile'] as String,
      otp: json['otp'] as String,
      name: json['name'] as String?,
      address: json['address'] as String?,
      fcmToken: json['fcm_token'] as String?,
    );

Map<String, dynamic> _$VerifyOtpRequestToJson(VerifyOtpRequest instance) =>
    <String, dynamic>{
      'mobile': instance.mobile,
      'otp': instance.otp,
      'name': instance.name,
      'address': instance.address,
      'fcm_token': instance.fcmToken,
    };

RefreshTokenRequest _$RefreshTokenRequestFromJson(Map<String, dynamic> json) =>
    RefreshTokenRequest(
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$RefreshTokenRequestToJson(
        RefreshTokenRequest instance) =>
    <String, dynamic>{
      'refresh_token': instance.refreshToken,
    };
