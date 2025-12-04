import 'package:dio/dio.dart';

import 'package:sazon_recetas/core/network/network.dart';
import 'package:sazon_recetas/core/services/services.dart';

class ApiClient {
  final Dio _dio;
  final AuthTokenStorage _tokenStorage;

  ApiClient({Dio? dio, required AuthTokenStorage tokenStorage})
    : _dio = dio ?? Dio(),
      _tokenStorage = tokenStorage {
    _configureDio();
  }

  Dio get dio => _dio;

  void _configureDio() {
    _dio
      ..options.baseUrl = ApiConfig.baseUrl
      ..options.connectTimeout = const Duration(seconds: 10)
      ..options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          // Error handling can be added here
          return handler.next(error);
        },
      ),
    );
  }
}
