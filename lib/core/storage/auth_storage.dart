import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStorageProvider = Provider<AuthStorage>((_) => AuthStorage());

class AuthStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _kToken = 'blume_token';
  static const _kRole = 'blume_role';

  Future<void> saveToken(String token) =>
      _storage.write(key: _kToken, value: token);

  Future<String?> getToken() => _storage.read(key: _kToken);

  Future<void> saveRole(String role) =>
      _storage.write(key: _kRole, value: role);

  Future<String?> getRole() => _storage.read(key: _kRole);

  Future<bool> hasToken() async {
    final token = await _storage.read(key: _kToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() => _storage.deleteAll();
}
