import 'package:flutter/material.dart';

const Map<String, List<String>> _categoryKeywords = {
  'Vegetable': [
    'tomato', 'onion', 'potato', 'cabbage', 'cauliflower', 'brinjal', 'beans',
    'carrot', 'beetroot', 'cucum', 'bhindi', 'ladies finger', 'chilli',
    'capsicum', 'peas', 'garlic', 'pumpkin', 'gourd', 'radish',
  ],
  'Fruit': [
    'banana', 'mango', 'grape', 'papaya', 'watermelon', 'orange', 'apple',
    'pomegranate', 'guava', 'sapota', 'lemon', 'melon',
  ],
  'Grain': ['rice', 'ragi', 'maize', 'wheat', 'jowar', 'bajra', 'paddy', 'corn'],
  'Oilseed': ['groundnut', 'soyabean', 'soybean', 'sunflower', 'sesame', 'til'],
  'Spice': ['turmeric', 'pepper', 'cardamom', 'clove', 'coriander', 'ginger'],
  'Plantation': ['areca', 'coconut', 'coffee', 'cotton', 'sugarcane', 'cashew', 'tea', 'rubber'],
  'Pulses': ['gram', 'dal', 'tur', 'moong', 'urad', 'lentil', 'toor'],
};

const List<String> cropCategories = [
  'All', 'Plantation', 'Vegetable', 'Fruit', 'Grain', 'Oilseed', 'Spice', 'Pulses', 'Other',
];

const Map<String, String> categoryKannada = {
  'All': 'ಎಲ್ಲವೂ',
  'Plantation': 'ತೋಟದ ಬೆಳೆ',
  'Vegetable': 'ತರಕಾರಿ',
  'Fruit': 'ಹಣ್ಣುಗಳು',
  'Grain': 'ಧಾನ್ಯಗಳು',
  'Oilseed': 'ಎಣ್ಣೆಕಾಳು',
  'Spice': 'ಮಸಾಲೆ',
  'Pulses': 'ದ್ವಿದಳ ಧಾನ್ಯ',
  'Other': 'ಇತರೆ',
};

const Map<String, String> commodityKannadaNames = {
  'areca nut': 'ಅಡಿಕೆ (ಸುಪಾರಿ)',
  'arecanut': 'ಅಡಿಕೆ',
  'tomato': 'ಟೊಮೇಟೊ',
  'onion': 'ಈರುಳ್ಳಿ',
  'coconut': 'ತೆಂಗಿನಕಾಯಿ',
  'copra': 'ಕೊಬ್ಬರಿ',
  'maize': 'ಮೆಕ್ಕೆಜೋಳ',
  'paddy': 'ಭತ್ತ',
  'rice': 'ಅಕ್ಕಿ',
  'ragi': 'ರಾಗಿ',
  'coffee': 'ಕಾಫಿ ಬೀಜ',
  'ginger': 'ಶುಂಠಿ',
  'banana': 'ಬಾಳೆಹಣ್ಣು',
  'turmeric': 'ಅರಿಶಿನ',
  'black pepper': 'ಕರಿಮೆಣಸು',
  'pepper': 'ಮೆಣಸು',
  'cardamom': 'ಏಲಕ್ಕಿ',
  'cotton': 'ಹತ್ತಿ',
  'sugarcane': 'ಕಬ್ಬು',
  'chilli': 'ಮೆಣಸಿನಕಾಯಿ',
  'garlic': 'ಬೆಳ್ಳುಳ್ಳಿ',
  'potato': 'ಆಲೂಗಡ್ಡೆ',
  'wheat': 'ಗೋಧಿ',
  'jowar': 'ಜೋಳ',
  'groundnut': 'ಕಡಲೆಕಾಯಿ',
  'tur': 'ತೊಗರಿ ಬೇಳೆ',
  'moong': 'ಹೆಸರು ಕಾಳು',
  'mango': 'ಮಾವಿನ ಹಣ್ಣು',
};

String kannadaNameFor(String commodity) {
  final lower = commodity.toLowerCase().trim();
  for (final entry in commodityKannadaNames.entries) {
    if (lower.contains(entry.key)) {
      return entry.value;
    }
  }
  return '';
}

String categoryFor(String commodity) {
  final lower = commodity.toLowerCase();
  for (final entry in _categoryKeywords.entries) {
    if (entry.value.any((keyword) => lower.contains(keyword))) {
      return entry.key;
    }
  }
  return 'Other';
}

IconData iconFor(String category) {
  switch (category) {
    case 'Plantation':
      return Icons.park;
    case 'Vegetable':
      return Icons.eco;
    case 'Fruit':
      return Icons.local_florist;
    case 'Grain':
      return Icons.grass;
    case 'Oilseed':
      return Icons.opacity;
    case 'Spice':
      return Icons.local_fire_department;
    case 'Pulses':
      return Icons.scatter_plot;
    default:
      return Icons.category;
  }
}

Color colorFor(String category) {
  switch (category) {
    case 'Plantation':
      return const Color(0xFF1B4332);
    case 'Vegetable':
      return const Color(0xFF16A34A);
    case 'Fruit':
      return const Color(0xFFEA580C);
    case 'Grain':
      return const Color(0xFFD97706);
    case 'Oilseed':
      return const Color(0xFF0D9488);
    case 'Spice':
      return const Color(0xFFDC2626);
    case 'Pulses':
      return const Color(0xFF854D0E);
    default:
      return const Color(0xFF4B5563);
  }
}