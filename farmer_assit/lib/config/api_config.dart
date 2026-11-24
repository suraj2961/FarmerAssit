import 'platform_host_io.dart' if (dart.library.html) 'platform_host_web.dart';

class ApiConfig {
  static const int backendPort = 8080;
  static const String defaultCloudUrl = 'https://farmerassit-backend.onrender.com';
  static const String? physicalDeviceHostOverride = null; // e.g. '192.168.1.5'

  /// Allows setting the backend URL at build time using:
  /// `--dart-define=API_BASE_URL=https://api.yourdomain.com`
  /// Defaults to production Render cloud backend.
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: defaultCloudUrl);

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl.endsWith('/') ? _envBaseUrl.substring(0, _envBaseUrl.length - 1) : _envBaseUrl;
    }
    if (physicalDeviceHostOverride != null) {
      return 'http://$physicalDeviceHostOverride:$backendPort';
    }
    return 'http://${resolveBackendHost()}:$backendPort';
  }
}