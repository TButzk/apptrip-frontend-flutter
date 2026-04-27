class DtoResponse<T> {
  const DtoResponse({required this.data, required this.error});

  final T? data;
  final String? error;

  factory DtoResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) convertData,
  ) {
    return DtoResponse<T>(
      data: json['data'] == null ? null : convertData(json['data']),
      error: json['error'] as String?,
    );
  }
}

class PageResponse<T> {
  const PageResponse({
    required this.data,
    required this.error,
    required this.page,
  });

  final List<T> data;
  final String? error;
  final PageInfo? page;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) convertItem,
  ) {
    final rawData = json['data'];
    final data = rawData is List ? rawData.map(convertItem).toList() : <T>[];
    final rawPage = json['page'];

    return PageResponse<T>(
      data: data,
      error: json['error'] as String?,
      page: rawPage is Map<String, dynamic> ? PageInfo.fromJson(rawPage) : null,
    );
  }
}

class PageInfo {
  const PageInfo({required this.totalPages, required this.totalElements});

  final int totalPages;
  final int totalElements;

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
    );
  }
}
