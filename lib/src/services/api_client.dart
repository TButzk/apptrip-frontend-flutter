import 'package:dio/dio.dart';

import '../config/app_config.dart';

class ApiClient {
  ApiClient(AppConfig config)
    : _dio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  final Dio _dio;

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<Object?>(
      path,
      queryParameters: queryParameters,
      options: _authorizationOptions(),
    );

    return _responseAsMap(response.data);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.post<Object?>(
      path,
      data: data,
      options: _authorizationOptions(),
    );

    return _responseAsMap(response.data);
  }

  Future<Map<String, dynamic>> patch(String path) async {
    final response = await _dio.patch<Object?>(
      path,
      options: _authorizationOptions(),
    );

    return _responseAsMap(response.data);
  }

  Options _authorizationOptions() {
    final token = _token;

    if (token == null || token.isEmpty) {
      return Options();
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Map<String, dynamic> _responseAsMap(Object? response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return response.map((key, value) => MapEntry(key.toString(), value));
    }

    throw const ApiException('Resposta inesperada da API.');
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
