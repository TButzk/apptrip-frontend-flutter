import 'package:flutter/material.dart';

import '../services/route_service.dart';
import '../state/app_controller.dart';
import 'capture_route_screen.dart';
import 'routes_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.controller,
    required this.routeService,
    super.key,
  });

  final AppController controller;
  final RouteService routeService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      RoutesListScreen(
        title: 'Rotas publicadas',
        emptyMessage: 'Nenhuma rota publicada encontrada.',
        loadRoutes: widget.routeService.listPublishedRoutes,
        routeService: widget.routeService,
      ),
      RoutesListScreen(
        title: 'Minhas rotas',
        emptyMessage: 'Voce ainda nao criou rotas.',
        loadRoutes: widget.routeService.listMyRoutes,
        routeService: widget.routeService,
      ),
      CaptureRouteScreen(routeService: widget.routeService),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AppTrip'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: widget.controller.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.public), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.route), label: 'Minhas'),
          NavigationDestination(
            icon: Icon(Icons.add_location_alt),
            label: 'Capturar',
          ),
        ],
      ),
    );
  }
}
