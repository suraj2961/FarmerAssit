import '../models/mandi_price.dart';
import 'api_client.dart';

class MandiPriceService {
  final ApiClient _apiClient;

  MandiPriceService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<MandiPrice>> fetchMandiPrices({
    String? state,
    String? district,
    String? commodity,
    int limit = 100,
    int offset = 0,
  }) async {
    final data = await _apiClient.get('/api/mandi-prices', queryParams: {
      'state': state,
      'district': district,
      'commodity': commodity,
      'limit': limit.toString(),
      'offset': offset.toString(),
    });

    if (data == null || data is! List) return [];
    return data.map((json) => MandiPrice.fromJson(json as Map<String, dynamic>)).toList();
  }

  void dispose() => _apiClient.dispose();
}