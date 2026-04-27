import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/place.dart';
import '../models/route.dart';
import '../services/route_service.dart';
import '../widgets/route_map.dart';

class CaptureRouteScreen extends StatefulWidget {
  const CaptureRouteScreen({required this.routeService, super.key});

  final RouteService routeService;

  @override
  State<CaptureRouteScreen> createState() => _CaptureRouteScreenState();
}

class _CaptureRouteScreenState extends State<CaptureRouteScreen> {
  final _routeNameController = TextEditingController();

  TripRoute? _currentRoute;
  final List<Place> _capturedPlaces = [];
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _routeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Capturar rota',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (_currentRoute == null) ...[
                  TextField(
                    controller: _routeNameController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Nome da rota',
                      prefixIcon: Icon(Icons.route),
                    ),
                    onSubmitted: (_) => _createRoute(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _createRoute,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar rota'),
                  ),
                ] else ...[
                  Text('Rota: ${_currentRoute!.name}'),
                  Text('Status: ${_currentRoute!.status.label}'),
                  Text('Pontos capturados: ${_capturedPlaces.length}'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _canCapturePoint ? _capturePoint : null,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Capturar ponto atual'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _canPublishRoute ? _publishRoute : null,
                    icon: const Icon(Icons.publish),
                    label: const Text('Publicar rota'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _canFinalizeRoute ? _finalizeRoute : null,
                    icon: const Icon(Icons.flag),
                    label: const Text('Finalizar rota'),
                  ),
                ],
                if (_isSubmitting) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (_successMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _successMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(height: 360, child: RouteMap(points: _capturedPlaces)),
      ],
    );
  }

  bool get _canCapturePoint {
    return !_isSubmitting && _currentRoute?.status == RouteStatus.draft;
  }

  bool get _canPublishRoute {
    return !_isSubmitting &&
        _currentRoute?.status == RouteStatus.draft &&
        _capturedPlaces.length >= 2;
  }

  bool get _canFinalizeRoute {
    return !_isSubmitting && _currentRoute?.status == RouteStatus.published;
  }

  Future<void> _createRoute() async {
    final routeName = _routeNameController.text.trim();

    if (routeName.isEmpty) {
      setState(() {
        _errorMessage = 'Informe um nome para iniciar a rota.';
        _successMessage = null;
      });
      return;
    }

    await _submit(() async {
      final route = await widget.routeService.createRoute(routeName);
      setState(() {
        _currentRoute = route;
        _capturedPlaces.clear();
        _routeNameController.clear();
        _successMessage = 'Rota criada. Capture pelo menos 2 pontos.';
      });
    });
  }

  Future<void> _capturePoint() async {
    final route = _currentRoute;
    if (route == null) {
      return;
    }

    await _submit(() async {
      final position = await _getCurrentPosition();
      final sequence = _capturedPlaces.length + 1;
      final place = await widget.routeService.createPlace(
        CreatePlaceRequest(
          name: 'Ponto $sequence',
          routeId: route.id,
          latitude: position.latitude,
          longitude: position.longitude,
          sequence: sequence,
          capturedAt: DateTime.now(),
        ),
      );

      setState(() {
        _capturedPlaces.add(place);
        _successMessage = 'Ponto $sequence registrado.';
      });
    });
  }

  Future<void> _publishRoute() async {
    final route = _currentRoute;
    if (route == null) {
      return;
    }

    await _submit(() async {
      final publishedRoute = await widget.routeService.publishRoute(route.id);
      setState(() {
        _currentRoute = publishedRoute;
        _successMessage = 'Rota publicada.';
      });
    });
  }

  Future<void> _finalizeRoute() async {
    final route = _currentRoute;
    if (route == null) {
      return;
    }

    await _submit(() async {
      final finalizedRoute = await widget.routeService.finalizeRoute(route.id);
      setState(() {
        _currentRoute = finalizedRoute;
        _successMessage = 'Rota finalizada.';
      });
    });
  }

  Future<Position> _getCurrentPosition() async {
    final locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      throw Exception('Servico de localizacao desabilitado.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Permissao de localizacao negada.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissao de localizacao bloqueada nas configuracoes.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> _submit(Future<void> Function() action) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await action();
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
