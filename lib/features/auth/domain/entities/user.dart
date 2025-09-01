import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String mobileNumber;
  final String? email;
  final String? profileImage;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const User({
    required this.id,
    required this.name,
    required this.mobileNumber,
    this.email,
    this.profileImage,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [
    id,
    name,
    mobileNumber,
    email,
    profileImage,
    address,
    createdAt,
    updatedAt,
  ];
  
  User copyWith({
    String? id,
    String? name,
    String? mobileNumber,
    String? email,
    String? profileImage,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
