class PricePoint {
  final String date;
  final double modalPrice;

  PricePoint({required this.date, required this.modalPrice});

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      date: json['date'] ?? '',
      modalPrice: (json['modalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'modalPrice': modalPrice,
  };
}

class ForecastPoint {
  final String date;
  final double expectedPrice;
  final double lowerBound;
  final double upperBound;

  ForecastPoint({
    required this.date,
    required this.expectedPrice,
    required this.lowerBound,
    required this.upperBound,
  });

  factory ForecastPoint.fromJson(Map<String, dynamic> json) {
    return ForecastPoint(
      date: json['date'] ?? '',
      expectedPrice: (json['expectedPrice'] as num?)?.toDouble() ?? 0.0,
      lowerBound: (json['lowerBound'] as num?)?.toDouble() ?? 0.0,
      upperBound: (json['upperBound'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MarketSignal {
  final String type;
  final String title;
  final String description;
  final bool isPositive;

  MarketSignal({
    required this.type,
    required this.title,
    required this.description,
    required this.isPositive,
  });

  factory MarketSignal.fromJson(Map<String, dynamic> json) {
    return MarketSignal(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isPositive: json['isPositive'] as bool? ?? true,
    );
  }
}

class MandiComparison {
  final String market;
  final String district;
  final double price;
  final double difference;

  MandiComparison({
    required this.market,
    required this.district,
    required this.price,
    required this.difference,
  });

  factory MandiComparison.fromJson(Map<String, dynamic> json) {
    return MandiComparison(
      market: json['market'] ?? '',
      district: json['district'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      difference: (json['difference'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SellAdvisory {
  final String commodity;
  final String? market;
  final String district;
  final String state;
  final double currentPrice;
  final double earliestPrice;
  final double changeAmount;
  final double changePercent;
  final String trend;
  final String recommendation;
  final String recommendationKannada;
  final String actionVerdict;
  final int confidenceScore;
  final String perishabilityGrade;
  final double predictedPrice7Days;
  final double predictedPrice14Days;
  final double expectedNetHoldingBenefit;
  final double volatilityPercent;
  final int historicalPercentile;
  final List<PricePoint> priceHistory;
  final List<ForecastPoint> forecastHistory;
  final List<MarketSignal> keySignals;
  final List<MandiComparison> nearbyMandis;

  SellAdvisory({
    required this.commodity,
    this.market,
    this.district = '',
    this.state = 'Karnataka',
    required this.currentPrice,
    required this.earliestPrice,
    required this.changeAmount,
    required this.changePercent,
    required this.trend,
    required this.recommendation,
    this.recommendationKannada = '',
    this.actionVerdict = 'MONITOR',
    this.confidenceScore = 75,
    this.perishabilityGrade = 'SEMI_PERISHABLE',
    this.predictedPrice7Days = 0.0,
    this.predictedPrice14Days = 0.0,
    this.expectedNetHoldingBenefit = 0.0,
    this.volatilityPercent = 4.0,
    this.historicalPercentile = 50,
    required this.priceHistory,
    this.forecastHistory = const [],
    this.keySignals = const [],
    this.nearbyMandis = const [],
  });

  factory SellAdvisory.fromJson(Map<String, dynamic> json) {
    return SellAdvisory(
      commodity: json['commodity'] ?? '',
      market: json['market'],
      district: json['district'] ?? '',
      state: json['state'] ?? 'Karnataka',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      earliestPrice: (json['earliestPrice'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (json['changeAmount'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
      trend: json['trend'] ?? 'NO_DATA',
      recommendation: json['recommendation'] ?? '',
      recommendationKannada: json['recommendationKannada'] ?? '',
      actionVerdict: json['actionVerdict'] ?? 'MONITOR',
      confidenceScore: (json['confidenceScore'] as num?)?.toInt() ?? 75,
      perishabilityGrade: json['perishabilityGrade'] ?? 'SEMI_PERISHABLE',
      predictedPrice7Days: (json['predictedPrice7Days'] as num?)?.toDouble() ??
          (json['currentPrice'] as num?)?.toDouble() ??
          0.0,
      predictedPrice14Days:
          (json['predictedPrice14Days'] as num?)?.toDouble() ??
          (json['currentPrice'] as num?)?.toDouble() ??
          0.0,
      expectedNetHoldingBenefit:
          (json['expectedNetHoldingBenefit'] as num?)?.toDouble() ?? 0.0,
      volatilityPercent:
          (json['volatilityPercent'] as num?)?.toDouble() ?? 4.0,
      historicalPercentile:
          (json['historicalPercentile'] as num?)?.toInt() ?? 50,
      priceHistory: (json['priceHistory'] as List?)
              ?.map((e) => PricePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      forecastHistory: (json['forecastHistory'] as List?)
              ?.map((e) => ForecastPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      keySignals: (json['keySignals'] as List?)
              ?.map((e) => MarketSignal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nearbyMandis: (json['nearbyMandis'] as List?)
              ?.map((e) => MandiComparison.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isHoldRecommended =>
      actionVerdict == 'HOLD_AND_WAIT';

  bool get isSellRecommended =>
      actionVerdict == 'STRONG_SELL' ||
      actionVerdict == 'SELL_NOW' ||
      actionVerdict == 'SELL_IMMEDIATELY';

  String get verdictBadgeTextEn {
    switch (actionVerdict) {
      case 'STRONG_SELL':
        return 'STRONG SELL (Peak Rate)';
      case 'HOLD_AND_WAIT':
        return 'HOLD & WAIT (Price Rising)';
      case 'SELL_IMMEDIATELY':
        return 'SELL IMMEDIATELY (Downside Risk)';
      case 'SELL_NOW':
        return 'SELL NOW (Downward Trend)';
      default:
        return 'MONITOR MARKET (Stable)';
    }
  }

  String get verdictBadgeTextKn {
    switch (actionVerdict) {
      case 'STRONG_SELL':
        return 'ಈಗಲೇ ಮಾರಿ (ಗರಿಷ್ಠ ದರ)';
      case 'HOLD_AND_WAIT':
        return 'ಕಾಯಿರಿ (ದರ ಏರಿಕೆ ಮುನ್ಸೂಚನೆ)';
      case 'SELL_IMMEDIATELY':
        return 'ತಕ್ಷಣವೇ ಮಾರಿ (ಕುಸಿತದ ಅಪಾಯ)';
      case 'SELL_NOW':
        return 'ಮಾರಾಟ ಸೂಕ್ತ (ಇಳಿಕೆಯ ಹಾದಿ)';
      default:
        return 'ಗಮನಿಸಿ (ದರ ಸ್ಥಿರ)';
    }
  }
}