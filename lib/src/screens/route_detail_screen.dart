import 'package:flutter/material.dart';

import '../models/place.dart';
import '../models/route.dart';
import '../services/route_service.dart';
import '../widgets/route_map.dart';

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({
    required this.routeId,
    required this.routeService,
    super.key,
  });

  final String routeId;
  final RouteService routeService;

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late Future<_RouteDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da rota')),
      body: FutureBuilder<_RouteDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(snapshot.error.toString()),
              ),
            );
          }

          final detail = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.route.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Status: ${detail.route.status.label}'),
                      Text('Autor: ${detail.route.userId}'),
                      Text('Total de pontos: ${detail.places.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(height: 320, child: RouteMap(points: detail.places)),
              const SizedBox(height: 16),
              Text('Pontos', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final place in detail.places)
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${place.sequence ?? '-'}'),
                    ),
                    title: Text(place.name.isEmpty ? 'Sem nome' : place.name),
                    subtitle: Text('${place.latitude}, ${place.longitude}'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<_RouteDetail> _loadDetail() async {
    final results = await Future.wait([
      widget.routeService.getRouteById(widget.routeId),
      widget.routeService.getRoutePlaces(widget.routeId),
    ]);

    final places = List<Place>.from(results[1] as List<Place>)
      ..sort((left, right) {
        final sequenceCompare = (left.sequence ?? 1 << 30).compareTo(
          right.sequence ?? 1 << 30,
        );
        if (sequenceCompare != 0) {
          return sequenceCompare;
        }

        return left.id.compareTo(right.id);
      });

    return _RouteDetail(route: results[0] as TripRoute, places: places);
  }
}

class _RouteDetail {
  const _RouteDetail({required this.route, required this.places});

  final TripRoute route;
  final List<Place> places;
}
