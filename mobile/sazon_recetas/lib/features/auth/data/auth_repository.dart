import 'package:sazon_recetas/core/core.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _apiClient.dio.get('/auth/me');

    return response.data as Map<String, dynamic>;
  }
}
