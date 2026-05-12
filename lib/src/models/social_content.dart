enum MediaType {
  photo,
  video,
  audio,
  gif;

  factory MediaType.fromBackend(String? value) {
    return switch (value) {
      'Video' => MediaType.video,
      'Audio' => MediaType.audio,
      'Gif' => MediaType.gif,
      _ => MediaType.photo,
    };
  }

  String get backendValue {
    return switch (this) {
      MediaType.photo => 'Photo',
      MediaType.video => 'Video',
      MediaType.audio => 'Audio',
      MediaType.gif => 'Gif',
    };
  }

  String get label {
    return switch (this) {
      MediaType.photo => 'Imagem',
      MediaType.video => 'Video',
      MediaType.audio => 'Audio',
      MediaType.gif => 'GIF',
    };
  }
}

class TripPost {
  const TripPost({
    required this.id,
    required this.title,
    required this.message,
    required this.userId,
    required this.placeId,
    required this.mediaIds,
    this.date,
  });

  final String id;
  final String title;
  final String message;
  final DateTime? date;
  final String userId;
  final String placeId;
  final List<String> mediaIds;

  factory TripPost.fromJson(Map<String, dynamic> json) {
    return TripPost(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      date: _dateTimeFromJson(json['date']),
      userId: json['userId'] as String? ?? '',
      placeId: json['placeId'] as String? ?? '',
      mediaIds: _stringListFromJson(json['mediaIds']),
    );
  }
}

class TripMedia {
  const TripMedia({
    required this.id,
    required this.postId,
    required this.name,
    required this.url,
    required this.type,
  });

  final String id;
  final String postId;
  final String name;
  final String url;
  final MediaType type;

  factory TripMedia.fromJson(Map<String, dynamic> json) {
    return TripMedia(
      id: json['id'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      type: MediaType.fromBackend(json['type'] as String?),
    );
  }
}

class TripComment {
  const TripComment({
    required this.id,
    required this.message,
    required this.postId,
    required this.userId,
  });

  final String id;
  final String message;
  final String postId;
  final String userId;

  factory TripComment.fromJson(Map<String, dynamic> json) {
    return TripComment(
      id: json['id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
    );
  }
}

class CreatePostRequest {
  const CreatePostRequest({
    required this.title,
    required this.message,
    required this.placeId,
    required this.date,
  });

  final String title;
  final String message;
  final String placeId;
  final DateTime date;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'placeId': placeId,
      'date': date.toUtc().toIso8601String(),
      'mediaIds': const <String>[],
    };
  }
}

class CreateMediaRequest {
  const CreateMediaRequest({
    required this.name,
    required this.url,
    required this.type,
  });

  final String name;
  final String url;
  final MediaType type;

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url, 'type': type.backendValue};
  }
}

List<String> _stringListFromJson(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value.whereType<Object>().map((item) => item.toString()).toList();
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
}
