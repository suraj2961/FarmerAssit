class NewsVideo {
  final String videoId;
  final String title;
  final String description;
  final String channelTitle;
  final String thumbnailUrl;
  final String publishedAt;
  final String videoUrl;
  final String tag;
  final String tagKannada;

  NewsVideo({
    required this.videoId,
    required this.title,
    required this.description,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.videoUrl,
    this.tag = 'General Farming',
    this.tagKannada = 'ಕೃಷಿ ಮಾಹಿತಿ',
  });

  factory NewsVideo.fromJson(Map<String, dynamic> json) {
    final title = json['title'] ?? '';
    final desc = json['description'] ?? '';
    final inferred = _inferTag(title, desc);

    return NewsVideo(
      videoId: json['videoId'] ?? '',
      title: title,
      description: desc,
      channelTitle: json['channelTitle'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      tag: json['tag'] ?? inferred['en']!,
      tagKannada: json['tagKannada'] ?? inferred['kn']!,
    );
  }

  static Map<String, String> _inferTag(String title, String desc) {
    final combined = '$title $desc'.toLowerCase();
    if (combined.contains('areca') || combined.contains('ಅಡಿಕೆ') || combined.contains('pepper') || combined.contains('ಮೆಣಸು') || combined.contains('coconut') || combined.contains('ತೆಂಗು')) {
      return {'en': 'Plantation Crops', 'kn': 'ಅಡಿಕೆ & ತೋಟಗಾರಿಕೆ'};
    }
    if (combined.contains('market') || combined.contains('price') || combined.contains('mandi') || combined.contains('ದರ') || combined.contains('ಬೆಲೆ') || combined.contains('trend')) {
      return {'en': 'Market Trends', 'kn': 'ಮಾರುಕಟ್ಟೆ ದರ'};
    }
    if (combined.contains('scheme') || combined.contains('subsidy') || combined.contains('bhagya') || combined.contains('ಯೋಜನೆ') || combined.contains('ಸಹಾಯಧನ') || combined.contains('kisan')) {
      return {'en': 'Govt Schemes', 'kn': 'ಸರ್ಕಾರಿ ಯೋಜನೆ'};
    }
    if (combined.contains('drip') || combined.contains('organic') || combined.contains('ಸಾವಯವ') || combined.contains('ಹನಿ ನೀರಾವರಿ')) {
      return {'en': 'Organic & Drip', 'kn': 'ಸಾವಯವ & ನೀರಾವರಿ'};
    }
    if (combined.contains('machine') || combined.contains('tractor') || combined.contains('chc') || combined.contains('yantra') || combined.contains('ಯಂತ್ರ') || combined.contains('tech')) {
      return {'en': 'Machinery & Tech', 'kn': 'ಯಂತ್ರೋಪಕರಣ & ತಂತ್ರಜ್ಞಾನ'};
    }
    if (combined.contains('disease') || combined.contains('pest') || combined.contains('ರೋಗ') || combined.contains('ಕೀಟ') || combined.contains('kole')) {
      return {'en': 'Pest & Disease', 'kn': 'ರೋಗ ನಿಯಂತ್ರಣ'};
    }
    return {'en': 'Farming Guide', 'kn': 'ಕೃಷಿ ಮಾರ್ಗದರ್ಶಿ'};
  }
}
