import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';

class RouteMap extends StatelessWidget {
  const RouteMap({required this.points, super.key});

  final List<Place> points;

  @override
  Widget build(BuildContext context) {
    final coordinates = points
        .map((point) => LatLng(point.latitude, point.longitude))
        .where((point) => point.latitude != 0 || point.longitude != 0)
        .toList();
    final center = coordinates.isEmpty
        ? const LatLng(-29.1667, -51.1794)
        : coordinates.first;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: coordinates.length > 1 ? 14 : 12,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'frontend_flutter',
              ),
              if (coordinates.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: coordinates,
                      strokeWidth: 4,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (var index = 0; index < coordinates.length; index++)
                    Marker(
                      point: coordinates[index],
                      width: 42,
                      height: 42,
                      child: Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.error,
                        size: 36,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (coordinates.isEmpty)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
                child: const Center(
                  child: Text('Nenhum ponto para exibir no mapa.'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
