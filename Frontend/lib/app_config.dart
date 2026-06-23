class AppConfig {
  static const String appName = 'Staydesk';
  static const String _defaultApiBaseUrl = 'http://localhost:5225/api';

  static String get apiBaseUrl {
    final configured = const String.fromEnvironment(
      'STAYDESK_API_BASE_URL',
      defaultValue: _defaultApiBaseUrl,
    ).trim();

    if (configured.endsWith('/')) {
      return configured.substring(0, configured.length - 1);
    }

    return configured;
  }
}
