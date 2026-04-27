enum PlaceType {
  public,
  private;

  String get backendValue {
    return switch (this) {
      PlaceType.public => 'Public',
      PlaceType.private => 'Private',
    };
  }
}

class Place {
  const Place({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.routeId,
    required this.type,
    required this.eventIds,
    this.sequence,
    this.capturedAt,
    this.neighborhood = '',
    this.street = '',
    this.streetNumber = '',
    this.complement = '',
    this.city = '',
    this.postalCode = '',
    this.country = '',
    this.state = '',
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int? sequence;
  final DateTime? capturedAt;
  final String neighborhood;
  final String street;
  final String streetNumber;
  final String complement;
  final String city;
  final String postalCode;
  final String country;
  final String state;
  final String type;
  final String routeId;
  final List<String> eventIds;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      sequence: (json['sequence'] as num?)?.toInt(),
      capturedAt: _dateTimeFromJson(json['capturedAt']),
      neighborhood: json['neighborhood'] as String? ?? '',
      street: json['street'] as String? ?? '',
      streetNumber: json['streetNumber'] as String? ?? '',
      complement: json['complement'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      country: json['country'] as String? ?? '',
      state: json['state'] as String? ?? '',
      type: json['type'] as String? ?? '',
      routeId: json['routeId'] as String? ?? '',
      eventIds: _stringListFromJson(json['eventIds']),
    );
  }
}

class CreatePlaceRequest {
  const CreatePlaceRequest({
    required this.name,
    required this.routeId,
    required this.latitude,
    required this.longitude,
    required this.sequence,
    required this.capturedAt,
    this.type = PlaceType.public,
  });

  final String name;
  final String routeId;
  final double latitude;
  final double longitude;
  final int sequence;
  final DateTime capturedAt;
  final PlaceType type;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'routeId': routeId,
      'latitude': latitude,
      'longitude': longitude,
      'sequence': sequence,
      'capturedAt': capturedAt.toUtc().toIso8601String(),
      'type': type.backendValue,
    };
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
