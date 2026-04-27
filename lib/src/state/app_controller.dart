import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    required ApiClient apiClient,
    required AuthService authService,
  }) : _apiClient = apiClient,
       _authService = authService;

  static const String _tokenStorageKey = 'apptrip_token';

  final ApiClient _apiClient;
  final AuthService _authService;

  bool _isInitializing = true;
  bool _isSubmitting = false;
  String? _token;
  String? _userName;
  String? _userEmail;

  bool get isInitializing => _isInitializing;
  bool get isSubmitting => _isSubmitting;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    _token = preferences.getString(_tokenStorageKey);
    _apiClient.setToken(_token);
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _setSubmitting(true);
    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      await _persistSession(
        token: response.token,
        userName: response.name,
        userEmail: response.email,
      );
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setSubmitting(true);
    try {
      await _authService.register(name: name, email: email, password: password);
      final response = await _authService.login(
        email: email,
        password: password,
      );
      await _persistSession(
        token: response.token,
        userName: response.name,
        userEmail: response.email,
      );
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenStorageKey);
    _token = null;
    _userName = null;
    _userEmail = null;
    _apiClient.setToken(null);
    notifyListeners();
  }

  Future<void> _persistSession({
    required String token,
    required String userName,
    required String userEmail,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenStorageKey, token);
    _token = token;
    _userName = userName;
    _userEmail = userEmail;
    _apiClient.setToken(token);
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }
}
