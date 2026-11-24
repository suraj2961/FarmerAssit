import 'package:flutter/material.dart';
import '../config/negilu_tokens.dart';
import '../models/weather_info.dart';
import '../models/sell_advisory.dart';
import '../services/weather_service.dart';
import '../services/crop_advisory_service.dart';
import '../widgets/commodity_field.dart';
import '../widgets/negilu_footer.dart';
import '../widgets/farmer_drawer.dart';
import '../data/crop_categories.dart';
import '../data/crop_images.dart';
import '../data/karnataka_districts.dart';

const List<String> _featuredCrops = [
  'Areca nut',
  'Tomato',
  'Coconut',
  'Onion',
  'Maize',
  'Coffee',
  'Paddy',
  'Ragi',
];

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavigateToTab;
  final ValueChanged<String> onSearchCommodity;
  final String? selectedDistrict;
  final ValueChanged<String>? onDistrictSelected;

  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
    required this.onSearchCommodity,
    this.selectedDistrict,
    this.onDistrictSelected,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final CropAdvisoryService _advisoryService = CropAdvisoryService();
  final TextEditingController _searchController = TextEditingController();

  WeatherInfo? _weather;
  bool _loadingWeather = true;

  Map<String, SellAdvisory?> _advisories = {};
  bool _loadingAdvisories = true;

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    final dist = widget.selectedDistrict ?? 'Dakshina Kannada';
    // 1. Instant 0ms baseline data so the main thread never skips frames or hangs
    _weather = getDistrictFallbackWeather(dist);
    _loadingWeather = false;

    final initialAdvisories = <String, SellAdvisory?>{};
    for (final crop in _featuredCrops) {
      initialAdvisories[crop] = _advisoryService.getLocalAdvisory(crop, district: dist);
    }
    _advisories = initialAdvisories;
    _loadingAdvisories = false;

    // 2. Fetch live updates in the background without blocking the UI thread
    _loadWeather();
    _loadFeaturedAdvisories();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDistrict != null &&
        widget.selectedDistrict != oldWidget.selectedDistrict) {
      _loadWeather();
      _loadFeaturedAdvisories();
    }
  }

  Future<void> _loadWeather() async {
    final dist = widget.selectedDistrict ?? 'Dakshina Kannada';
    final city = districtToWeatherCity(dist);
    try {
      final weather = await _weatherService.getCurrentWeatherByCity(city);
      if (mounted) {
        setState(() {
          _weather = weather;
          _loadingWeather = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _weather = getDistrictFallbackWeather(dist);
          _loadingWeather = false;
        });
      }
    }
  }

  Future<void> _loadFeaturedAdvisories() async {
    final results = <String, SellAdvisory?>{};
    final dist = widget.selectedDistrict ?? 'Dakshina Kannada';

    await Future.wait(
      _featuredCrops.map((crop) async {
        try {
          final advisory = await _advisoryService.getSellAdvisory(
            commodity: crop,
            state: 'Karnataka',
            district: dist,
          );
          results[crop] = advisory;
        } catch (_) {
          results[crop] = null;
        }
      }),
    );

    if (mounted) {
      setState(() {
        _advisories = results;
        _loadingAdvisories = false;
      });
    }
  }

  @override
  void dispose() {
    _weatherService.dispose();
    _advisoryService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _trendColor(String verdict) {
    switch (verdict) {
      case 'STRONG_SELL':
      case 'SELL_IMMEDIATELY':
        return NegiluColors.brandWarmDeep; // #6E2E15
      case 'HOLD_AND_WAIT':
        return NegiluColors.brandGreenDark; // #1C5A2C
      case 'SELL_NOW':
        return NegiluColors.brandWarm; // #C2562B
      default:
        return NegiluColors.brandWarmDark; // #9C4220
    }
  }

  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderR18),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_logo_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: NegiluSpacing.s10),
            Expanded(
              child: Text(
                'FarmerAssist • ನೇಗಿಲು ಕೃಷಿ',
                style: NegiluTypography.heading(fontSize: 17),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ClipRRect(
                    borderRadius: NegiluRadii.borderMd,
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _guideStep('1', 'Check APMC Mandi Rates',
                  'Live daily wholesale market rates across Karnataka APMCs (Agmarknet & KRAMA).'),
              _guideStep('2', 'ML Sell Advisory',
                  'AI time-series model calculates regression momentum, volatility, and perishability to guide when to sell or hold.'),
              _guideStep('3', 'Agri Weather & Field Work',
                  'Farming suitability alerts for pesticide spraying, areca drying, and harvesting windows.'),
              _guideStep('4', 'Government Schemes',
                  'Direct subsidies, loan waivers, and machinery rental programs with official application links.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Understood (ತಿಳಿಯಿತು)'),
          ),
        ],
      ),
    );
  }

  Widget _guideStep(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NegiluSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: NegiluSpacing.s12,
            backgroundColor: NegiluColors.brandGreenDark,
            child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: NegiluSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: NegiluTypography.body(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(desc, style: NegiluTypography.body(fontSize: 12, color: NegiluColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    final visibleCrops = _selectedCategory == 'All'
        ? _featuredCrops
        : _featuredCrops.where((c) => categoryFor(c) == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: NegiluColors.surface2, // #FAF6EC organic warm background
      drawer: isDesktop
          ? null
          : FarmerDrawer(
              selectedIndex: 0,
              onTabSelected: widget.onNavigateToTab,
              selectedDistrict: widget.selectedDistrict ?? 'Dakshina Kannada',
              onDistrictSelected: widget.onDistrictSelected,
              onShowGuide: () => _showGuideDialog(context),
            ),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: NegiluColors.brandGreenDark,
              elevation: 0,
              leading: Builder(
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
                    'ನಮಸ್ಕಾರ ರೈತ ಬಾಂಧವರೇ • FarmerAssist',
                    style: NegiluTypography.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    'ನೇಗಿಲು ಕೃಷಿ • Negilu Krishi',
                    style: NegiluTypography.heading(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  tooltip: 'Guide',
                  onPressed: () => _showGuideDialog(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: NegiluSpacing.s16),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
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
      body: RefreshIndicator(
        color: NegiluColors.brandGreenDark,
        onRefresh: () async {
          setState(() {
            _loadingWeather = true;
            _loadingAdvisories = true;
          });
          await Future.wait([_loadWeather(), _loadFeaturedAdvisories()]);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1140),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? NegiluSpacing.s23 : NegiluSpacing.s16,
                    vertical: NegiluSpacing.s18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Executive Alert Ribbon
                      _buildAlertRibbon(),
                      const SizedBox(height: NegiluSpacing.s16),

                      // 2. Executive Hero Banner
                      _buildHeroBanner(isDesktop),
                      const SizedBox(height: NegiluSpacing.s20),

                      // 3. Search & Live Weather Card Row
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommodityField(
                                    controller: _searchController,
                                    labelText: 'Search any crop prices & advisory (ಬೆಳೆ ಹೆಸರು ಹುಡುಕಿ)',
                                    onSubmitted: (value) {
                                      if (value.trim().isNotEmpty) {
                                        widget.onSearchCommodity(value.trim());
                                      }
                                    },
                                  ),
                                  const SizedBox(height: NegiluSpacing.s10),
                                  _buildMyCropsQuickStrip(),
                                ],
                              ),
                            ),
                            const SizedBox(width: NegiluSpacing.s16),
                            Expanded(
                              flex: 2,
                              child: _buildWeatherMiniCard(context),
                            ),
                          ],
                        )
                      else ...[
                        CommodityField(
                          controller: _searchController,
                          labelText: 'Search any crop prices & advisory (ಬೆಳೆ ಹೆಸರು ಹುಡುಕಿ)',
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              widget.onSearchCommodity(value.trim());
                            }
                          },
                        ),
                        const SizedBox(height: NegiluSpacing.s10),
                        _buildMyCropsQuickStrip(),
                        const SizedBox(height: NegiluSpacing.s14),
                        _buildWeatherMiniCard(context),
                      ],
                      const SizedBox(height: NegiluSpacing.s23),

                      // 4. Quick Services Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quick Services (ತ್ವರಿತ ಸೇವೆಗಳು)',
                                  style: NegiluTypography.heading(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: NegiluSpacing.s2),
                                Text(
                                  'Empowering smart agricultural decisions across Karnataka',
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
                              borderRadius: NegiluRadii.borderCircular,
                              border: Border.all(color: NegiluColors.brandGreen100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, size: 13, color: NegiluColors.brandGreenDark),
                                const SizedBox(width: NegiluSpacing.s4),
                                Text(
                                  'Suite',
                                  style: NegiluTypography.body(
                                    fontSize: 11,
                                    color: NegiluColors.brandGreenDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: NegiluSpacing.s14),
                      _buildQuickActionsGrid(context),
                      const SizedBox(height: NegiluSpacing.s23),

                      // 5. Category Selection
                      Text(
                        'Browse Categories (ವರ್ಗಗಳು)',
                        style: NegiluTypography.heading(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: NegiluSpacing.s10),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: cropCategories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: NegiluSpacing.s8),
                          itemBuilder: (context, index) {
                            final category = cropCategories[index];
                            final kn = categoryKannada[category] ?? '';
                            final selected = category == _selectedCategory;
                            return ChoiceChip(
                              label: Text('$category ${kn.isNotEmpty ? "($kn)" : ""}'),
                              selected: selected,
                              onSelected: (_) => setState(() => _selectedCategory = category),
                              selectedColor: NegiluColors.brandGreenDark,
                              labelStyle: NegiluTypography.body(
                                color: selected ? Colors.white : NegiluColors.textPrimary,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 12,
                              ),
                              backgroundColor: NegiluColors.surface,
                              side: BorderSide(
                                color: selected ? NegiluColors.brandGreenDark : const Color(0xFFDCCFBD),
                                width: 1.0,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderCircular),
                              padding: const EdgeInsets.symmetric(
                                horizontal: NegiluSpacing.s12,
                                vertical: NegiluSpacing.s4,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: NegiluSpacing.s22),

                      // 6. Today's Live Mandi Pulse & AI Sell Advice Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Live Mandi Rates & AI Advice',
                                  style: NegiluTypography.heading(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: NegiluSpacing.s2),
                                Text(
                                  'ಇಂದಿನ ಮಾರುಕಟ್ಟೆ ದರಗಳು & AI ಮಾರಾಟ ಸಲಹೆ',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: NegiluTypography.kannada(
                                    fontSize: 12,
                                    color: NegiluColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: NegiluSpacing.s8),
                          OutlinedButton(
                            onPressed: () => widget.onNavigateToTab(1),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: NegiluColors.brandGreenDark,
                              side: const BorderSide(color: NegiluColors.brandGreenDark, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderFull),
                              padding: const EdgeInsets.symmetric(
                                horizontal: NegiluSpacing.s10,
                                vertical: NegiluSpacing.s6,
                              ),
                              textStyle: NegiluTypography.body(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('View All'),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward, size: 13),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: NegiluSpacing.s12),

                      // 7. Trend Cards Grid / Scroll
                      _buildTrendList(visibleCrops),
                      const SizedBox(height: NegiluSpacing.s23),

                      // 8. Institutional Community & Data Trust Card
                      _buildInstitutionalCard(),
                      const SizedBox(height: NegiluSpacing.s23),
                    ],
                  ),
                ),
              ),
            ),
            if (isDesktop) NegiluFooter(onNavigate: widget.onNavigateToTab),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCropsQuickStrip() {
    final crops = const [
      {'name': 'Arecanut', 'label': '🌿 ಅಡಿಕೆ', 'en': 'Arecanut'},
      {'name': 'Black Pepper', 'label': '🌶️ ಕಾಳುಮೆಣಸು', 'en': 'Pepper'},
      {'name': 'Coconut', 'label': '🥥 ತೆಂಗಿನಕಾಯಿ', 'en': 'Coconut'},
      {'name': 'Rubber', 'label': '⚪ ರಬ್ಬರ್', 'en': 'Rubber'},
      {'name': 'Paddy', 'label': '🌾 ಭತ್ತ', 'en': 'Paddy'},
      {'name': 'Tomato', 'label': '🍅 ಟೊಮೇಟೊ', 'en': 'Tomato'},
      {'name': 'Onion', 'label': '🧅 ಈರುಳ್ಳಿ', 'en': 'Onion'},
      {'name': 'Maize', 'label': '🌽 ಮೆಕ್ಕೆಜೋಳ', 'en': 'Maize'},
      {'name': 'Coffee', 'label': '☕ ಕಾಫಿ', 'en': 'Coffee'},
      {'name': 'Ginger', 'label': '🫚 ಶುಂಠಿ', 'en': 'Ginger'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.touch_app_rounded, size: 16, color: NegiluColors.brandGreenDark),
            const SizedBox(width: 6),
            Text(
              'ನನ್ನ ಬೆಳೆಗಳು (My Crops - Quick Check):',
              style: NegiluTypography.body(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: NegiluColors.textForest,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: crops.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final c = crops[i];
              return InkWell(
                onTap: () {
                  _searchController.text = c['name']!;
                  widget.onSearchCommodity(c['name']!);
                },
                borderRadius: NegiluRadii.borderLg,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: NegiluColors.surface,
                    borderRadius: NegiluRadii.borderLg,
                    border: Border.all(color: const Color(0xFFD4C8B5), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c['label']!,
                        style: NegiluTypography.body(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: NegiluColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${c['en']!})',
                        style: NegiluTypography.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: NegiluColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlertRibbon() {
    final weather = _weather;
    final dist = widget.selectedDistrict ?? 'Dakshina Kannada';

    String alertTitle;
    String alertText;
    IconData alertIcon = Icons.campaign_rounded;
    Color alertBg = NegiluColors.surfaceWarmMuted;
    Color alertBorder = NegiluColors.brandWarm100;
    Color alertIconBg = NegiluColors.brandWarm50;
    Color alertIconColor = NegiluColors.brandWarm;
    Color alertTitleColor = NegiluColors.brandWarmDark;
    Color alertTextColor = NegiluColors.brandWarmDeep;

    if (weather == null) {
      alertTitle = 'AGRI WEATHER ALERT • ಹವಾಮಾನ ಎಚ್ಚರಿಕೆ ($dist)';
      alertText = '$dist ಭಾಗದಲ್ಲಿ ಹವಾಮಾನ ಪರಿಶೀಲಿಸಲಾಗುತ್ತಿದೆ... ಕೃಷಿ ಕಾರ್ಯಗಳಿಗೆ ಹವಾಮಾನ ಮುನ್ಸೂಚನೆ ಗಮನಿಸಿ.';
    } else {
      final cond = weather.condition.toLowerCase();
      final desc = weather.description.toLowerCase();
      final isRain = cond.contains('rain') || cond.contains('drizzle') || cond.contains('thunder') || desc.contains('rain');
      final isWindy = weather.windSpeed > 4.5;
      final isHot = weather.temperature >= 35;
      final isHumidCloudy = weather.humidity > 75 || cond.contains('cloud');

      if (isRain) {
        alertTitle = 'AGRI WEATHER ALERT • ಮಳೆ ಎಚ್ಚರಿಕೆ (${weather.locationName})';
        alertText = '$dist ಭಾಗದಲ್ಲಿ ಮಳೆ ಸಂಭವ (${weather.description}). ಒಣಗಿಸಲು ಹಾಕಿರುವ ಅಡಿಕೆ, ಕೊಬ್ಬರಿ ಹಾಗೂ ಕಾಳುಗಳನ್ನು ರಕ್ಷಿಸಿ. ಕೀಟನಾಶಕ ಸಿಂಪಡಣೆ ಮುಂದೂಡಿ.';
        alertIcon = Icons.umbrella_rounded;
        alertBg = const Color(0xFFFDE8E8);
        alertBorder = const Color(0xFFF8B4B4);
        alertIconBg = const Color(0xFFFBD5D5);
        alertIconColor = const Color(0xFFC81E1E);
        alertTitleColor = const Color(0xFF9B1C1C);
        alertTextColor = const Color(0xFF771D1D);
      } else if (isWindy) {
        alertTitle = 'AGRI WEATHER ALERT • ಗಾಳಿಯ ವೇಗ ಎಚ್ಚರಿಕೆ (${weather.locationName})';
        alertText = 'ಗಾಳಿಯ ವೇಗ ${weather.windSpeed.toStringAsFixed(1)} m/s ತಲುಪಿದೆ. ಕೀಟನಾಶಕ ಸಿಂಪಡಣೆ ಮಾಡಬೇಡಿ (ಮದ್ದು ಕೊಚ್ಚಿ ಹೋಗುವ ಅಪಾಯವಿದೆ).';
        alertIcon = Icons.air_rounded;
      } else if (isHot) {
        alertTitle = 'AGRI WEATHER ADVISORY • ತಾಪಮಾನ ಎಚ್ಚರಿಕೆ (${weather.locationName})';
        alertText = '$dist ನಲ್ಲಿ ಗರಿಷ್ಠ ತಾಪಮಾನ ${weather.temperature.toStringAsFixed(0)}°C (ಆರ್ದ್ರತೆ ${weather.humidity}%). ಮುಂಜಾನೆ ಅಥವಾ ಸಂಜೆ ವೇಳೆ ತೋಟಗಳಿಗೆ ಹನಿ ನೀರಾವರಿ ಒದಗಿಸಿ.';
        alertIcon = Icons.wb_sunny_rounded;
      } else if (isHumidCloudy) {
        alertTitle = 'AGRI WEATHER ADVISORY • ಮೋಡ ಕವಿದ ವಾತಾವರಣ (${weather.locationName})';
        alertText = '$dist ಭಾಗದಲ್ಲಿ ಮೋಡ ಕವಿದ ವಾತಾವರಣ (${weather.description}). ಅಡಿಕೆ ಹಾಗೂ ಕಾಳು ಒಣಗಿಸುವಾಗ ಮಳೆ ರಕ್ಷಣೆ ಮಾಡಿ.';
        alertIcon = Icons.cloud_queue_rounded;
      } else {
        alertTitle = 'AGRI WEATHER ADVISORY • ಕೃಷಿ ಕಾರ್ಯಾನುಕೂಲ (${weather.locationName})';
        alertText = '$dist ನಲ್ಲಿ ${weather.temperature.toStringAsFixed(0)}°C ತಿಳಿ ಹವಾಮಾನ. ಕೀಟನಾಶಕ ಸಿಂಪಡಣೆ, ಕಣದಲ್ಲಿ ಕಾಳು ಒಣಗಿಸುವಿಕೆ ಹಾಗೂ ಕೊಯ್ಲಿಗೆ ಅತ್ಯುತ್ತಮ ಸಮಯ.';
        alertIcon = Icons.check_circle_outline;
        alertBg = NegiluColors.brandGreen50;
        alertBorder = NegiluColors.brandGreen100;
        alertIconBg = Colors.white;
        alertIconColor = NegiluColors.brandGreenDark;
        alertTitleColor = NegiluColors.brandGreenDark;
        alertTextColor = NegiluColors.textForest;
      }
    }

    return InkWell(
      onTap: () => widget.onNavigateToTab(3),
      borderRadius: NegiluRadii.borderFull,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: NegiluSpacing.s16,
          vertical: NegiluSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: alertBg,
          borderRadius: NegiluRadii.borderFull,
          border: Border.all(color: alertBorder),
          boxShadow: NegiluShadows.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(NegiluSpacing.s6),
              decoration: BoxDecoration(
                color: alertIconBg,
                borderRadius: NegiluRadii.borderLg,
              ),
              child: Icon(alertIcon, color: alertIconColor, size: 20),
            ),
            const SizedBox(width: NegiluSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          alertTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NegiluTypography.body(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: alertTitleColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: NegiluSpacing.s6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: alertIconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NegiluSpacing.s2),
                  Text(
                    alertText,
                    style: NegiluTypography.kannada(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: alertTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: NegiluSpacing.s6),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: alertIconColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? NegiluSpacing.s23 : NegiluSpacing.s19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            NegiluColors.brandGreenDark, // #1C5A2C deep forest
            NegiluColors.brandGreen,     // #2C7A3F rich agricultural green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: NegiluRadii.borderR24,
        boxShadow: NegiluShadows.brandAccent,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -20,
            child: Icon(
              Icons.agriculture_rounded,
              size: isDesktop ? 180 : 120,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: NegiluSpacing.s10,
                  vertical: NegiluSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: NegiluColors.brandWarm, // #C2562B Terracotta accent
                  borderRadius: NegiluRadii.borderCircular,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: NegiluSpacing.s6),
                    Text(
                      'AI SELL ADVISORY & APMC MANDI PULSE',
                      style: NegiluTypography.body(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NegiluSpacing.s14),

              // Headline
              Text(
                'ಸರಿಯಾದ ಸಮಯಕ್ಕೆ ಮಾರಾಟ — ಗರಿಷ್ಠ ಲಾಭ\nSmart Agricultural Decisions with Negilu',
                style: NegiluTypography.heading(
                  color: Colors.white,
                  fontSize: isDesktop ? 28 : 22,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: NegiluSpacing.s8),

              // Description
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  'ಕರ್ನಾಟಕದ ಎಲ್ಲಾ APMC ಮಂಡಿಗಳ ಲೈವ್ ದರಗಳು, ಕೃತಕ ಬುದ್ಧಿಮತ್ತೆ (AI) ಆಧಾರಿತ ಮಾರಾಟ ಮುನ್ಸೂಚನೆ ಹಾಗೂ ನಿಖರ ಕೃಷಿ ಹವಾಮಾನ ಸಲಹೆಗಳು ಒಂದೇ ವೇದಿಕೆಯಲ್ಲಿ.',
                  style: NegiluTypography.kannada(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: NegiluSpacing.s18),

              // CTAs Row
              Wrap(
                spacing: NegiluSpacing.s12,
                runSpacing: NegiluSpacing.s10,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => widget.onNavigateToTab(1),
                    icon: const Icon(Icons.storefront_rounded, size: 17, color: NegiluColors.brandGreenDark),
                    label: const Text('Check Mandi Prices (ದರಗಳು)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NegiluColors.surface,
                      foregroundColor: NegiluColors.brandGreenDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: NegiluSpacing.s18,
                        vertical: NegiluSpacing.s12,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderFull),
                      textStyle: NegiluTypography.body(fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => widget.onNavigateToTab(2),
                    icon: const Icon(Icons.insights_rounded, size: 17, color: Colors.white),
                    label: const Text('Launch AI Sell Advisory (ಮಾರಾಟ ಸಲಹೆ)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70, width: 1.4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: NegiluSpacing.s18,
                        vertical: NegiluSpacing.s12,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderFull),
                      textStyle: NegiluTypography.body(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;
        final aspectRatio = constraints.maxWidth >= 720 ? 1.55 : 1.35;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: NegiluSpacing.s12,
          crossAxisSpacing: NegiluSpacing.s12,
          childAspectRatio: aspectRatio,
          children: [
            _quickCard(
              icon: Icons.storefront_rounded,
              title: 'Mandi Rates',
              sub: 'ಮಾರುಕಟ್ಟೆ ದರಗಳು',
              tag: 'Agmarknet Live',
              color: NegiluColors.brandGreenDark,
              bgColor: NegiluColors.brandGreen50,
              onTap: () => widget.onNavigateToTab(1),
            ),
            _quickCard(
              icon: Icons.insights_rounded,
              title: 'Sell Advisory',
              sub: 'ಮಾರಾಟ ನಿರ್ಧಾರ (AI)',
              tag: 'Momentum Model',
              color: NegiluColors.brandWarm,
              bgColor: NegiluColors.surfaceWarmMuted,
              onTap: () => widget.onNavigateToTab(2),
            ),
            _quickCard(
              icon: Icons.wb_sunny_rounded,
              title: 'Agri Weather',
              sub: 'ಹವಾಮಾನ ಎಚ್ಚರಿಕೆ',
              tag: 'IMD & Field Radar',
              color: NegiluColors.textBlue,
              bgColor: NegiluColors.surfaceGreenMuted.withValues(alpha: 0.4),
              onTap: () => widget.onNavigateToTab(3),
            ),
            _quickCard(
              icon: Icons.account_balance_rounded,
              title: 'Govt Schemes',
              sub: 'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು',
              tag: 'Subsidies & Direct Links',
              color: NegiluColors.brandWarmDark,
              bgColor: NegiluColors.brandWarm100.withValues(alpha: 0.4),
              onTap: () => widget.onNavigateToTab(4),
            ),
          ],
        );
      },
    );
  }

  Widget _quickCard({
    required IconData icon,
    required String title,
    required String sub,
    required String tag,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: NegiluColors.surface,
        borderRadius: NegiluRadii.borderFull,
        border: Border.all(color: const Color(0xFFE8DFC8), width: 1.0),
        boxShadow: NegiluShadows.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: NegiluRadii.borderFull,
          child: Padding(
            padding: const EdgeInsets.all(NegiluSpacing.s14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(NegiluSpacing.s8),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: NegiluRadii.borderLg,
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: NegiluColors.textSubtle),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: NegiluTypography.body(fontWeight: FontWeight.w800, fontSize: 14.5),
                ),
                const SizedBox(height: NegiluSpacing.s2),
                Text(
                  sub,
                  style: NegiluTypography.kannada(fontSize: 11.5, color: NegiluColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendList(List<String> crops) {
    if (_loadingAdvisories) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: NegiluColors.brandGreenDark)),
      );
    }

    return SizedBox(
      height: 205,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: crops.length,
        separatorBuilder: (_, _) => const SizedBox(width: NegiluSpacing.s14),
        itemBuilder: (context, index) {
          final crop = crops[index];
          final advisory = _advisories[crop];
          final knName = kannadaNameFor(crop);

          final hasData = advisory != null;
          final verdict = advisory?.actionVerdict ?? 'MONITOR';
          final vColor = _trendColor(verdict);
          final price = advisory?.currentPrice ?? 0;
          final forecast = advisory?.predictedPrice7Days ?? 0;

          return SizedBox(
            width: 215,
            child: Container(
              decoration: BoxDecoration(
                color: NegiluColors.surface,
                borderRadius: NegiluRadii.borderFull,
                border: Border.all(color: const Color(0xFFE8DFC8), width: 1.0),
                boxShadow: NegiluShadows.md,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: NegiluRadii.borderFull,
                  onTap: () => widget.onSearchCommodity(crop),
                  child: Padding(
                    padding: const EdgeInsets.all(NegiluSpacing.s14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CropThumbnail(
                              commodity: crop,
                              size: 44,
                              borderRadius: NegiluRadii.xl,
                            ),
                            const SizedBox(width: NegiluSpacing.s10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    crop,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: NegiluTypography.body(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  if (knName.isNotEmpty)
                                    Text(
                                      knName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: NegiluTypography.kannada(
                                        fontSize: 11.5,
                                        color: NegiluColors.brandGreenDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Price & Forecast
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${price.toStringAsFixed(0)}',
                              style: NegiluTypography.heading(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: NegiluColors.brandGreenDark,
                              ),
                            ),
                            const SizedBox(width: NegiluSpacing.s4),
                            Text(
                              '/ Quintal',
                              style: NegiluTypography.body(fontSize: 11, color: NegiluColors.textMuted),
                            ),
                          ],
                        ),
                        if (hasData && forecast > 0) ...[
                          const SizedBox(height: NegiluSpacing.s2),
                          Row(
                            children: [
                              Icon(
                                forecast >= price ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                size: 14,
                                color: forecast >= price ? NegiluColors.brandGreenDark : NegiluColors.brandWarmDark,
                              ),
                              const SizedBox(width: NegiluSpacing.s4),
                              Text(
                                '7D Est: ₹${forecast.toStringAsFixed(0)}',
                                style: NegiluTypography.body(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: forecast >= price ? NegiluColors.brandGreenDark : NegiluColors.brandWarmDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: NegiluSpacing.s10),

                        // Verdict Pill
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: NegiluSpacing.s5,
                            horizontal: NegiluSpacing.s8,
                          ),
                          decoration: BoxDecoration(
                            color: vColor.withValues(alpha: 0.12),
                            borderRadius: NegiluRadii.borderMd,
                            border: Border.all(color: vColor.withValues(alpha: 0.25), width: 0.8),
                          ),
                          child: Text(
                            advisory?.verdictBadgeTextKn ?? 'ದರ ಪರಿಶೀಲಿಸಿ',
                            textAlign: TextAlign.center,
                            style: NegiluTypography.kannada(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: vColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherMiniCard(BuildContext context) {
    if (_loadingWeather) {
      return Container(
        height: 64,
        decoration: BoxDecoration(
          color: NegiluColors.surface,
          borderRadius: NegiluRadii.borderFull,
          border: Border.all(color: const Color(0xFFE8DFC8)),
        ),
        child: const Center(child: CircularProgressIndicator(color: NegiluColors.brandGreenDark, strokeWidth: 2)),
      );
    }
    final weather = _weather;
    if (weather == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: NegiluColors.surface,
        borderRadius: NegiluRadii.borderFull,
        border: Border.all(color: const Color(0xFFE8DFC8), width: 1.0),
        boxShadow: NegiluShadows.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: NegiluRadii.borderFull,
          onTap: () => widget.onNavigateToTab(3),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NegiluSpacing.s14,
              vertical: NegiluSpacing.s10,
            ),
            child: Row(
              children: [
                Image.network(
                  weather.iconUrl,
                  width: 42,
                  height: 42,
                  errorBuilder: (_, _, _) => const Icon(Icons.wb_sunny_rounded, size: 34, color: NegiluColors.brandWarm),
                ),
                const SizedBox(width: NegiluSpacing.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${weather.locationName} • ಹವಾಮಾನ',
                        style: NegiluTypography.body(fontWeight: FontWeight.w700, fontSize: 13.5),
                      ),
                      Text(
                        weather.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NegiluTypography.body(color: NegiluColors.textMuted, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${weather.temperature.toStringAsFixed(0)}°C',
                  style: NegiluTypography.heading(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: NegiluColors.brandGreenDark,
                  ),
                ),
                const SizedBox(width: NegiluSpacing.s6),
                const Icon(Icons.chevron_right_rounded, size: 20, color: NegiluColors.brandGreenDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstitutionalCard() {
    return Container(
      padding: const EdgeInsets.all(NegiluSpacing.s18),
      decoration: BoxDecoration(
        color: NegiluColors.surface,
        borderRadius: NegiluRadii.borderFull,
        border: Border.all(color: const Color(0xFFE8DFC8)),
        boxShadow: NegiluShadows.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(NegiluSpacing.s10),
            decoration: const BoxDecoration(
              color: NegiluColors.brandGreenDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: NegiluSpacing.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Institutional Agricultural Intelligence (ವಿಶ್ವಾಸಾರ್ಹ ಕೃಷಿ ವೇದಿಕೆ)',
                  style: NegiluTypography.body(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: NegiluSpacing.s2),
                Text(
                  'Sourced daily from Agmarknet, KRAMA Karnataka Market Board, and IMD Weather Radar.',
                  style: NegiluTypography.body(fontSize: 12, color: NegiluColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
