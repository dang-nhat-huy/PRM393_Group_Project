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
  admin(0, 'Admin'),
  manager(1, 'Manager'),
  customer(2, 'Customer'),
  staff(3, 'Staff');

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
