import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/negilu_tokens.dart';
import '../models/sell_advisory.dart';
import '../services/crop_advisory_service.dart';
import '../services/api_client.dart';
import '../widgets/price_trend_chart.dart';
import '../widgets/negilu_footer.dart';
import '../widgets/farmer_drawer.dart';
import '../data/crop_images.dart';

const List<Map<String, String>> _popularKarnatakaCrops = [
  {'en': 'Areca nut', 'kn': 'ಅಡಿಕೆ'},
  {'en': 'Tomato', 'kn': 'ಟೊಮೇಟೊ'},
  {'en': 'Onion', 'kn': 'ಈರುಳ್ಳಿ'},
  {'en': 'Coconut', 'kn': 'ತೆಂಗಿನಕಾಯಿ'},
  {'en': 'Maize', 'kn': 'ಮೆಕ್ಕೆಜೋಳ'},
  {'en': 'Paddy', 'kn': 'ಭತ್ತ'},
  {'en': 'Coffee', 'kn': 'ಕಾಫಿ'},
  {'en': 'Ginger', 'kn': 'ಶುಂಠಿ'},
  {'en': 'Banana', 'kn': 'ಬಾಳೆ'},
  {'en': 'Ragi', 'kn': 'ರಾಗಿ'},
];

class CropAdvisoryScreen extends StatefulWidget {
  final String? initialCommodity;
  final String? selectedDistrict;
  final ValueChanged<String>? onDistrictSelected;
  final ValueChanged<int>? onNavigateToTab;

  const CropAdvisoryScreen({
    super.key,
    this.initialCommodity,
    this.selectedDistrict,
    this.onDistrictSelected,
    this.onNavigateToTab,
  });

  @override
  State<CropAdvisoryScreen> createState() => _CropAdvisoryScreenState();
}

class _CropAdvisoryScreenState extends State<CropAdvisoryScreen> {
  final CropAdvisoryService _service = CropAdvisoryService();
  late final TextEditingController _commodityController;

  final String _state = 'Karnataka';
  SellAdvisory? _advisory;
  bool _loading = false;
  String? _error;

  // Quantity calculator state
  double _farmerQuantity = 20.0; // Quintals
  final TextEditingController _quantityController = TextEditingController(text: '20');

  @override
  void initState() {
    super.initState();
    _commodityController = TextEditingController(
      text: widget.initialCommodity ?? 'Areca nut',
    );
    _fetchAdvisory();
  }

