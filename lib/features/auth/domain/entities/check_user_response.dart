import 'package:equatable/equatable.dart';

class CheckUserResponse extends Equatable {
  final bool exists;
  final UserInfo? user;
  
  const CheckUserResponse({
    required this.exists,
    this.user,
  });
  
  @override
  List<Object?> get props => [exists, user];
}

class UserInfo extends Equatable {
  final String id;
  final String mobile;
  final String name;
  final String? address;
  
  const UserInfo({
    required this.id,
    required this.mobile,
    required this.name,
    this.address,
  });
  
  @override
  List<Object?> get props => [id, mobile, name, address];
}
