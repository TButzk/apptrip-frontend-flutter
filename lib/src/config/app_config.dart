import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  final String apiBaseUrl;

  static const String _apiBaseUrlFromDefine = String.fromEnvironment(
    'API_BASE_URL',
  );

  factory AppConfig.fromEnvironment() {
    final configuredUrl = _apiBaseUrlFromDefine.trim();

    if (configuredUrl.isNotEmpty) {
      return AppConfig(apiBaseUrl: normalizeBaseUrl(configuredUrl));
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return const AppConfig(apiBaseUrl: 'http://10.0.2.2:5010/api/v1');
    }

    return const AppConfig(apiBaseUrl: 'http://localhost:5010/api/v1');
  }

  static String normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
