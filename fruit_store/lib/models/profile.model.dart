// lib/models/profile.model.dart
import 'package:json_annotation/json_annotation.dart';
import '../constants/user.constant.dart';

part 'profile.model.g.dart';

@JsonSerializable()
class AccountProfile {
  @JsonKey(name: 'accountProfileId')
  final int accountProfileId;

  final Gender? gender;
  final String? phone;

  @JsonKey(name: 'fullname')
  final String? fullName;

  final String? address;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  const AccountProfile({
    required this.accountProfileId,
    this.gender,
    this.phone,
    this.fullName,
    this.address,
    required this.createdAt,
    this.updatedAt,
  });

  factory AccountProfile.fromJson(Map<String, dynamic> json) =>
      _$AccountProfileFromJson(json);
  Map<String, dynamic> toJson() => _$AccountProfileToJson(this);
}

// Request DTO

@JsonSerializable()
class CreateProfileRequest {
  final String fullName;
  final String phone;
  final Gender gender;
  final String address;

  const CreateProfileRequest({
    required this.fullName,
    required this.phone,
    required this.gender,
    required this.address,
  });

  factory CreateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProfileRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateProfileRequestToJson(this);
}

@JsonSerializable()
class UpdateProfileRequest {
  final String? fullName;
  final String? phone;
  final Gender? gender;
  final String? address;

  const UpdateProfileRequest({
    this.fullName,
    this.phone,
    this.gender,
    this.address,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}