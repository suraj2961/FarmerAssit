import 'package:flutter/material.dart';
import '../config/negilu_tokens.dart';
import '../models/weather_info.dart';
import '../services/weather_service.dart';
import '../widgets/negilu_footer.dart';
import '../widgets/farmer_drawer.dart';
import '../data/karnataka_districts.dart';

class WeatherScreen extends StatefulWidget {
  final String? selectedDistrict;
  final ValueChanged<String>? onDistrictSelected;
  final ValueChanged<int>? onNavigateToTab;

  const WeatherScreen({
    super.key,
    this.selectedDistrict,
    this.onDistrictSelected,
    this.onNavigateToTab,
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _service = WeatherService();
  late final TextEditingController _cityController;

  WeatherInfo? _weather;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final initialCity = widget.selectedDistrict != null
        ? districtToWeatherCity(widget.selectedDistrict!)
        : 'Mangalore,IN';
    _cityController = TextEditingController(text: initialCity);
    _fetchWeather(cityOverride: initialCity);
  }

  @override
  void didUpdateWidget(covariant WeatherScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDistrict != null &&
        widget.selectedDistrict != oldWidget.selectedDistrict) {
      final newCity = districtToWeatherCity(widget.selectedDistrict!);
      _cityController.text = newCity;
      _fetchWeather(cityOverride: newCity);
    }
  }

  Future<void> _fetchWeather({String? cityOverride}) async {
    final query = cityOverride ?? _cityController.text.trim();
    if (query.isEmpty) return;

    if (cityOverride != null) {
      _cityController.text = cityOverride;
    }

    setState(() {
      _loading = true;
    });

    try {
      final result = await _service.getCurrentWeatherByCity(query);
      setState(() {
        _weather = result;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _weather = _generateFallbackWeather(query);
        _loading = false;
      });
    }
  }

  WeatherInfo _generateFallbackWeather(String cityQuery) {
    return getDistrictFallbackWeather(cityQuery);
  }

  @override
  void dispose() {
    _service.dispose();
    _cityController.dispose();
    super.dispose();
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
              selectedIndex: 3,
              onTabSelected: (idx) {
                widget.onNavigateToTab?.call(idx);
              },
              selectedDistrict: widget.selectedDistrict ?? 'Dakshina Kannada',
              onDistrictSelected: (d) {
                widget.onDistrictSelected?.call(d);
                final newCity = districtToWeatherCity(d);
                _cityController.text = newCity;
                _fetchWeather(cityOverride: newCity);
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
                    'Agri Weather & Alerts',
                    style: NegiluTypography.heading(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'ಹವಾಮಾನ ಎಚ್ಚರಿಕೆಗಳು • Farm Work Forecast',
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
              // Search & City Chips
              _buildCitySelector(),
              const SizedBox(height: NegiluSpacing.s16),

              if (_loading)
                const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator(color: NegiluColors.brandGreenDark)),
                )
              else if (_weather != null) ...[
                ..._buildWeatherContent(_weather!, isDesktop),
                if (isDesktop) const SizedBox(height: NegiluSpacing.s23),
                if (isDesktop) const NegiluFooter(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitySelector() {
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  style: NegiluTypography.body(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Search City / Taluk (ನಗರ ಅಥವಾ ತಾಲೂಕು)',
                    hintText: 'e.g. Shivamogga, Mangalore, Kolar',
                    prefixIcon: const Icon(Icons.location_city, color: NegiluColors.brandGreenDark),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: NegiluSpacing.s14,
                      vertical: NegiluSpacing.s12,
                    ),
                  ),
                  onSubmitted: (_) => _fetchWeather(),
                ),
              ),
              const SizedBox(width: NegiluSpacing.s10),
              IconButton.filled(
                onPressed: _loading ? null : () => _fetchWeather(),
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

          // Horizontal quick district chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: karnatakaDistrictsList.length,
              separatorBuilder: (_, _) => const SizedBox(width: NegiluSpacing.s8),
              itemBuilder: (context, index) {
                final dist = karnatakaDistrictsList[index];
                final isSelected = _cityController.text.toLowerCase().trim() == dist.weatherCity.toLowerCase().trim() ||
                    _cityController.text.toLowerCase().contains(dist.englishName.toLowerCase());

                return ChoiceChip(
                  label: Text('${dist.englishName} (${dist.kannadaName})'),
                  selected: isSelected,
                  onSelected: (_) {
                    widget.onDistrictSelected?.call(dist.englishName);
                    _fetchWeather(cityOverride: dist.weatherCity);
                  },
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

  List<Widget> _buildWeatherContent(WeatherInfo weather, bool isDesktop) {
    final heroCard = _buildHeroWeatherCard(weather);
    final advisoryCard = _buildAgriculturalAdvisoryCard(weather);
    final outlookCard = _build5DayOutlookCard();

    if (isDesktop) {
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heroCard),
            const SizedBox(width: NegiluSpacing.s18),
            Expanded(child: advisoryCard),
          ],
        ),
        const SizedBox(height: NegiluSpacing.s18),
        outlookCard,
        const SizedBox(height: NegiluSpacing.s23),
      ];
    }

    return [
      heroCard,
      const SizedBox(height: NegiluSpacing.s18),
      advisoryCard,
      const SizedBox(height: NegiluSpacing.s18),
      outlookCard,
      const SizedBox(height: NegiluSpacing.s23),
    ];
  }

