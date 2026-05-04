import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider), ref.watch(authStorageProvider));
});

class AuthRepository {
  final Dio _dio;
  final AuthStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<UserModel> login(String email, String password) async {
    final response = await _dio.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    final data = _unwrapData(response.data);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String?;
    if (token != null) {
      await _storage.saveToken(token);
      await _storage.saveRole(user.role);
    }
    return user;
  }

  Future<UserModel> register(String fullName, String email, String password) async {
    final response = await _dio.post(ApiConstants.register, data: {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
    final data = _unwrapData(response.data);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String?;
    if (token != null) {
      await _storage.saveToken(token);
      await _storage.saveRole(user.role);
    }
    return user;
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiConstants.me);
    final raw = response.data;
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      final inner = raw['data'];
      if (inner is Map<String, dynamic> && inner.containsKey('user')) {
        return UserModel.fromJson(inner['user'] as Map<String, dynamic>);
      }
      return UserModel.fromJson(inner as Map<String, dynamic>);
    }
    return UserModel.fromJson(raw as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {}
    await _storage.clearAll();
  }

  Future<void> completeOnboarding(String username, String role) async {
    await _dio.post(ApiConstants.onboarding, data: {
      'username': username,
      'role': role,
    });
    await _storage.saveRole(role);
  }

  Future<void> requestPasswordReset(String email) async {
    await _dio.post(ApiConstants.passwordResetRequest, data: {'email': email});
  }

  Future<void> confirmPasswordReset(
      String email, String code, String newPassword) async {
    await _dio.post(ApiConstants.passwordResetConfirm, data: {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    });
  }

  Map<String, dynamic> _unwrapData(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data')) return raw['data'] as Map<String, dynamic>;
      return raw;
    }
    throw const FormatException('Unexpected response format');
  }
}
