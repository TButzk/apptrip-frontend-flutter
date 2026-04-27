import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/route_service.dart';
import 'state/app_controller.dart';

class AppTripFlutterApp extends StatefulWidget {
  const AppTripFlutterApp({super.key});

  @override
  State<AppTripFlutterApp> createState() => _AppTripFlutterAppState();
}

class _AppTripFlutterAppState extends State<AppTripFlutterApp> {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final RouteService _routeService;
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(AppConfig.fromEnvironment());
    _authService = AuthService(_apiClient);
    _routeService = RouteService(_apiClient);
    _controller = AppController(
      apiClient: _apiClient,
      authService: _authService,
    )..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'AppTrip',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F766E),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF7FAFC),
            useMaterial3: true,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ),
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    if (_controller.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_controller.isAuthenticated) {
      return AuthScreen(controller: _controller);
    }

    return HomeScreen(controller: _controller, routeService: _routeService);
  }
}
