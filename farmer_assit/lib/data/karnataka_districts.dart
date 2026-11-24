import '../models/weather_info.dart';

class DistrictInfo {
  final String englishName;
  final String kannadaName;
  final String weatherCity;
  final List<String> primaryApmcs;
  final String majorCrops;
  final WeatherInfo fallbackWeather;

  const DistrictInfo({
    required this.englishName,
    required this.kannadaName,
    required this.weatherCity,
    required this.primaryApmcs,
    required this.majorCrops,
    required this.fallbackWeather,
  });

  String get displayName => '$englishName ($kannadaName)';
}

const List<DistrictInfo> karnatakaDistrictsList = [
  DistrictInfo(
    englishName: 'Dakshina Kannada',
    kannadaName: 'ಮಂಗಳೂರು',
    weatherCity: 'Mangalore,IN',
    primaryApmcs: ['Mangalore', 'Puttur', 'Bantwal', 'Belthangady', 'Sullia'],
    majorCrops: 'Arecanut, Coconut, Black Pepper, Paddy, Rubber',
    fallbackWeather: WeatherInfo(
      locationName: 'Mangalore',
      temperature: 28.5,
      feelsLike: 31.8,
      humidity: 78,
      windSpeed: 3.8,
      condition: 'Clouds',
      description: 'Pleasant coastal breeze with scattered sea clouds',
      icon: '02d',
    ),
  ),
  DistrictInfo(
    englishName: 'Shivamogga',
    kannadaName: 'ಶಿವಮೊಗ್ಗ',
    weatherCity: 'Shivamogga,IN',
    primaryApmcs: ['Shivamogga', 'Sagar', 'Shikaripura', 'Bhadravathi', 'Thirthahalli'],
    majorCrops: 'Arecanut, Paddy, Ginger, Maize, Banana',
    fallbackWeather: WeatherInfo(
      locationName: 'Shivamogga',
      temperature: 26.4,
      feelsLike: 27.5,
      humidity: 82,
      windSpeed: 2.6,
      condition: 'Rain',
      description: 'Light Malnad drizzle, ideal for plantation care',
      icon: '10d',
    ),
  ),
  DistrictInfo(
    englishName: 'Kolar',
    kannadaName: 'ಕೋಲಾರ',
    weatherCity: 'Kolar,IN',
    primaryApmcs: ['Kolar', 'Srinivaspur', 'Mulbagal', 'Bangarapet', 'Malur'],
    majorCrops: 'Tomato, Mango, Groundnut, Ragi, Capsicum',
    fallbackWeather: WeatherInfo(
      locationName: 'Kolar',
      temperature: 29.2,
      feelsLike: 30.1,
      humidity: 52,
      windSpeed: 4.1,
      condition: 'Clear',
      description: 'Bright sunshine, excellent for vegetable harvesting & solar drying',
      icon: '01d',
    ),
  ),
  DistrictInfo(
    englishName: 'Bengaluru',
    kannadaName: 'ಬೆಂಗಳೂರು',
    weatherCity: 'Bengaluru,IN',
    primaryApmcs: ['Bangalore', 'Yeshwanthpur', 'Binny Mill', 'Hosakote'],
    majorCrops: 'Vegetables, Flowers, Grapes, Ragi, Poultry',
    fallbackWeather: WeatherInfo(
      locationName: 'Bengaluru',
      temperature: 25.5,
      feelsLike: 26.2,
      humidity: 62,
      windSpeed: 3.4,
      condition: 'Clouds',
      description: 'Mild temperature with gentle breeze',
      icon: '03d',
    ),
  ),
  DistrictInfo(
    englishName: 'Mysuru',
    kannadaName: 'ಮೈಸೂರು',
    weatherCity: 'Mysore,IN',
    primaryApmcs: ['Mysore', 'Bandipalya', 'Nanjangud', 'T. Narasipura', 'Hunsur'],
    majorCrops: 'Paddy, Ragi, Sugarcane, Cotton, Banana, Tobacco',
    fallbackWeather: WeatherInfo(
      locationName: 'Mysuru',
      temperature: 27.8,
      feelsLike: 28.9,
      humidity: 65,
      windSpeed: 3.1,
      condition: 'Clear',
      description: 'Warm and sunny with comfortable farm field conditions',
      icon: '01d',
    ),
  ),
  DistrictInfo(
    englishName: 'Dharwad',
    kannadaName: 'ಧಾರವಾಡ / ಹುಬ್ಬಳ್ಳಿ',
    weatherCity: 'Hubli,IN',
    primaryApmcs: ['Hubli', 'Dharwad', 'Amargol', 'Kundgol', 'Kalghatgi'],
    majorCrops: 'Onion, Cotton, Soybean, Chilli, Groundnut',
    fallbackWeather: WeatherInfo(
      locationName: 'Hubballi-Dharwad',
      temperature: 29.8,
      feelsLike: 31.2,
      humidity: 54,
      windSpeed: 3.9,
      condition: 'Clear',
      description: 'Sunny and dry, suitable for grain threshing and mandi transport',
      icon: '01d',
    ),
  ),
  DistrictInfo(
    englishName: 'Davanagere',
    kannadaName: 'ದಾವಣಗೆರೆ',
    weatherCity: 'Davanagere,IN',
    primaryApmcs: ['Davanagere', 'Harihar', 'Channagiri', 'Honnali', 'Jagalur'],
    majorCrops: 'Maize, Arecanut, Paddy, Sugarcane, Cotton',
    fallbackWeather: WeatherInfo(
      locationName: 'Davanagere',
      temperature: 28.9,
      feelsLike: 30.0,
      humidity: 58,
      windSpeed: 3.5,
      condition: 'Clouds',
      description: 'Partly sunny, favorable for spraying and weeding',
      icon: '02d',
    ),
  ),
  DistrictInfo(
    englishName: 'Udupi',
    kannadaName: 'ಉಡುಪಿ',
    weatherCity: 'Udupi,IN',
    primaryApmcs: ['Udupi', 'Kundapur', 'Karkala', 'Brahmavar'],
    majorCrops: 'Paddy, Arecanut, Coconut, Cashew, Pepper',
    fallbackWeather: WeatherInfo(
      locationName: 'Udupi',
      temperature: 28.4,
      feelsLike: 32.0,
      humidity: 80,
      windSpeed: 4.0,
      condition: 'Clouds',
      description: 'Warm coastal weather with scattered showers',
      icon: '10d',
    ),
  ),
  DistrictInfo(
    englishName: 'Hassan',
    kannadaName: 'ಹಾಸನ',
    weatherCity: 'Hassan,IN',
    primaryApmcs: ['Hassan', 'Arsikere', 'Channarayapatna', 'Sakleshpur', 'Belur'],
    majorCrops: 'Potato, Coffee, Coconut, Cardamom, Ginger',
    fallbackWeather: WeatherInfo(
      locationName: 'Hassan',
      temperature: 24.8,
      feelsLike: 25.5,
      humidity: 72,
      windSpeed: 3.0,
      condition: 'Clouds',
      description: 'Cool coffee-tract climate, overcast skies',
      icon: '03d',
    ),
  ),
  DistrictInfo(
    englishName: 'Belagavi',
    kannadaName: 'ಬೆಳಗಾವಿ',
    weatherCity: 'Belagavi,IN',
    primaryApmcs: ['Belgaum', 'Bailhongal', 'Gokak', 'Athani', 'Chikkodi'],
    majorCrops: 'Sugarcane, Soybean, Maize, Cotton, Vegetables',
    fallbackWeather: WeatherInfo(
      locationName: 'Belagavi',
      temperature: 26.5,
      feelsLike: 27.3,
      humidity: 68,
      windSpeed: 3.3,
      condition: 'Clouds',
      description: 'Pleasant weather across northern plains',
      icon: '02d',
    ),
  ),
  DistrictInfo(
    englishName: 'Tumakuru',
    kannadaName: 'ತುಮಕೂರು',
    weatherCity: 'Tumkur,IN',
    primaryApmcs: ['Tumkur', 'Tiptur', 'Madhugiri', 'Sira', 'Kunigal'],
    majorCrops: 'Coconut (Copra), Arecanut, Ragi, Groundnut',
    fallbackWeather: WeatherInfo(
      locationName: 'Tumakuru',
      temperature: 28.7,
      feelsLike: 29.8,
      humidity: 56,
      windSpeed: 3.6,
      condition: 'Clear',
      description: 'Dry sunshine, perfect for copra drying in Tiptur tract',
      icon: '01d',
    ),
  ),
  DistrictInfo(
    englishName: 'Chikkamagaluru',
    kannadaName: 'ಚಿಕ್ಕಮಗಳೂರು',
    weatherCity: 'Chikmagalur,IN',
    primaryApmcs: ['Chikmagalur', 'Tarikere', 'Kadur', 'Mudigere', 'Koppa'],
    majorCrops: 'Coffee, Pepper, Arecanut, Cardamom, Tea',
    fallbackWeather: WeatherInfo(
      locationName: 'Chikkamagaluru',
      temperature: 23.5,
      feelsLike: 24.2,
      humidity: 79,
      windSpeed: 2.8,
      condition: 'Clouds',
      description: 'Cool mountain mist with intermittent sun',
      icon: '03d',
    ),
  ),
  DistrictInfo(
    englishName: 'Uttara Kannada',
    kannadaName: 'ಶಿರಸಿ',
    weatherCity: 'Sirsi,IN',
    primaryApmcs: ['Sirsi', 'Kumta', 'Karwar', 'Yellapur', 'Siddapur'],
    majorCrops: 'Arecanut, Spices, Vanilla, Paddy, Cashew',
    fallbackWeather: WeatherInfo(
      locationName: 'Uttara Kannada (Sirsi)',
      temperature: 25.2,
      feelsLike: 26.5,
      humidity: 84,
      windSpeed: 2.9,
      condition: 'Rain',
      description: 'Western Ghats humidity with passing showers',
      icon: '10d',
    ),
  ),
  DistrictInfo(
    englishName: 'Haveri',
    kannadaName: 'ಹಾವೇರಿ',
    weatherCity: 'Haveri,IN',
    primaryApmcs: ['Byadgi', 'Ranebennur', 'Haveri', 'Hirekerur'],
    majorCrops: 'Byadgi Red Chilli, Maize, Cotton, Groundnut',
    fallbackWeather: WeatherInfo(
      locationName: 'Haveri',
      temperature: 29.4,
      feelsLike: 31.0,
      humidity: 55,
      windSpeed: 3.7,
      condition: 'Clear',
      description: 'Warm and dry, ideal for Byadgi chilli sorting & drying',
      icon: '01d',
    ),
  ),
  DistrictInfo(
    englishName: 'Mandya',
    kannadaName: 'ಮಂಡ್ಯ',
    weatherCity: 'Mandya,IN',
    primaryApmcs: ['Mandya', 'Maddur', 'Malavalli', 'Pandavapura'],
    majorCrops: 'Sugarcane, Paddy, Banana, Ragi, Silk (Cocoon)',
    fallbackWeather: WeatherInfo(
      locationName: 'Mandya',
      temperature: 27.5,
      feelsLike: 28.8,
      humidity: 64,
      windSpeed: 3.2,
      condition: 'Clear',
      description: 'Sunny canal irrigated tract, good field moisture',
      icon: '01d',
    ),
  ),
  DistrictInfo(
    englishName: 'Ballari',
    kannadaName: 'ಬಳ್ಳಾರಿ',
    weatherCity: 'Bellary,IN',
    primaryApmcs: ['Bellary', 'Hospet', 'Siruguppa', 'Kudligi'],
    majorCrops: 'Paddy, Cotton, Chilli, Sunflower, Jowar',
    fallbackWeather: WeatherInfo(
      locationName: 'Ballari',
      temperature: 31.5,
      feelsLike: 33.8,
      humidity: 48,
      windSpeed: 4.2,
      condition: 'Clear',
      description: 'Hot and dry sunshine across Tungabhadra basin',
      icon: '01d',
    ),
  ),
];

String cleanDistrictName(String rawDistrict) {
  if (rawDistrict.isEmpty) return 'Dakshina Kannada';
  final cleaned = rawDistrict.split(' (').first.trim();
  return cleaned;
}

DistrictInfo getDistrictInfo(String district) {
  final clean = cleanDistrictName(district).toLowerCase();
  for (final info in karnatakaDistrictsList) {
    if (info.englishName.toLowerCase() == clean ||
        clean.contains(info.englishName.toLowerCase()) ||
        info.englishName.toLowerCase().contains(clean)) {
      return info;
    }
  }
  return karnatakaDistrictsList.first;
}

String districtToWeatherCity(String district) {
  return getDistrictInfo(district).weatherCity;
}

WeatherInfo getDistrictFallbackWeather(String district) {
  return getDistrictInfo(district).fallbackWeather;
}
