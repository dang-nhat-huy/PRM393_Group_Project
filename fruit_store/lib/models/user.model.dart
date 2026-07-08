// lib/models/user.model.dart
import 'package:json_annotation/json_annotation.dart';
import 'profile.model.dart';
import '../constants/user.constant.dart';

part 'user.model.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'accountId')
  final int accountId;

  final String email;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? password;

  @JsonKey(fromJson: UserRole.userRoleFromJson, toJson: UserRole.userRoleToJson)
  final UserRole role;
  final UserStatus status;
  final AccountProfile? accountProfile;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  const User({
    required this.accountId,
    required this.email,
    this.password,
    this.accountProfile,
    this.role = UserRole.customer,
    this.status = UserStatus.active,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// Request DTO

@JsonSerializable()
class CreateUserRequest {
  final String email;
  final String? password;
  final String? phone;
  final Gender? gender;
  
  @JsonKey(fromJson: UserRole.userRoleFromJson, toJson: UserRole.userRoleToJson)
  final UserRole role;
  final String? fullName;
  final String? address;
  final String? images;

  const CreateUserRequest({
    required this.email,
    this.password,
    this.phone,
    this.gender,
    this.role = UserRole.customer,
    this.fullName,
    this.address,
    this.images,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}

@JsonSerializable()
class UpdateUserRequest {
  final String? email;
  final String? phone;
  final Gender? gender;
  @JsonKey(fromJson: UserRole.userRoleFromJson, toJson: UserRole.userRoleToJson)
  final UserRole? role;
  final String? fullName;
  final String? address;
  final String? images;

  const UpdateUserRequest({
    this.email,
    this.phone,
    this.gender,
    this.role,
    this.fullName,
    this.address,
    this.images,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}

@JsonSerializable()
class PaginatedResponse {
  final int totalItemCount;
  final int pageSize;
  final int totalPagesCount;
  final int pageIndex;
  final bool next;
  final bool previous;
  final List<User> items;

  const PaginatedResponse({
    required this.totalItemCount,
    required this.pageSize,
    required this.totalPagesCount,
    required this.pageIndex,
    required this.next,
    required this.previous,
    required this.items,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedResponseToJson(this);
}