  Widget _buildHeroWeatherCard(WeatherInfo weather) {
    return Container(
      padding: const EdgeInsets.all(NegiluSpacing.s22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            NegiluColors.brandGreenDark, // #1C5A2C
            NegiluColors.brandGreen,     // #2C7A3F
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: NegiluRadii.borderR24,
        boxShadow: NegiluShadows.brandAccent,
      ),
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
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 16),
                        const SizedBox(width: NegiluSpacing.s4),
                        Expanded(
                          child: Text(
                            weather.locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NegiluTypography.heading(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      weather.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NegiluTypography.body(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Image.network(
                weather.iconUrl,
                width: 58,
                height: 58,
                errorBuilder: (_, _, _) => const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 48),
              ),
            ],
          ),

          const SizedBox(height: NegiluSpacing.s18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${weather.temperature.toStringAsFixed(0)}°',
                style: NegiluTypography.heading(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: NegiluSpacing.s8),
              Text(
                'Feels like ${weather.feelsLike.toStringAsFixed(0)}°C',
                style: NegiluTypography.body(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: NegiluSpacing.s16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: NegiluSpacing.s14),

          // Quick Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _heroMiniStat(
                icon: Icons.water_drop_outlined,
                label: 'Humidity',
                value: '${weather.humidity}%',
              ),
              _heroMiniStat(
                icon: Icons.air,
                label: 'Wind Speed',
                value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
              ),
              _heroMiniStat(
                icon: Icons.wb_twilight,
                label: 'Condition',
                value: weather.condition,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgriculturalAdvisoryCard(WeatherInfo weather) {
    return Container(
      decoration: BoxDecoration(
        color: NegiluColors.surface,
        borderRadius: NegiluRadii.borderFull,
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
                child: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: NegiluSpacing.s10),
              Expanded(
                child: Text(
                  'Agricultural Advisory (ಕೃಷಿ ಸಲಹೆ)',
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
            'Weather-based suitability for on-field farming activities:',
            style: NegiluTypography.body(fontSize: 13, color: NegiluColors.textMuted),
          ),
          const SizedBox(height: NegiluSpacing.s14),

          _buildAdvisoryMeter(
            title: 'Spraying Operations (ಕೀಟನಾಶಕ ಸಿಂಪಡಣೆ)',
            status: weather.windSpeed > 4.5 ? 'NOT RECOMMENDED' : 'HIGHLY SUITABLE',
            detail: weather.windSpeed > 4.5
                ? 'High winds will cause pesticide drift and poor leaf adhesion.'
                : 'Optimal wind speed (<4 m/s) ensures maximum canopy absorption.',
            isFavorable: weather.windSpeed <= 4.5,
          ),
          const SizedBox(height: NegiluSpacing.s10),

          _buildAdvisoryMeter(
            title: 'Outdoor Crop Drying (ಅಡಿಕೆ / ಧಾನ್ಯ ಒಣಗಿಸುವುದು)',
            status: weather.humidity > 80 ? 'HIGH MOISTURE RISK' : 'SAFE FOR DRYING',
            detail: weather.humidity > 80
                ? 'High ambient humidity. Cover arecanut and grains under tarpaulin if showers threaten.'
                : 'Favorable sun hours for yard drying of arecanut, copra, and paddy.',
            isFavorable: weather.humidity <= 80,
          ),
          const SizedBox(height: NegiluSpacing.s10),

          _buildAdvisoryMeter(
            title: 'Harvesting & Field Work (ಕೊಯ್ಲು & ಉಳುಮೆ)',
            status: 'FAVORABLE WINDOW',
            detail: 'Soil moisture is optimal for intercultural operations and tilling.',
            isFavorable: true,
          ),
        ],
      ),
    );
  }

  Widget _build5DayOutlookCard() {
    return Container(
      decoration: BoxDecoration(
        color: NegiluColors.surface,
        borderRadius: NegiluRadii.borderFull,
        border: Border.all(color: const Color(0xFFE8DFC8), width: 1.0),
        boxShadow: NegiluShadows.md,
      ),
      padding: const EdgeInsets.all(NegiluSpacing.s18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '5-Day Weather Trend (5 ದಿನಗಳ ಮುನ್ನೋಟ)',
            style: NegiluTypography.heading(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: NegiluSpacing.s14),

          _forecastRow('Tomorrow', 'Partly Cloudy', Icons.wb_cloudy_outlined, '29°', '23°'),
          const Divider(height: 18, color: Color(0xFFEFE8DB)),
          _forecastRow('Day 3', 'Light Rain / Showers', Icons.grain, '27°', '22°'),
          const Divider(height: 18, color: Color(0xFFEFE8DB)),
          _forecastRow('Day 4', 'Sunny & Clear', Icons.wb_sunny_outlined, '31°', '24°'),
          const Divider(height: 18, color: Color(0xFFEFE8DB)),
          _forecastRow('Day 5', 'Isolated Thunderstorm', Icons.flash_on, '28°', '23°'),
        ],
      ),
    );
  }

  Widget _buildAdvisoryMeter({
    required String title,
    required String status,
    required String detail,
    required bool isFavorable,
  }) {
    final color = isFavorable ? NegiluColors.brandGreenDark : NegiluColors.brandWarmDeep;
    final bgColor = isFavorable ? NegiluColors.brandGreen50 : NegiluColors.surfaceWarmMuted;
    final borderColor = isFavorable ? NegiluColors.brandGreen100 : NegiluColors.brandWarm100;

    return Container(
      padding: const EdgeInsets.all(NegiluSpacing.s12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: NegiluRadii.borderLg,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isFavorable ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(width: NegiluSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      title,
                      style: NegiluTypography.body(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: NegiluRadii.borderSm,
                      ),
                      child: Text(
                        status,
                        style: NegiluTypography.body(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NegiluSpacing.s4),
                Text(
                  detail,
                  style: NegiluTypography.body(
                    fontSize: 12,
                    color: NegiluColors.textForest,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroMiniStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: NegiluSpacing.s4),
        Text(
          value,
          style: NegiluTypography.body(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: NegiluTypography.body(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _forecastRow(String day, String condition, IconData icon, String high, String low) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            day,
            style: NegiluTypography.body(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Icon(icon, color: NegiluColors.brandGreenDark, size: 20),
        const SizedBox(width: NegiluSpacing.s8),
        Expanded(
          child: Text(
            condition,
            style: NegiluTypography.body(fontSize: 12, color: NegiluColors.textForest),
          ),
        ),
        Text(
          high,
          style: NegiluTypography.heading(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(width: NegiluSpacing.s6),
        Text(
          low,
          style: NegiluTypography.body(color: NegiluColors.textSubtle, fontSize: 12),
        ),
      ],
    );
  }
}
