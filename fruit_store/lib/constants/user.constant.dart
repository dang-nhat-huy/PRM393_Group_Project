import 'package:json_annotation/json_annotation.dart';

enum Gender {
  @JsonValue('Male')
  male,
  @JsonValue('Female')
  female,
  @JsonValue('Other')
  other,
}

enum UserRole {
  admin(1, 'Admin'),
  manager(2, 'Manager'),
  customer(3, 'Customer'),
  staff(4, 'Staff');

  final int id;
  final String name;

  const UserRole(this.id, this.name);

  static UserRole userRoleFromJson(String text) {
    return UserRole.values.firstWhere(
      (r) => r.name == text,
      orElse: () => throw ArgumentError('Unknown role text: $text'),
    );
  }

  static int? userRoleToJson(UserRole? role) => role?.id;
}

enum UserStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('DEACTIVATED')
  deactivated,
  @JsonValue('SUSPENDED')
  suspended,
  @JsonValue('BANNED')
  banned,
}
