import 'package:flutter/material.dart';
import 'crop_categories.dart';

class CropImageHelper {
  static const Map<String, String> _cropImages = {
    'areca nut': 'https://images.unsplash.com/photo-1627920769842-6887c6df05ca?w=400&auto=format&fit=crop&q=80',
    'arecanut': 'https://images.unsplash.com/photo-1627920769842-6887c6df05ca?w=400&auto=format&fit=crop&q=80',
    'adike': 'https://images.unsplash.com/photo-1627920769842-6887c6df05ca?w=400&auto=format&fit=crop&q=80',
    'tomato': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&auto=format&fit=crop&q=80',
    'onion': 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400&auto=format&fit=crop&q=80',
    'potato': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&auto=format&fit=crop&q=80',
    'coconut': 'https://images.unsplash.com/photo-1544378730-8b5104b18790?w=400&auto=format&fit=crop&q=80',
    'copra': 'https://images.unsplash.com/photo-1544378730-8b5104b18790?w=400&auto=format&fit=crop&q=80',
    'maize': 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400&auto=format&fit=crop&q=80',
    'corn': 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400&auto=format&fit=crop&q=80',
    'paddy': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&auto=format&fit=crop&q=80',
    'rice': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&auto=format&fit=crop&q=80',
    'ragi': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&auto=format&fit=crop&q=80',
    'coffee': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400&auto=format&fit=crop&q=80',
    'ginger': 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=400&auto=format&fit=crop&q=80',
    'banana': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&auto=format&fit=crop&q=80',
    'chilli': 'https://images.unsplash.com/photo-1568584711271-6c929fb49b60?w=400&auto=format&fit=crop&q=80',
    'pepper': 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&auto=format&fit=crop&q=80',
    'black pepper': 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&auto=format&fit=crop&q=80',
    'cardamom': 'https://images.unsplash.com/photo-1599940824399-b87987ceb72a?w=400&auto=format&fit=crop&q=80',
    'turmeric': 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=400&auto=format&fit=crop&q=80',
    'garlic': 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=400&auto=format&fit=crop&q=80',
    'cotton': 'https://images.unsplash.com/photo-1606041008023-472dfb5e530f?w=400&auto=format&fit=crop&q=80',
    'sugarcane': 'https://images.unsplash.com/photo-1596704017254-9b121068fb31?w=400&auto=format&fit=crop&q=80',
    'mango': 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400&auto=format&fit=crop&q=80',
    'pomegranate': 'https://images.unsplash.com/photo-1541344999736-83eca872f242?w=400&auto=format&fit=crop&q=80',
    'papaya': 'https://images.unsplash.com/photo-1517282009859-f000ec3b26fe?w=400&auto=format&fit=crop&q=80',
    'lemon': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=400&auto=format&fit=crop&q=80',
    'watermelon': 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400&auto=format&fit=crop&q=80',
    'grape': 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=400&auto=format&fit=crop&q=80',
    'guava': 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=400&auto=format&fit=crop&q=80',
    'orange': 'https://images.unsplash.com/photo-1547514701-42782101795e?w=400&auto=format&fit=crop&q=80',
    'groundnut': 'https://images.unsplash.com/photo-1567892329381-817ea2d46e2a?w=400&auto=format&fit=crop&q=80',
    'wheat': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&auto=format&fit=crop&q=80',
    'cabbage': 'https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?w=400&auto=format&fit=crop&q=80',
    'carrot': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&auto=format&fit=crop&q=80',
    'cashew': 'https://images.unsplash.com/photo-1509912760195-56a9e8a7f29a?w=400&auto=format&fit=crop&q=80',
    'rubber': 'https://images.unsplash.com/photo-1544378730-8b5104b18790?w=400&auto=format&fit=crop&q=80',
    'sunflower': 'https://images.unsplash.com/photo-1597848212624-a19eb35e2651?w=400&auto=format&fit=crop&q=80',
    'ladies finger': 'https://images.unsplash.com/photo-1425543103986-22abb7d7e8d2?w=400&auto=format&fit=crop&q=80',
    'brinjal': 'https://images.unsplash.com/photo-1628773822503-930a84d03e33?w=400&auto=format&fit=crop&q=80',
    'cauliflower': 'https://images.unsplash.com/photo-1568584711075-3d021a7c3ca3?w=400&auto=format&fit=crop&q=80',
  };

  static String getImageUrl(String commodity) {
    final lower = commodity.toLowerCase().trim();
    for (final entry in _cropImages.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    // Default fallback based on category
    final category = categoryFor(commodity);
    switch (category) {
      case 'Vegetable':
        return 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&auto=format&fit=crop&q=80';
      case 'Fruit':
        return 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&auto=format&fit=crop&q=80';
      case 'Plantation':
        return 'https://images.unsplash.com/photo-1544378730-8b5104b18790?w=400&auto=format&fit=crop&q=80';
      case 'Spice':
        return 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&auto=format&fit=crop&q=80';
      default:
        return 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&auto=format&fit=crop&q=80';
    }
  }
}

class CropThumbnail extends StatelessWidget {
  final String commodity;
  final double size;
  final double borderRadius;
  final BoxFit fit;

  const CropThumbnail({
    super.key,
    required this.commodity,
    this.size = 52,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = CropImageHelper.getImageUrl(commodity);
    final category = categoryFor(commodity);
    final themeColor = colorFor(category);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        color: themeColor.withValues(alpha: 0.12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background fallback icon
            Center(
              child: Icon(
                iconFor(category),
                color: themeColor.withValues(alpha: 0.6),
                size: size * 0.45,
              ),
            ),
            // Real photo image
            Image.network(
              imageUrl,
              fit: fit,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: SizedBox(
                    width: size * 0.35,
                    height: size * 0.35,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(themeColor),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(
                  iconFor(category),
                  color: themeColor,
                  size: size * 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
