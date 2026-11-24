import '../models/scheme.dart';
import 'api_client.dart';

class SchemeService {
  final ApiClient _apiClient;

  SchemeService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Scheme>> fetchSchemes({String? category, String? level}) async {
    final data = await _apiClient.get('/api/schemes', queryParams: {
      'category': category,
      'level': level,
    });
    if (data == null || data is! List) return [];
    return data.map((json) => Scheme.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Scheme?> fetchSchemeById(String id) async {
    try {
      final data = await _apiClient.get('/api/schemes/$id');
      if (data == null) return null;
      return Scheme.fromJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  void dispose() => _apiClient.dispose();
}