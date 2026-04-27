import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/src/config/app_config.dart';

void main() {
  test('normalizes configured API base URL by removing trailing slash', () {
    final config = AppConfig(
      apiBaseUrl: AppConfig.normalizeBaseUrl('http://localhost:5010/api/v1/'),
    );

    expect(config.apiBaseUrl, 'http://localhost:5010/api/v1');
  });
}
