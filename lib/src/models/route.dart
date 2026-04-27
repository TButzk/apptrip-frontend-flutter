enum RouteStatus {
  draft,
  published,
  finished;

  factory RouteStatus.fromBackend(String? value) {
    return switch (value) {
      'PUBLISHED' => RouteStatus.published,
      'FINISHED' => RouteStatus.finished,
      _ => RouteStatus.draft,
    };
  }

  String get label {
    return switch (this) {
      RouteStatus.draft => 'DRAFT',
      RouteStatus.published => 'PUBLISHED',
      RouteStatus.finished => 'FINISHED',
    };
  }
}

class TripRoute {
  const TripRoute({
    required this.id,
    required this.name,
    required this.userId,
    required this.placeIds,
    required this.status,
    this.publishedAt,
    this.finalizedAt,
  });

  final String id;
  final String name;
  final String userId;
  final List<String> placeIds;
  final RouteStatus status;
  final DateTime? publishedAt;
  final DateTime? finalizedAt;

  factory TripRoute.fromJson(Map<String, dynamic> json) {
    return TripRoute(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      placeIds: _stringListFromJson(json['placeIds']),
      status: RouteStatus.fromBackend(json['status'] as String?),
      publishedAt: _dateTimeFromJson(json['publishedAt']),
      finalizedAt: _dateTimeFromJson(json['finalizedAt']),
    );
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
