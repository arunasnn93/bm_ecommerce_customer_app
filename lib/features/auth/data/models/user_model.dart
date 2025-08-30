import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.mobileNumber,
    super.email,
    super.profileImage,
    required super.createdAt,
    required super.updatedAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      mobileNumber: user.mobileNumber,
      email: user.email,
      profileImage: user.profileImage,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
  
  User toEntity() {
    return User(
      id: id,
      name: name,
      mobileNumber: mobileNumber,
      email: email,
      profileImage: profileImage,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
