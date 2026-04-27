import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  const AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<UserLogin> login({
    required String email,
    required String password,
  }) async {
    return _withApiErrors(() async {
      final json = await _apiClient.post(
        '/users-auth/login',
        data: {'email': email, 'password': password},
      );

      final response = DtoResponse<UserLogin>.fromJson(
        json,
        (data) => UserLogin.fromJson(data as Map<String, dynamic>),
      );

      final userLogin = response.data;
      if (userLogin == null) {
        throw ApiException(response.error ?? 'Nao foi possivel autenticar.');
      }

      return userLogin;
    });
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _withApiErrors(() async {
      final json = await _apiClient.post(
        '/users-auth',
        data: {'name': name, 'email': email, 'password': password},
      );

      final response = DtoResponse<User>.fromJson(
        json,
        (data) => User.fromJson(data as Map<String, dynamic>),
      );

      final user = response.data;
      if (user == null) {
        throw ApiException(response.error ?? 'Nao foi possivel criar a conta.');
      }

      return user;
    });
  }
}

Future<T> _withApiErrors<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    final responseData = error.response?.data;
    if (responseData is Map && responseData['error'] is String) {
      throw ApiException(responseData['error'] as String);
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      throw const ApiException('Tempo esgotado ao conectar com a API.');
    }

    throw ApiException(error.message ?? 'Falha de comunicacao com a API.');
  }
}
