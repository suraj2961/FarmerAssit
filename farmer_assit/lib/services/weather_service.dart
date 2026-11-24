import '../models/weather_info.dart';
import 'api_client.dart';

class WeatherService {
  final ApiClient _apiClient;

  WeatherService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<WeatherInfo> getCurrentWeather({required double lat, required double lon}) async {
    final data = await _apiClient.get('/api/weather', queryParams: {
      'lat': lat.toString(),
      'lon': lon.toString(),
    });
    return WeatherInfo.fromJson(data as Map<String, dynamic>);
  }

  Future<WeatherInfo> getCurrentWeatherByCity(String city) async {
    final data = await _apiClient.get('/api/weather', queryParams: {'city': city});
    return WeatherInfo.fromJson(data as Map<String, dynamic>);
  }

  void dispose() => _apiClient.dispose();
}