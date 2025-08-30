import 'package:json_annotation/json_annotation.dart';

part 'api_requests.g.dart';

@JsonSerializable()
class SendOtpRequest {
  final String mobile;
  
  const SendOtpRequest({
    required this.mobile,
  });
  
  factory SendOtpRequest.fromJson(Map<String, dynamic> json) => _$SendOtpRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SendOtpRequestToJson(this);
}

@JsonSerializable()
class VerifyOtpRequest {
  final String mobile;
  final String otp;
  final String? name;
  final String? address;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;
  
  const VerifyOtpRequest({
    required this.mobile,
    required this.otp,
    this.name,
    this.address,
    this.fcmToken,
  });
  
  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) => _$VerifyOtpRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyOtpRequestToJson(this);
}

@JsonSerializable()
class RefreshTokenRequest {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  
  const RefreshTokenRequest({
    required this.refreshToken,
  });
  
  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => _$RefreshTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}
