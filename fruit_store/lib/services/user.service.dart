// lib/services/user.service.dart
import '../models/user.model.dart';
import '../constants/user.constant.dart';
import 'api.service.dart';

/// CRUD operations for User resources.
class UserService {
  final ApiService _api;

  UserService(this._api);

  /// Gets the currently authenticated user's profile.
  Future<User> getByEmail(String email) async {
    final data = await _api.get('/api/v1/account/get-by-email?email=$email');
    return User.fromJson(data);
  }

  /// Get profile for the currently logged-in user (customer endpoint).
  Future<Map<String, dynamic>> getProfile() async {
    return await _api.get('/api/v1/account-profile/profile');
  }

  /// Update profile for the currently logged-in user.
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await _api.put('/api/v1/account-profile/update', data: data);
  }

  Future<List<User>> getAvailableStaff() async {
    final data = await _api.get('/api/v1/account/available-staff');
    final items = data['data'] as List<dynamic>;
    return items
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a paginated list of users.
  Future<PaginatedResponse> getAll({
    int? pageSize,
    int? pageIndex,
    UserStatus? status,
    UserRole? role,
  }) async {
    final query = <String, String>{};
    if (pageSize != null) query['pageSize'] = pageSize.toString();
    if (pageIndex != null) query['pageIndex'] = pageIndex.toString();
    if (status != null) query['status'] = status.name.toUpperCase();
    if (role != null) query['role'] = role.name;
    final data = await _api.get('/api/v1/account/get-all', query: query);
    return PaginatedResponse.fromJson(data);
  }

  /// Creates a new user with the given [request] data.
  /// Requires ADMIN role.
  Future<User> create(CreateUserRequest request) async {
    final data = await _api.post(
      '/api/v1/account/create',
      data: request.toJson(),
    );
    return User.fromJson(data);
  }

  /// Updates an existing user by [id] with the given [request] data.
  Future<User> update(int id, UpdateUserRequest request) async {
    final data = await _api.put(
      '/api/v1/account/update/$id',
      data: request.toJson(),
    );
    return User.fromJson(data);
  }

  Future<void> updatePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    await _api.patch(
      '/api/v1/account/update-password',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<void> updateStatus(int id) async {
    await _api.patch('/api/v1/account/update-status/$id');
  }

  Future<void> updateRole(int id, String roleId) async {
    await _api.patch(
      '/api/v1/account/update-role',
      data: {'accountId': id, 'roleId': roleId},
    );
  }
}