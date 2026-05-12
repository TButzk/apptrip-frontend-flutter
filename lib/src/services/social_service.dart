import 'package:dio/dio.dart';

import '../models/api_response.dart';
import '../models/social_content.dart';
import 'api_client.dart';

class SocialService {
  const SocialService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TripPost>> listPosts({int skip = 0, int take = 200}) async {
    return _withApiErrors(() async {
      final json = await _apiClient.get(
        '/posts',
        queryParameters: {'skip': skip, 'take': take},
      );
      final response = PageResponse<TripPost>.fromJson(
        json,
        (data) => TripPost.fromJson(data as Map<String, dynamic>),
      );

      if (response.error != null) {
        throw ApiException(response.error!);
      }

      return response.data;
    });
  }

  Future<List<TripPost>> listPlacePosts(String placeId) async {
    final posts = await listPosts();
    return posts.where((post) => post.placeId == placeId).toList();
  }

  Future<TripPost> createPost(CreatePostRequest request) async {
    return _withApiErrors(() async {
      final json = await _apiClient.post('/posts', data: request.toJson());
      final response = DtoResponse<TripPost>.fromJson(
        json,
        (data) => TripPost.fromJson(data as Map<String, dynamic>),
      );

      final post = response.data;
      if (post == null) {
        throw ApiException(
          response.error ?? 'Nao foi possivel criar registro.',
        );
      }

      return post;
    });
  }

  Future<List<TripMedia>> listPostMedia(String postId) async {
    return _withApiErrors(() async {
      final json = await _apiClient.get(
        '/posts/$postId/media',
        queryParameters: {'skip': 0, 'take': 100},
      );
      final response = PageResponse<TripMedia>.fromJson(
        json,
        (data) => TripMedia.fromJson(data as Map<String, dynamic>),
      );

      if (response.error != null) {
        throw ApiException(response.error!);
      }

      return response.data;
    });
  }

  Future<TripMedia> createMedia(
    String postId,
    CreateMediaRequest request,
  ) async {
    return _withApiErrors(() async {
      final json = await _apiClient.post(
        '/posts/$postId/media',
        data: request.toJson(),
      );
      final response = DtoResponse<TripMedia>.fromJson(
        json,
        (data) => TripMedia.fromJson(data as Map<String, dynamic>),
      );

      final media = response.data;
      if (media == null) {
        throw ApiException(response.error ?? 'Nao foi possivel criar midia.');
      }

      return media;
    });
  }

  Future<List<TripComment>> listPostComments(String postId) async {
    return _withApiErrors(() async {
      final json = await _apiClient.get(
        '/posts/$postId/comments',
        queryParameters: {'skip': 0, 'take': 100},
      );
      final response = PageResponse<TripComment>.fromJson(
        json,
        (data) => TripComment.fromJson(data as Map<String, dynamic>),
      );

      if (response.error != null) {
        throw ApiException(response.error!);
      }

      return response.data;
    });
  }

  Future<TripComment> createComment(String postId, String message) async {
    return _withApiErrors(() async {
      final json = await _apiClient.post(
        '/posts/$postId/comments',
        data: {'message': message},
      );
      final response = DtoResponse<TripComment>.fromJson(
        json,
        (data) => TripComment.fromJson(data as Map<String, dynamic>),
      );

      final comment = response.data;
      if (comment == null) {
        throw ApiException(
          response.error ?? 'Nao foi possivel criar comentario.',
        );
      }

      return comment;
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
