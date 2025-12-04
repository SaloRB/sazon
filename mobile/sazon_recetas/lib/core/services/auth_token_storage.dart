import 'package:sazon_recetas/core/services/services.dart';

class AuthTokenStorage {
  static const String _tokenKey = 'auth_token';

  final SecureStorageService _storage;

  AuthTokenStorage({required SecureStorageService storage})
    : _storage = storage;

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    return _storage.delete(key: _tokenKey);
  }
}
