import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}

class ApiClient {
  static const Duration _timeout = Duration(seconds: 3);
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String path, {Map<String, String?>? queryParams}) async {
    final filteredParams = <String, String>{};
    queryParams?.forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        filteredParams[key] = value;
      }
    });

    final uri = Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: filteredParams.isEmpty ? null : filteredParams);

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      }

      String message = 'Server returned status ${response.statusCode}';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}

      throw ApiException(message, statusCode: response.statusCode);
    } on TimeoutException {
      throw ApiException(
          'Request timed out. Check that the backend is running and reachable.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}