import 'package:flutter/material.dart';

import '../models/route.dart';
import '../services/route_service.dart';
import 'route_detail_screen.dart';

typedef RouteLoader = Future<List<TripRoute>> Function({int skip, int take});

class RoutesListScreen extends StatefulWidget {
  const RoutesListScreen({
    required this.title,
    required this.emptyMessage,
    required this.loadRoutes,
    required this.routeService,
    super.key,
  });

  final String title;
  final String emptyMessage;
  final RouteLoader loadRoutes;
  final RouteService routeService;

  @override
  State<RoutesListScreen> createState() => _RoutesListScreenState();
}

class _RoutesListScreenState extends State<RoutesListScreen> {
  late Future<List<TripRoute>> _routesFuture;

  @override
  void initState() {
    super.initState();
    _routesFuture = _loadRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _routesFuture = _loadRoutes());
        await _routesFuture;
      },
      child: FutureBuilder<List<TripRoute>>(
        future: _routesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _MessageView(
              icon: Icons.error_outline,
              message: snapshot.error.toString(),
              action: FilledButton.icon(
                onPressed: () {
                  setState(() => _routesFuture = _loadRoutes());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            );
          }

          final routes = snapshot.data ?? const <TripRoute>[];

          if (routes.isEmpty) {
            return _MessageView(
              icon: Icons.route_outlined,
              message: widget.emptyMessage,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final route = routes[index];

              return Card(
                elevation: 0,
                child: ListTile(
                  title: Text(route.name),
                  subtitle: Text(
                    '${route.status.label} - ${route.placeIds.length} ponto(s)',
                  ),
                  leading: const Icon(Icons.route),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RouteDetailScreen(
                          routeId: route.id,
                          routeService: widget.routeService,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemCount: routes.length,
          );
        },
      ),
    );
  }

  Future<List<TripRoute>> _loadRoutes() {
    return widget.loadRoutes(skip: 0, take: 30);
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 48),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (action != null) ...[
          const SizedBox(height: 16),
          Center(child: action),
        ],
      ],
    );
  }
}
