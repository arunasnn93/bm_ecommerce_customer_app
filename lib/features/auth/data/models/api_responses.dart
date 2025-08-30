import 'package:json_annotation/json_annotation.dart';

part 'api_responses.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;
  
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
    );
  }
  
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': data != null ? toJsonT(data!) : null,
      'error': error,
    };
  }
}

@JsonSerializable()
class SendOtpResponse {
  final String mobile;
  
  const SendOtpResponse({
    required this.mobile,
  });
  
  factory SendOtpResponse.fromJson(Map<String, dynamic> json) => _$SendOtpResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SendOtpResponseToJson(this);
}

@JsonSerializable()
class UserResponse {
  final String id;
  final String mobile;
  final String name;
  final String role;
  @JsonKey(name: 'isNewUser')
  final bool isNewUser;
  
  const UserResponse({
    required this.id,
    required this.mobile,
    required this.name,
    required this.role,
    required this.isNewUser,
  });
  
  factory UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}

@JsonSerializable()
class SessionResponse {
  final Map<String, dynamic> properties;
  final Map<String, dynamic> user;
  
  const SessionResponse({
    required this.properties,
    required this.user,
  });
  
  factory SessionResponse.fromJson(Map<String, dynamic> json) => _$SessionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SessionResponseToJson(this);
}

@JsonSerializable()
class VerifyOtpResponse {
  final UserResponse user;
  final SessionResponse session;
  
  const VerifyOtpResponse({
    required this.user,
    required this.session,
  });
  
  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) => _$VerifyOtpResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyOtpResponseToJson(this);
}