  @override
  void didUpdateWidget(covariant CropAdvisoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.selectedDistrict != null && widget.selectedDistrict != oldWidget.selectedDistrict) ||
        (widget.initialCommodity != null && widget.initialCommodity != oldWidget.initialCommodity)) {
      if (widget.initialCommodity != null) {
        _commodityController.text = widget.initialCommodity!;
      }
      _fetchAdvisory();
    }
  }

  Future<void> _fetchAdvisory({String? overrideCrop}) async {
    final commodity = overrideCrop ?? _commodityController.text.trim();
    if (commodity.isEmpty) {
      setState(() => _error = 'Please enter or select a crop first.');
      return;
    }

    if (overrideCrop != null) {
      _commodityController.text = overrideCrop;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.getSellAdvisory(
        commodity: commodity,
        state: _state,
        district: widget.selectedDistrict,
      );
      if (mounted) {
        setState(() {
          _advisory = result;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load advisory: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _service.dispose();
    _commodityController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Color _verdictColor(String verdict) {
    switch (verdict) {
      case 'STRONG_SELL':
      case 'SELL_IMMEDIATELY':
        return NegiluColors.brandWarmDeep; // #6E2E15 Alert Terracotta Deep
      case 'HOLD_AND_WAIT':
        return NegiluColors.brandGreenDark; // #1C5A2C Growth Green
      case 'SELL_NOW':
        return NegiluColors.brandWarm; // #C2562B Warm Orange
      default:
        return NegiluColors.brandWarmDark; // #9C4220 Amber
    }
  }

  IconData _verdictIcon(String verdict) {
    switch (verdict) {
      case 'STRONG_SELL':
        return Icons.sell;
      case 'SELL_IMMEDIATELY':
        return Icons.warning_amber_rounded;
      case 'HOLD_AND_WAIT':
        return Icons.hourglass_top_rounded;
      case 'SELL_NOW':
        return Icons.arrow_downward;
      default:
        return Icons.remove_red_eye_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: NegiluColors.surface2,
      drawer: isDesktop
          ? null
          : FarmerDrawer(
              selectedIndex: 2,
              onTabSelected: (idx) {
                widget.onNavigateToTab?.call(idx);
              },
              selectedDistrict: widget.selectedDistrict ?? 'Dakshina Kannada',
              onDistrictSelected: (d) {
                widget.onDistrictSelected?.call(d);
                _fetchAdvisory();
              },
            ),
      appBar: (isDesktop && !canPop)
          ? null
          : AppBar(
              backgroundColor: NegiluColors.brandGreenDark,
              elevation: 0,
              leading: canPop
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : Builder(
                      builder: (ctx) => IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                        tooltip: 'ಮೆನು (Menu)',
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                    ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sell Advisory Engine',
                    style: NegiluTypography.heading(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'ಮಾರಾಟ ಸಲಹೆ • ML Market Forecast',
                    style: NegiluTypography.body(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: NegiluSpacing.s16),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 1.5),
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Image.asset(
                          'assets/images/app_logo_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? NegiluSpacing.s20 : NegiluSpacing.s16,
              vertical: NegiluSpacing.s14,
            ),
            children: [
              // Search & Crop Chips Bar
              _buildCropSelectionBar(),
              const SizedBox(height: NegiluSpacing.s14),

              // Main Advisory Content
              if (_loading)
                const SizedBox(
                  height: 340,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: NegiluColors.brandGreenDark),
                        SizedBox(height: NegiluSpacing.s14),
                        Text(
                          'Analyzing historical mandi prices & running ML forecast...',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_error != null)
                _buildErrorCard()
              else if (_advisory != null) ...[
                ..._buildAdvisorySections(_advisory!, isDesktop),
                if (isDesktop) const SizedBox(height: NegiluSpacing.s23),
                if (isDesktop) const NegiluFooter(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropSelectionBar() {
    return Container(
      decoration: BoxDecoration(
        color: NegiluColors.surface,
        borderRadius: NegiluRadii.borderFull,
        border: Border.all(color: const Color(0xFFE8DFC8), width: 1.0),
        boxShadow: NegiluShadows.md,
      ),
      padding: const EdgeInsets.all(NegiluSpacing.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commodityController,
                  style: NegiluTypography.body(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Enter Crop Name (ಬೆಳೆ ಹೆಸರು)',
                    hintText: 'e.g. Tomato, Areca nut, Coffee',
                    prefixIcon: const Icon(Icons.eco_rounded, color: NegiluColors.brandGreenDark),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: NegiluSpacing.s14,
                      vertical: NegiluSpacing.s12,
                    ),
                  ),
                  onSubmitted: (_) => _fetchAdvisory(),
                ),
              ),
              const SizedBox(width: NegiluSpacing.s10),
              IconButton.filled(
                onPressed: _loading ? null : () => _fetchAdvisory(),
                style: IconButton.styleFrom(
                  backgroundColor: NegiluColors.brandGreenDark,
                  shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderFull),
                  padding: const EdgeInsets.all(NegiluSpacing.s14),
                ),
                icon: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: NegiluSpacing.s12),

          // Popular Karnataka Crops Chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _popularKarnatakaCrops.length,
              separatorBuilder: (_, _) => const SizedBox(width: NegiluSpacing.s8),
              itemBuilder: (context, index) {
                final crop = _popularKarnatakaCrops[index];
                final isSelected = _commodityController.text.toLowerCase().trim() == crop['en']!.toLowerCase().trim();

                return ChoiceChip(
                  label: Text('${crop['en']} (${crop['kn']})'),
                  selected: isSelected,
                  onSelected: (_) => _fetchAdvisory(overrideCrop: crop['en']),
                  selectedColor: NegiluColors.brandGreenDark,
                  labelStyle: NegiluTypography.body(
                    color: isSelected ? Colors.white : NegiluColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 12,
                  ),
                  backgroundColor: NegiluColors.surface,
                  side: BorderSide(
                    color: isSelected ? NegiluColors.brandGreenDark : const Color(0xFFDCCFBD),
                    width: 1.0,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: NegiluSpacing.s12, vertical: NegiluSpacing.s4),
                  shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderCircular),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAdvisorySections(SellAdvisory advisory, bool isDesktop) {
    final hero = _buildDecisionHeroCard(advisory);
    final trajectory = _buildPriceTrajectoryCard(advisory);
    final clarity = _buildMarketClarityCard(advisory);
    final profit = _buildProfitCalculatorCard(advisory);
    final nearby = advisory.nearbyMandis.isNotEmpty ? _buildNearbyMandisCard(advisory) : null;

    if (isDesktop) {
      return [
        hero,
        const SizedBox(height: NegiluSpacing.s18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  trajectory,
                  const SizedBox(height: NegiluSpacing.s18),
                  clarity,
                ],
              ),
            ),
            const SizedBox(width: NegiluSpacing.s18),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  profit,
                  if (nearby != null) ...[
                    const SizedBox(height: NegiluSpacing.s18),
                    nearby,
                  ],
                ],
              ),
            ),
          ],
        ),
      ];
    }

    return [
      hero,
      const SizedBox(height: NegiluSpacing.s16),
      trajectory,
      const SizedBox(height: NegiluSpacing.s16),
      clarity,
      const SizedBox(height: NegiluSpacing.s16),
      profit,
      if (nearby != null) ...[
        const SizedBox(height: NegiluSpacing.s16),
        nearby,
      ],
      const SizedBox(height: NegiluSpacing.s23),
    ];
  }

  Widget _buildDecisionHeroCard(SellAdvisory advisory) {
    final vColor = _verdictColor(advisory.actionVerdict);

    return Container(
      decoration: BoxDecoration(
        color: NegiluColors.surface,
        borderRadius: NegiluRadii.borderR18,
        border: Border.all(color: vColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: NegiluShadows.md,
      ),
      padding: const EdgeInsets.all(NegiluSpacing.s18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top badge row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CropThumbnail(
                    commodity: advisory.commodity,
                    size: 58,
                    borderRadius: NegiluRadii.xl,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: vColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(_verdictIcon(advisory.actionVerdict), color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: NegiluSpacing.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: NegiluSpacing.s10,
                        vertical: NegiluSpacing.s4,
                      ),
                      decoration: BoxDecoration(
                        color: vColor.withValues(alpha: 0.14),
                        borderRadius: NegiluRadii.borderMd,
                      ),
                      child: Text(
                        advisory.verdictBadgeTextEn,
                        style: NegiluTypography.body(
                          color: vColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: NegiluSpacing.s4),
                    Text(
                      advisory.verdictBadgeTextKn,
                      style: NegiluTypography.heading(
                        color: vColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Market Target: ${advisory.commodity} (${advisory.state})',
                      style: NegiluTypography.body(
                        color: NegiluColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Confidence meter badge
              Container(
                padding: const EdgeInsets.all(NegiluSpacing.s10),
                decoration: BoxDecoration(
                  color: NegiluColors.brandGreen50,
                  borderRadius: NegiluRadii.borderFull,
                  border: Border.all(color: NegiluColors.brandGreen100),
                ),
                child: Column(
                  children: [
                    Text(
                      '${advisory.confidenceScore}%',
                      style: NegiluTypography.heading(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: NegiluColors.brandGreenDark,
                      ),
                    ),
                    Text(
                      'ML Confidence',
                      style: NegiluTypography.body(
                        fontSize: 10,
                        color: NegiluColors.textForest,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: NegiluSpacing.s16),
          const Divider(height: 1, color: Color(0xFFEFE8DB)),
          const SizedBox(height: NegiluSpacing.s14),

          // Recommendations in English & Kannada
          if (advisory.recommendationKannada.isNotEmpty) ...[
            Text(
              advisory.recommendationKannada,
              style: NegiluTypography.kannada(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.45,
                color: NegiluColors.textPrimary,
              ),
            ),
            const SizedBox(height: NegiluSpacing.s8),
          ],
          Text(
            advisory.recommendation,
            style: NegiluTypography.body(
              fontSize: 13.5,
              color: NegiluColors.textMuted,
              height: 1.4,
            ),
          ),

          const SizedBox(height: NegiluSpacing.s16),

          // Metric Stats Row
          Container(
            padding: const EdgeInsets.all(NegiluSpacing.s12),
            decoration: BoxDecoration(
              color: NegiluColors.surface2,
              borderRadius: NegiluRadii.borderFull,
              border: Border.all(color: const Color(0xFFE8DFC8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metricStat(
                  label: 'Today\'s Rate',
                  value: '₹${advisory.currentPrice.toStringAsFixed(0)}',
                  sub: '/ Quintal',
                ),
                _dividerVertical(),
                _metricStat(
                  label: '7-Day Expected',
                  value: '₹${advisory.predictedPrice7Days.toStringAsFixed(0)}',
                  sub: advisory.predictedPrice7Days >= advisory.currentPrice
                      ? '+₹${(advisory.predictedPrice7Days - advisory.currentPrice).toStringAsFixed(0)}'
                      : '-₹${(advisory.currentPrice - advisory.predictedPrice7Days).toStringAsFixed(0)}',
                  color: advisory.predictedPrice7Days >= advisory.currentPrice
                      ? NegiluColors.brandGreenDark
                      : NegiluColors.brandWarmDeep,
                ),
                _dividerVertical(),
                _metricStat(
                  label: 'ಸೀಸನ್ ಮಟ್ಟ',
                  value: '${advisory.historicalPercentile}%',
                  sub: advisory.historicalPercentile >= 75
                      ? 'ಗರಿಷ್ಠ (Peak)'
                      : (advisory.historicalPercentile <= 25 ? 'ಕನಿಷ್ಠ (Low)' : 'ಸಾಮಾನ್ಯ (Normal)'),
                  color: NegiluColors.brandGreenDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: NegiluSpacing.s12),

          // One-tap WhatsApp Advisory Share for Farmers
          InkWell(
            onTap: () => _shareAdvisoryWhatsApp(advisory),
            borderRadius: NegiluRadii.borderLg,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.12),
                borderRadius: NegiluRadii.borderLg,
                border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.45), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.share_rounded, color: Color(0xFF1E7E34), size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ಮಾರಾಟ ಸಲಹೆಯನ್ನು ವಾಟ್ಸಾಪ್‌ನಲ್ಲಿ ಹಂಚಿಕೊಳ್ಳಿ (Share Advisory)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NegiluTypography.body(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E7E34),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTrajectoryCard(SellAdvisory advisory) {
    return Container(
      decoration: BoxDecoration(
        color: NegiluColors.surface,
        borderRadius: NegiluRadii.borderR18,
        border: Border.all(color: const Color(0xFFE8DFC8), width: 1.0),
        boxShadow: NegiluShadows.md,
      ),
      padding: const EdgeInsets.all(NegiluSpacing.s18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Trajectory & Forecast',
                      style: NegiluTypography.heading(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: NegiluSpacing.s2),
                    Text(
                      'ದರ ಪ್ರವೃತ್ತಿ & 7 ದಿನಗಳ ಮುನ್ಸೂಚನೆ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NegiluTypography.body(
                        fontSize: 12,
                        color: NegiluColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: NegiluSpacing.s8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: NegiluSpacing.s8,
                  vertical: NegiluSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: NegiluColors.brandGreen50,
                  borderRadius: NegiluRadii.borderLg,
                ),
                child: Text(
                  'AI Model',
                  style: NegiluTypography.body(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: NegiluColors.brandGreenDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NegiluSpacing.s16),

          PriceTrendChart(
            history: advisory.priceHistory,
            forecast: advisory.forecastHistory,
            primaryColor: NegiluColors.brandGreenDark,
            forecastColor: NegiluColors.brandWarm,
          ),
        ],
      ),
    );
  }

  Widget _buildMarketClarityCard(SellAdvisory advisory) {
    return Container(
      decoration: BoxDecoration(
        color: NegiluColors.surface,
        borderRadius: NegiluRadii.borderR18,
        border: Border.all(color: const Color(0xFFE8DFC8), width: 1.0),
        boxShadow: NegiluShadows.md,
      ),
      padding: const EdgeInsets.all(NegiluSpacing.s18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Clarity (ಮಾರುಕಟ್ಟೆ ಸಂಜ್ಞೆಗಳು)',
            style: NegiluTypography.heading(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: NegiluSpacing.s4),
          Text(
            'ಮಾರಾಟ ನಿರ್ಧಾರಕ್ಕೆ ಪರಿಗಣಿಸಲಾದ ಪ್ರಮುಖ ಅಂಶಗಳು (Key factors evaluated for this crop):',
            style: NegiluTypography.body(fontSize: 13, color: NegiluColors.textMuted),
          ),
          const SizedBox(height: NegiluSpacing.s12),

          ...advisory.keySignals.map((signal) => _buildSignalTile(signal)),

          if (advisory.keySignals.isEmpty)
            Text(
              'No critical risk flags detected. Trading volume is within regular seasonal limits.',
              style: NegiluTypography.body(color: NegiluColors.textMuted),
            ),
        ],
      ),
    );
  }

  String _farmerFriendlySignalTitle(MarketSignal signal) {
    final t = signal.title;
    if (t.contains('+β') || t.contains('Positive Price Gradient')) {
      return 'ದರ ಏರಿಕೆಯಲ್ಲಿದೆ (Prices Climbing)';
    } else if (t.contains('-β') || t.contains('Downward') || t.contains('Negative')) {
      return 'ದರ ಇಳಿಕೆಯಾಗುತ್ತಿದೆ (Prices Softening)';
    } else if (t.contains('Percentile')) {
      return 'ಸೀಸನ್‌ನ ಉತ್ತಮ ದರ (Peak Season Rate)';
    } else if (t.contains('Minimal Storage Decay') || t.contains('Low Storage Decay')) {
      return 'ದಾಸ್ತಾನು ಸುರಕ್ಷಿತ (Safe Farm Storage)';
    } else if (t.contains('Perishable')) {
      return 'ಬೇಗ ಹಾಳಾಗುವ ಬೆಳೆ (High Spoilage Alert)';
    }
    return t;
  }

  String _farmerFriendlySignalDesc(MarketSignal signal) {
    final d = signal.description;
    if (d.contains('moving averages') || d.contains('wholesale buyer bidding') || d.contains('buyer accumulation')) {
      return 'ಮಾರುಕಟ್ಟೆಯಲ್ಲಿ ಖರೀದಿದಾರರ ನಿರಂತರ ಬೇಡಿಕೆ ಇದೆ (Strong wholesale buyer demand across APMCs).';
    } else if (d.contains('supply inflow') || d.contains('Arrival supply') || d.contains('outpaces')) {
      return 'ಮಂಡಿಗಳಲ್ಲಿ ಆವಕ ಹೆಚ್ಚಾಗಿದ್ದು ದರ ಸ್ವಲ್ಪ ಇಳಿಕೆಯಾಗಬಹುದು (Arrival supply slightly exceeds demand).';
    } else if (d.contains('historical corridor') || d.contains('quartile') || d.contains('top quartile')) {
      return 'ಪ್ರಸ್ತುತ ಮಾರುಕಟ್ಟೆ ದರವು ಕಳೆದ ಎರಡು ತಿಂಗಳುಗಳಲ್ಲಿ ಉತ್ತಮ ಮಟ್ಟದಲ್ಲಿದೆ (Spot rate is at season highs).';
    } else if (d.contains('Produce retains test weight') || d.contains('standard farm warehouses') || d.contains('maintains moisture')) {
      return 'ದಾಸ್ತಾನು ಹಾನಿಯ ಅಪಾಯವಿಲ್ಲ, ಕಾಯ್ದಿರಿಸಿ ಉತ್ತಮ ದರಕ್ಕೆ ಮಾರಾಟ ಮಾಡಬಹುದು (Safe to hold for higher rates).';
    } else if (d.contains('refrigerated transit') || d.contains('Ambient') || d.contains('shrinkage')) {
      return 'ಶೀತಲ ಗೋದಾಮು ಇಲ್ಲದಿದ್ದರೆ ತೂಕ ನಷ್ಟವಾಗಬಹುದು, ಬೇಗ ಮಾರಾಟ ಉತ್ತಮ (Sell promptly to avoid weight loss).';
    }
    return d;
  }

  Widget _buildSignalTile(MarketSignal signal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NegiluSpacing.s10),
      child: Container(
        padding: const EdgeInsets.all(NegiluSpacing.s12),
        decoration: BoxDecoration(
          color: signal.isPositive
              ? NegiluColors.brandGreen50
              : NegiluColors.surfaceWarmMuted,
          borderRadius: NegiluRadii.borderFull,
          border: Border.all(
            color: signal.isPositive
                ? NegiluColors.brandGreen100
                : NegiluColors.brandWarm100,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              signal.isPositive ? Icons.check_circle_outline : Icons.info_outline,
              color: signal.isPositive ? NegiluColors.brandGreenDark : NegiluColors.brandWarm,
              size: 20,
            ),
            const SizedBox(width: NegiluSpacing.s10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _farmerFriendlySignalTitle(signal),
                    style: NegiluTypography.body(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: NegiluColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: NegiluSpacing.s2),
                  Text(
                    _farmerFriendlySignalDesc(signal),
                    style: NegiluTypography.body(
                      fontSize: 12.5,
                      color: NegiluColors.textForest,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitCalculatorCard(SellAdvisory advisory) {
    final currentTotal = _farmerQuantity * advisory.currentPrice;
    final forecastTotal = _farmerQuantity * advisory.predictedPrice7Days;
    final netAdvantage = _farmerQuantity * advisory.expectedNetHoldingBenefit;

    return Container(
      decoration: BoxDecoration(
        color: NegiluColors.surface,
        borderRadius: NegiluRadii.borderR18,
        border: Border.all(color: const Color(0xFFE8DFC8), width: 1.0),
        boxShadow: NegiluShadows.md,
      ),
      padding: const EdgeInsets.all(NegiluSpacing.s18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(NegiluSpacing.s6),
                decoration: const BoxDecoration(
                  color: NegiluColors.brandGreenDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calculate_outlined, color: Colors.white, size: 18),
              ),
              const SizedBox(width: NegiluSpacing.s10),
              Expanded(
                child: Text(
                  'Holding Profit Calculator (ಲಾಭ ಲೆಕ್ಕಾಚಾರ)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NegiluTypography.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NegiluSpacing.s4),
          Text(
            'Enter your harvested crop quantity to calculate estimated net returns:',
            style: NegiluTypography.body(fontSize: 13, color: NegiluColors.textMuted),
          ),
          const SizedBox(height: NegiluSpacing.s14),

          // Quick quantity preset chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [5.0, 10.0, 20.0, 50.0, 100.0].map((q) {
              final isSelected = (_farmerQuantity - q).abs() < 0.1;
              return ChoiceChip(
                label: Text('${q.toInt()} Qtl (${q.toInt() * 100} kg)'),
                selected: isSelected,
                selectedColor: NegiluColors.brandGreenDark,
                backgroundColor: NegiluColors.surface,
                labelStyle: NegiluTypography.body(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : NegiluColors.textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: NegiluRadii.borderFull,
                  side: BorderSide(
                    color: isSelected ? NegiluColors.brandGreenDark : const Color(0xFFD4C8B5),
                  ),
                ),
                onSelected: (_) {
                  setState(() {
                    _farmerQuantity = q;
                    _quantityController.text = q.toInt().toString();
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: NegiluSpacing.s10),

          // Slider + Input
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: NegiluColors.brandGreenDark,
                    thumbColor: NegiluColors.brandGreenDark,
                  ),
                  child: Slider(
                    value: _farmerQuantity.clamp(1.0, 200.0),
                    min: 1.0,
                    max: 200.0,
                    divisions: 199,
                    label: '${_farmerQuantity.round()} Qtl',
                    onChanged: (val) {
                      setState(() {
                        _farmerQuantity = val;
                        _quantityController.text = val.round().toString();
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: 'Qtl',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: NegiluRadii.borderLg),
                  ),
                  onChanged: (val) {
                    final parsed = double.tryParse(val);
                    if (parsed != null && parsed > 0) {
                      setState(() => _farmerQuantity = parsed);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: NegiluSpacing.s12),

          // Results grid
          Container(
            padding: const EdgeInsets.all(NegiluSpacing.s14),
            decoration: BoxDecoration(
              color: NegiluColors.surface2,
              borderRadius: NegiluRadii.borderFull,
              border: Border.all(color: const Color(0xFFE8DFC8)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Today\'s Value (${_farmerQuantity.toStringAsFixed(0)} Qtl):',
                        style: NegiluTypography.body(color: NegiluColors.textForest)),
                    Text('₹${currentTotal.toStringAsFixed(0)}',
                        style: NegiluTypography.body(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: NegiluSpacing.s6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('7-Day Forecasted Gross Value:',
                        style: NegiluTypography.body(color: NegiluColors.textForest)),
                    Text('₹${forecastTotal.toStringAsFixed(0)}',
                        style: NegiluTypography.body(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: forecastTotal >= currentTotal ? NegiluColors.brandGreenDark : NegiluColors.brandWarmDeep,
                        )),
                  ],
                ),
                const Divider(height: 16, color: Color(0xFFEFE8DB)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'ಅಂದಾಜು ನಿವ್ವಳ ಲಾಭ (Net Advantage):',
                        style: NegiluTypography.body(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: NegiluSpacing.s8),
                    Text(
                      '${netAdvantage >= 0 ? '+' : ''}₹${netAdvantage.toStringAsFixed(0)}',
                      style: NegiluTypography.heading(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: netAdvantage >= 0 ? NegiluColors.brandGreenDark : NegiluColors.brandWarmDeep,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyMandisCard(SellAdvisory advisory) {
    return Container(
      decoration: BoxDecoration(
        color: NegiluColors.surface,
        borderRadius: NegiluRadii.borderR18,
        border: Border.all(color: const Color(0xFFE8DFC8), width: 1.0),
        boxShadow: NegiluShadows.md,
      ),
      padding: const EdgeInsets.all(NegiluSpacing.s18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby Mandi Price Comparison',
                      style: NegiluTypography.heading(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ಯಾವ ಮಂಡಿಯಲ್ಲಿ ಹೆಚ್ಚಿನ ದರ? (Regional Arbitrage)',
                      style: NegiluTypography.body(
                        fontSize: 12,
                        color: NegiluColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: NegiluSpacing.s8),
              const Icon(Icons.compare_arrows, color: NegiluColors.brandGreenDark),
            ],
          ),
          const SizedBox(height: NegiluSpacing.s12),

          ...advisory.nearbyMandis.map((mandi) {
            final isHigher = mandi.difference > 0;
            final isCurrent = mandi.difference == 0;

            return Container(
              margin: const EdgeInsets.only(bottom: NegiluSpacing.s8),
              padding: const EdgeInsets.symmetric(horizontal: NegiluSpacing.s14, vertical: NegiluSpacing.s10),
              decoration: BoxDecoration(
                color: isCurrent
                    ? NegiluColors.brandGreen50
                    : (isHigher ? NegiluColors.brandGreen50.withValues(alpha: 0.5) : Colors.white),
                borderRadius: NegiluRadii.borderFull,
                border: Border.all(
                  color: isCurrent
                      ? NegiluColors.brandGreenDark
                      : (isHigher ? NegiluColors.brandGreen100 : const Color(0xFFEFE8DB)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              mandi.market,
                              style: NegiluTypography.body(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: NegiluSpacing.s6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: NegiluColors.brandGreenDark,
                                  borderRadius: NegiluRadii.borderMd,
                                ),
                                child: const Text(
                                  'Selected',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          mandi.district,
                          style: NegiluTypography.body(fontSize: 12, color: NegiluColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${mandi.price.toStringAsFixed(0)}',
                        style: NegiluTypography.heading(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: NegiluColors.brandGreenDark,
                        ),
                      ),
                      if (!isCurrent)
                        Text(
                          '${isHigher ? '+' : ''}₹${mandi.difference.toStringAsFixed(0)}/qtl',
                          style: NegiluTypography.body(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isHigher ? NegiluColors.brandGreenDark : NegiluColors.brandWarmDeep,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NegiluSpacing.s23),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: NegiluColors.brandWarm),
            const SizedBox(height: NegiluSpacing.s12),
            Text(_error!, textAlign: TextAlign.center, style: NegiluTypography.body()),
            const SizedBox(height: NegiluSpacing.s14),
            ElevatedButton(
              onPressed: () => _fetchAdvisory(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricStat({
    required String label,
    required String value,
    required String sub,
    Color? color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: NegiluTypography.heading(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? NegiluColors.brandGreenDark,
          ),
        ),
        const SizedBox(height: NegiluSpacing.s2),
        Text(
          label,
          style: NegiluTypography.body(fontSize: 11, color: NegiluColors.textMuted),
        ),
        Text(
          sub,
          style: NegiluTypography.body(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color ?? NegiluColors.textForest,
          ),
        ),
      ],
    );
  }

  Widget _dividerVertical() {
    return Container(width: 1, height: 42, color: const Color(0xFFDCCFBD));
  }

  Future<void> _shareAdvisoryWhatsApp(SellAdvisory advisory) async {
    final verdict = advisory.actionVerdict == 'HOLD_AND_WAIT'
        ? 'ಕಾಯ್ದಿರಿಸಿ (HOLD & WAIT)'
        : (advisory.actionVerdict == 'SELL_NOW' ? 'ಮಾರಾಟ ಮಾಡಿ (SELL NOW)' : 'ಗಮನಿಸಿ (MONITOR)');
    final text = '🌾 *ನೇಗಿಲು ಕೃಷಿ ಮಾರಾಟ ಸಲಹೆ (Negilu Advisory)* 🌾\n\n'
        '🌱 *ಬೆಳೆ:* ${advisory.commodity}\n'
        '📍 *ಮಂಡಿ:* ${advisory.market} (${advisory.district})\n'
        '💰 *ಇಂದಿನ ದರ:* ₹${advisory.currentPrice.toStringAsFixed(0)} / ಕ್ವಿಂಟಾಲ್\n'
        '📈 *7 ದಿನಗಳ ನಿರೀಕ್ಷಿತ ದರ:* ₹${advisory.predictedPrice7Days.toStringAsFixed(0)} / ಕ್ವಿಂಟಾಲ್\n'
        '📢 *ಸಲಹೆ:* $verdict\n'
        '${advisory.recommendationKannada.isNotEmpty ? '\n${advisory.recommendationKannada}' : ''}\n\n'
        'ನೇಗಿಲು ಕೃಷಿ ಆ್ಯಪ್ - ಕರ್ನಾಟಕ ರೈತರಿಗಾಗಿ.';

    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')),
        );
      }
    }
  }
}
