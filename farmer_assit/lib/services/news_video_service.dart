import '../models/news_video.dart';
import 'api_client.dart';

class NewsVideoService {
  final ApiClient _apiClient;

  NewsVideoService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<NewsVideo>> fetchNews({String? query}) async {
    final data = await _apiClient.get('/api/news', queryParams: {'query': query});
    if (data == null || data is! List) return [];
    return data.map((json) => NewsVideo.fromJson(json as Map<String, dynamic>)).toList();
  }

  void dispose() => _apiClient.dispose();
}