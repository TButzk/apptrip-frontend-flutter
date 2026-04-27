import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/place.dart';
import '../models/route.dart';
import 'api_client.dart';

class RouteService {
  const RouteService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TripRoute>> listPublishedRoutes({
    int skip = 0,
    int take = 30,
  }) async {
    return _getRouteList('/routes/published', skip: skip, take: take);
  }

  Future<List<TripRoute>> listMyRoutes({int skip = 0, int take = 30}) async {
    return _getRouteList('/routes/mine', skip: skip, take: take);
  }

  Future<TripRoute> getRouteById(String routeId) async {
    return _withApiErrors(() async {
      final json = await _apiClient.get('/routes/$routeId');
      final response = DtoResponse<TripRoute>.fromJson(
        json,
        (data) => TripRoute.fromJson(data as Map<String, dynamic>),
      );

      final route = response.data;
      if (route == null) {
        throw ApiException(response.error ?? 'Nao foi possivel carregar rota.');
      }

      return route;
    });
  }

  Future<List<Place>> getRoutePlaces(String routeId) async {
    return _withApiErrors(() async {
      final json = await _apiClient.get(
        '/routes/$routeId/places',
        queryParameters: {'skip': 0, 'take': 500},
      );
      final response = PageResponse<Place>.fromJson(
        json,
        (data) => Place.fromJson(data as Map<String, dynamic>),
      );

      if (response.error != null) {
        throw ApiException(response.error!);
      }

      return response.data;
    });
  }

  Future<TripRoute> createRoute(String name) async {
    return _withApiErrors(() async {
      final json = await _apiClient.post('/routes', data: {'name': name});
      final response = DtoResponse<TripRoute>.fromJson(
        json,
        (data) => TripRoute.fromJson(data as Map<String, dynamic>),
      );

      final route = response.data;
      if (route == null) {
        throw ApiException(response.error ?? 'Nao foi possivel criar rota.');
      }

      return route;
    });
  }

  Future<Place> createPlace(CreatePlaceRequest request) async {
    return _withApiErrors(() async {
      final json = await _apiClient.post('/places', data: request.toJson());
      final response = DtoResponse<Place>.fromJson(
        json,
        (data) => Place.fromJson(data as Map<String, dynamic>),
      );

      final place = response.data;
      if (place == null) {
        throw ApiException(
          response.error ?? 'Nao foi possivel registrar ponto.',
        );
      }

      return place;
    });
  }

  Future<TripRoute> publishRoute(String routeId) async {
    return _changeRouteStatus(routeId, 'publish');
  }

  Future<TripRoute> finalizeRoute(String routeId) async {
    return _changeRouteStatus(routeId, 'finalize');
  }

  Future<List<TripRoute>> _getRouteList(
    String path, {
    required int skip,
    required int take,
  }) async {
    return _withApiErrors(() async {
      final json = await _apiClient.get(
        path,
        queryParameters: {'skip': skip, 'take': take},
      );
      final response = PageResponse<TripRoute>.fromJson(
        json,
        (data) => TripRoute.fromJson(data as Map<String, dynamic>),
      );

      if (response.error != null) {
        throw ApiException(response.error!);
      }

      return response.data;
    });
  }

  Future<TripRoute> _changeRouteStatus(String routeId, String action) async {
    return _withApiErrors(() async {
      final json = await _apiClient.patch('/routes/$routeId/$action');
      final response = DtoResponse<TripRoute>.fromJson(
        json,
        (data) => TripRoute.fromJson(data as Map<String, dynamic>),
      );

      final route = response.data;
      if (route == null) {
        throw ApiException(
          response.error ?? 'Nao foi possivel atualizar rota.',
        );
      }

      return route;
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
