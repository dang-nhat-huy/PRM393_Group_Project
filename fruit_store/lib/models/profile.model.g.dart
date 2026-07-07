// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountProfile _$AccountProfileFromJson(Map<String, dynamic> json) =>
    AccountProfile(
      accountProfileId: (json['accountProfileId'] as num).toInt(),
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      phone: json['phone'] as String?,
      fullName: json['fullname'] as String?,
      address: json['address'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$AccountProfileToJson(AccountProfile instance) =>
    <String, dynamic>{
      'accountProfileId': instance.accountProfileId,
      'gender': _$GenderEnumMap[instance.gender],
      'phone': instance.phone,
      'fullname': instance.fullName,
      'address': instance.address,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

const _$GenderEnumMap = {
  Gender.male: 'Male',
  Gender.female: 'Female',
  Gender.other: 'Other',
};

CreateProfileRequest _$CreateProfileRequestFromJson(
  Map<String, dynamic> json,
) => CreateProfileRequest(
  fullName: json['fullName'] as String,
  phone: json['phone'] as String,
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  address: json['address'] as String,
);

Map<String, dynamic> _$CreateProfileRequestToJson(
  CreateProfileRequest instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'phone': instance.phone,
  'gender': _$GenderEnumMap[instance.gender]!,
  'address': instance.address,
};

UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequest(
  fullName: json['fullName'] as String?,
  phone: json['phone'] as String?,
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  address: json['address'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  UpdateProfileRequest instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'phone': instance.phone,
  'gender': _$GenderEnumMap[instance.gender],
  'address': instance.address,
};
