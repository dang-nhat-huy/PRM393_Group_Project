// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  accountId: (json['accountId'] as num).toInt(),
  email: json['email'] as String,
  accountProfile: json['accountProfile'] == null
      ? null
      : AccountProfile.fromJson(json['accountProfile'] as Map<String, dynamic>),
  role: json['role'] == null
      ? UserRole.customer
      : UserRole.userRoleFromJson(json['role'] as String),
  status:
      $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
      UserStatus.active,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'accountId': instance.accountId,
  'email': instance.email,
  'role': UserRole.userRoleToJson(instance.role),
  'status': _$UserStatusEnumMap[instance.status]!,
  'accountProfile': instance.accountProfile,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'ACTIVE',
  UserStatus.deactivated: 'DEACTIVATED',
  UserStatus.suspended: 'SUSPENDED',
  UserStatus.banned: 'BANNED',
};

CreateUserRequest _$CreateUserRequestFromJson(Map<String, dynamic> json) =>
    CreateUserRequest(
      email: json['email'] as String,
      password: json['password'] as String?,
      phone: json['phone'] as String?,
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      role: json['role'] == null
          ? UserRole.customer
          : UserRole.userRoleFromJson(json['role'] as String),
      fullName: json['fullName'] as String?,
      address: json['address'] as String?,
      images: json['images'] as String?,
    );

Map<String, dynamic> _$CreateUserRequestToJson(CreateUserRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'phone': instance.phone,
      'gender': _$GenderEnumMap[instance.gender],
      'role': UserRole.userRoleToJson(instance.role),
      'fullName': instance.fullName,
      'address': instance.address,
      'images': instance.images,
    };

const _$GenderEnumMap = {
  Gender.male: 'Male',
  Gender.female: 'Female',
  Gender.other: 'Other',
};

UpdateUserRequest _$UpdateUserRequestFromJson(Map<String, dynamic> json) =>
    UpdateUserRequest(
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      role: UserRole.userRoleFromJson(json['role'] as String),
      fullName: json['fullName'] as String?,
      address: json['address'] as String?,
      images: json['images'] as String?,
    );

Map<String, dynamic> _$UpdateUserRequestToJson(UpdateUserRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'phone': instance.phone,
      'gender': _$GenderEnumMap[instance.gender],
      'role': UserRole.userRoleToJson(instance.role),
      'fullName': instance.fullName,
      'address': instance.address,
      'images': instance.images,
    };

PaginatedResponse _$PaginatedResponseFromJson(Map<String, dynamic> json) =>
    PaginatedResponse(
      totalItemCount: (json['totalItemCount'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPagesCount: (json['totalPagesCount'] as num).toInt(),
      pageIndex: (json['pageIndex'] as num).toInt(),
      next: json['next'] as bool,
      previous: json['previous'] as bool,
      items: (json['items'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaginatedResponseToJson(PaginatedResponse instance) =>
    <String, dynamic>{
      'totalItemCount': instance.totalItemCount,
      'pageSize': instance.pageSize,
      'totalPagesCount': instance.totalPagesCount,
      'pageIndex': instance.pageIndex,
      'next': instance.next,
      'previous': instance.previous,
      'items': instance.items,
    };
