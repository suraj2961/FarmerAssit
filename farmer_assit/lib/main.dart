import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/mandi_prices_screen.dart';
import 'screens/crop_advisory_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/schemes_screen.dart';
import 'screens/news_screen.dart';
import 'widgets/negilu_desktop_header.dart';
import 'data/karnataka_districts.dart';
import 'config/negilu_tokens.dart';
import 'config/negilu_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FarmerAssistApp());
}

class FarmerAssistApp extends StatelessWidget {
  const FarmerAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ನೇಗಿಲು (Negilu) • FarmerAssist',
      debugShowCheckedModeBanner: false,
      theme: NegiluTheme.lightTheme,
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  String _selectedDistrict = 'Dakshina Kannada';
  String? _pendingCommoditySearch;

  // History stack for menu navigation (forward & backward arrows)
  final List<int> _navHistory = [0];
  int _historyIndex = 0;

  // Lazy tab loading: only instantiate tabs once visited to keep startup instant
  final Set<int> _loadedTabs = {0};

  bool get _canGoBack => _historyIndex > 0;
  bool get _canGoForward => _historyIndex < _navHistory.length - 1;

  void _onTabSelected(int index, {bool recordHistory = true}) {
    _loadedTabs.add(index);
    if (recordHistory && index != _selectedIndex) {
      if (_historyIndex < _navHistory.length - 1) {
        _navHistory.removeRange(_historyIndex + 1, _navHistory.length);
      }
      _navHistory.add(index);
      _historyIndex = _navHistory.length - 1;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goBack() {
    if (_canGoBack) {
      setState(() {
        _historyIndex--;
        _selectedIndex = _navHistory[_historyIndex];
      });
    }
  }

  void _goForward() {
    if (_canGoForward) {
      setState(() {
        _historyIndex++;
        _selectedIndex = _navHistory[_historyIndex];
      });
    }
  }

  void _onDistrictChanged(String district) {
    setState(() {
      _selectedDistrict = cleanDistrictName(district);
    });
  }

  void _searchCommodity(String commodity) {
    _pendingCommoditySearch = commodity;
    _onTabSelected(1); // Jump to Mandi tab with history entry
  }

  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderR18),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(NegiluSpacing.s6),
              decoration: const BoxDecoration(
                color: NegiluColors.brandGreenDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.agriculture, color: Colors.white, size: 20),
            ),
            const SizedBox(width: NegiluSpacing.s10),
            Text(
              'ನೇಗಿಲು (Negilu) • ಮಾರ್ಗದರ್ಶಿ',
              style: NegiluTypography.heading(fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _guideStep('1', 'ಮಾರುಕಟ್ಟೆ ದರಗಳು (Mandi Rates)',
                  'ಕರ್ನಾಟಕದ ಎಲ್ಲಾ APMC ಮಂಡಿಗಳ ಇಂದಿನ ಕನಿಷ್ಠ, ಗರಿಷ್ಠ ಮತ್ತು ಮಾದರಿ ದರಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.'),
              _guideStep('2', 'ಮಾರಾಟ ಸಲಹೆ • ML Engine (Sell Advisory)',
                  'ಹಿಂದಿನ ಮಾರುಕಟ್ಟೆ ಪರಿಸ್ಥಿತಿ, ಬೆಲೆಯ ಏರಿಳಿತ, ಕೊಳೆಯುವ ಅಪಾಯವನ್ನು ವಿಶ್ಲೇಷಿಸಿ ಯಾವಾಗ ಮಾರಾಟ ಮಾಡಬೇಕೆಂದು ಸ್ಪಷ್ಟ ಸಲಹೆ ಪಡೆಯಿರಿ.'),
              _guideStep('3', 'ಹವಾಮಾನ ಎಚ್ಚರಿಕೆ (Agri Weather)',
                  'ಕೀಟನಾಶಕ ಸಿಂಪಡಣೆ, ಅಡಿಕೆ/ಕಾಳು ಒಣಗಿಸುವಿಕೆ ಮತ್ತು ಕೊಯ್ಲಿಗೆ ಹವಾಮಾನ ಸೂಕ್ತವೇ ಎಂಬುದನ್ನು ತಿಳಿಯಿರಿ.'),
              _guideStep('4', 'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು (Schemes)',
                  'ಪಿಎಂ-ಕಿಸಾನ್, ಕೃಷಿ ಭಾಗ್ಯ, ಯಂತ್ರಧಾರೆ ಮೊದಲಾದ ಯೋಜನೆಗಳ ಸಬ್ಸಿಡಿ ಹಾಗೂ ನೇರ ಅರ್ಜಿ ಲಿಂಕ್‌ಗಳು.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ತಿಳಿಯಿತು (Understood)'),
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

    final screens = [
      HomeScreen(
        selectedDistrict: _selectedDistrict,
        onDistrictSelected: _onDistrictChanged,
        onNavigateToTab: _onTabSelected,
        onSearchCommodity: _searchCommodity,
      ),
      _loadedTabs.contains(1)
          ? MandiPricesScreen(
              key: ValueKey('mandi_${_selectedDistrict}_$_pendingCommoditySearch'),
              selectedDistrict: _selectedDistrict,
              onDistrictSelected: _onDistrictChanged,
              onNavigateToTab: _onTabSelected,
              initialCommodity: _pendingCommoditySearch,
            )
          : const SizedBox.shrink(),
      _loadedTabs.contains(2)
          ? CropAdvisoryScreen(
              selectedDistrict: _selectedDistrict,
              onDistrictSelected: _onDistrictChanged,
              onNavigateToTab: _onTabSelected,
            )
          : const SizedBox.shrink(),
      _loadedTabs.contains(3)
          ? WeatherScreen(
              selectedDistrict: _selectedDistrict,
              onDistrictSelected: _onDistrictChanged,
              onNavigateToTab: _onTabSelected,
            )
          : const SizedBox.shrink(),
      _loadedTabs.contains(4)
          ? SchemesScreen(
              onNavigateToTab: _onTabSelected,
              selectedDistrict: _selectedDistrict,
            )
          : const SizedBox.shrink(),
      _loadedTabs.contains(5)
          ? NewsScreen(
              onNavigateToTab: _onTabSelected,
              selectedDistrict: _selectedDistrict,
            )
          : const SizedBox.shrink(),
    ];

    if (isDesktop) {
      // DESKTOP SITE (Negilu Krishi PC Browser Style):
      return PopScope(
        canPop: !_canGoBack,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_canGoBack) {
            _goBack();
          }
        },
        child: Scaffold(
          body: Column(
            children: [
              NegiluDesktopHeader(
                selectedIndex: _selectedIndex,
                onTabSelected: _onTabSelected,
                selectedDistrict: _selectedDistrict,
                onDistrictSelected: _onDistrictChanged,
                onShowGuide: () => _showGuideDialog(context),
                canGoBack: _canGoBack,
                canGoForward: _canGoForward,
                onBack: _goBack,
                onForward: _goForward,
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: screens,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // MOBILE PHONE VIEW:
    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_canGoBack) {
          _goBack();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex.clamp(0, 4),
          onDestinationSelected: (idx) {
            if (idx == 4) {
              // Show more menu
              _showMobileMoreSheet(context);
            } else {
              _onTabSelected(idx);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'ಮುಖಪುಟ',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'ದರಗಳು',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'ಸಲಹೆ (AI)',
            ),
            NavigationDestination(
              icon: Icon(Icons.wb_sunny_outlined),
              selectedIcon: Icon(Icons.wb_sunny),
              label: 'ಹವಾಮಾನ',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'ಇನ್ನಷ್ಟು',
            ),
          ],
        ),
      ),
    );
  }

  void _showMobileMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(NegiluRadii.r18)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: NegiluSpacing.s18,
          horizontal: NegiluSpacing.s16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ಹೆಚ್ಚಿನ ಸೇವೆಗಳು (More Services)',
              style: NegiluTypography.heading(fontSize: 18),
            ),
            const SizedBox(height: NegiluSpacing.s12),
            ListTile(
              leading: const Icon(Icons.account_balance, color: NegiluColors.brandWarmDark),
              title: Text('ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು (Govt Schemes)', style: NegiluTypography.body(fontWeight: FontWeight.w700, fontSize: 13)),
              subtitle: Text('ಪಿಎಂ-ಕಿಸಾನ್, ಕೃಷಿ ಭಾಗ್ಯ, ಯಂತ್ರಧಾರೆ ಸಹಾಯಧನ', style: NegiluTypography.body(fontSize: 12, color: NegiluColors.textMuted)),
              trailing: const Icon(Icons.chevron_right, color: NegiluColors.textMuted),
              onTap: () {
                Navigator.pop(ctx);
                _onTabSelected(4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_filled, color: NegiluColors.brandWarm),
              title: Text('ಕೃಷಿ ವಿಡಿಯೋ & ವಾರ್ತೆ (News & Videos)', style: NegiluTypography.body(fontWeight: FontWeight.w700, fontSize: 13)),
              subtitle: Text('ಅಡಿಕೆ, ತೋಟಗಾರಿಕೆ, ನೈಸರ್ಗಿಕ ಕೃಷಿ ವಿಡಿಯೋಗಳು', style: NegiluTypography.body(fontSize: 12, color: NegiluColors.textMuted)),
              trailing: const Icon(Icons.chevron_right, color: NegiluColors.textMuted),
              onTap: () {
                Navigator.pop(ctx);
                _onTabSelected(5);
              },
            ),
          ],
        ),
      ),
    );
  }
}
