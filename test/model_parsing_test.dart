import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/src/models/place.dart';
import 'package:frontend_flutter/src/models/route.dart';

void main() {
  test('parses route status as enum', () {
    final route = TripRoute.fromJson({
      'id': 'route-1',
      'name': 'Rota Teste',
      'userId': 'user-1',
      'placeIds': ['place-1'],
      'status': 'PUBLISHED',
    });

    expect(route.status, RouteStatus.published);
    expect(route.status.label, 'PUBLISHED');
  });

  test('serializes create place request using backend field names', () {
    final request = CreatePlaceRequest(
      name: 'Ponto 1',
      routeId: 'route-1',
      latitude: -29.1,
      longitude: -51.1,
      sequence: 1,
      capturedAt: DateTime.utc(2026, 4, 25, 10),
    );

    expect(request.toJson(), {
      'name': 'Ponto 1',
      'routeId': 'route-1',
      'latitude': -29.1,
      'longitude': -51.1,
      'sequence': 1,
      'capturedAt': '2026-04-25T10:00:00.000Z',
      'type': 'Public',
    });
  });
}
