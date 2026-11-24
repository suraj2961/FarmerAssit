import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/scheme.dart';
import '../services/scheme_service.dart';
import '../services/api_client.dart';
import '../widgets/negilu_footer.dart';
import '../widgets/farmer_drawer.dart';

class SchemesScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;
  final String? selectedDistrict;

  const SchemesScreen({
    super.key,
    this.onNavigateToTab,
    this.selectedDistrict,
  });

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  final SchemeService _service = SchemeService();
  List<Scheme> _schemes = [];
  bool _loading = false;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Income Support',
    'Farm Mechanisation',
    'Irrigation & Water Conservation',
    'Crop Insurance',
    'Credit & Loans',
  ];

  @override
  void initState() {
    super.initState();
    _fetchSchemes();
  }

  Future<void> _fetchSchemes() async {
    setState(() {
      _loading = true;
    });

    try {
      final results = await _service.fetchSchemes();
      setState(() {
        _schemes = results.isNotEmpty ? results : _fallbackSchemes();
        _loading = false;
      });
    } on ApiException catch (_) {
      setState(() {
        _schemes = _fallbackSchemes();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _schemes = _fallbackSchemes();
        _loading = false;
      });
    }
  }

  List<Scheme> _fallbackSchemes() {
    return [
      Scheme(
        id: 'pm-kisan',
        name: 'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)',
        category: 'Income Support',
        level: 'Central',
        description:
            'Direct income support scheme providing financial assistance to landholding farmer families across India.',
        eligibility: [
          'Indian citizen with cultivable land in the farmer family\'s name',
          'Land ownership verified in RTC/Pahani records',
          'Mandatory Aadhaar eKYC linkage with bank account',
        ],
        benefits: [
          '₹6,000 per year in 3 equal installments of ₹2,000 every 4 months',
          'Direct Benefit Transfer (DBT) directly into bank account',
          'Automatic eligibility pathway for Kisan Credit Card (KCC)',
        ],
        applicationLink: 'https://pmkisan.gov.in',
        applicationProcess:
            'Register online at pmkisan.gov.in under "Farmers Corner" or through local CSC / Raitha Samparka Kendra.',
      ),
      Scheme(
        id: 'krishi-bhagya',
        name: 'Krishi Bhagya Yojana (ಕೃಷಿ ಭಾಗ್ಯ)',
        category: 'Irrigation & Water Conservation',
        level: 'Karnataka State',
        description:
            'Karnataka flagship rainwater harvesting and farm pond (Krishi Honda) initiative for dryland and coastal farmers.',
        eligibility: [
          'Karnataka resident farmer with at least 1 acre cultivable land',
          'Targeted at dryland and rain-dependent agricultural plots',
        ],
        benefits: [
          '80% to 90% subsidy for constructing farm pond (Krishi Honda)',
          '50% subsidy for polyhouse and shade net installations',
          'Subsidies for lift irrigation pump sets and diesel motors',
        ],
        applicationLink: 'https://raitamitra.karnataka.gov.in',
        applicationProcess:
            'Apply via FRUITS portal or visit your nearest Raitha Samparka Kendra (RSK).',
      ),
      Scheme(
        id: 'krishi-yantra-dhare',
        name: 'Krishi Yantra Dhare (ಕೃಷಿ ಯಂತ್ರಧಾರೆ)',
        category: 'Farm Mechanisation',
        level: 'Karnataka State',
        description:
            'Enables small and marginal farmers to hire modern farm machinery at heavily subsidized rental prices.',
        eligibility: [
          'Karnataka small and marginal landholding farmers',
          'Farmers who cannot afford expensive heavy farm machinery',
        ],
        benefits: [
          'Subsidized tractor, power tiller, and harvester rentals (₹200–₹1,500/acre vs ₹3,500+ private rate)',
          '500+ Custom Hiring Centres (CHCs) active across Karnataka',
        ],
        applicationLink: 'https://yantradhare.karnataka.gov.in',
        applicationProcess:
            'Book machinery through Yantra Karnataka app or local RSK centre.',
      ),
      Scheme(
        id: 'pmfby',
        name: 'PMFBY (Pradhan Mantri Fasal Bima Yojana)',
        category: 'Crop Insurance',
        level: 'Central',
        description:
            'Comprehensive crop insurance scheme protecting farmers against drought, flood, pests, and unseasonal rainfall.',
        eligibility: [
          'Farmers cultivating notified crops in notified taluks/panchayats',
          'Both owner farmers and tenant/sharecroppers eligible',
        ],
        benefits: [
          'Low premium: 2% for Kharif, 1.5% for Rabi, 5% for commercial/horticultural crops',
          'Up to 100% loss compensation credited via DBT',
        ],
        applicationLink: 'https://pmfby.gov.in',
        applicationProcess:
            'Apply through pmfby.gov.in, Samrakshane portal, or local commercial/Grameena bank branch.',
      ),
    ];
  }

  List<Scheme> get _filteredSchemes {
    if (_selectedCategory == 'All') return _schemes;
    return _schemes.where((s) => s.category == _selectedCategory).toList();
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSchemes;
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;

    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      drawer: isDesktop
          ? null
          : FarmerDrawer(
              selectedIndex: 4,
              onTabSelected: (idx) => widget.onNavigateToTab?.call(idx),
              selectedDistrict: widget.selectedDistrict ?? 'Dakshina Kannada',
            ),
      appBar: (isDesktop && !canPop)
          ? null
          : AppBar(
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
                    'Govt Schemes & Subsidies',
                    style: GoogleFonts.bricolageGrotesque(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು & ಸಹಾಯಧನ • Farmer Welfare',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
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
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            children: [
              // Categories horizontal bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final selected = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                        selectedColor: const Color(0xFF1C5A2C),
                        labelStyle: GoogleFonts.manrope(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: selected ? const Color(0xFF1C5A2C) : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      );
                    },
                  ),
                ),
              ),

              // Schemes list
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF1C5A2C)))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isMultiCol = constraints.maxWidth >= 768;
                          if (!isMultiCol) {
                            return RefreshIndicator(
                              onRefresh: _fetchSchemes,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                itemCount: filtered.length + (isDesktop ? 1 : 0),
                                separatorBuilder: (_, _) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  if (isDesktop && index == filtered.length) {
                                    return const Padding(
                                      padding: EdgeInsets.only(top: 24),
                                      child: NegiluFooter(),
                                    );
                                  }
                                  return _buildSchemeCard(filtered[index]);
                                },
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: _fetchSchemes,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              children: [
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    mainAxisExtent: 260,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) => _buildSchemeCard(filtered[index]),
                                ),
                                if (isDesktop)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 24),
                                    child: NegiluFooter(),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchemeCard(Scheme scheme) {
    final isState = scheme.level.contains('Karnataka');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isState ? const Color(0xFFFEF3C7) : const Color(0xFFEAF5ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isState ? Icons.account_balance : Icons.flag,
              color: isState ? const Color(0xFFB45309) : const Color(0xFF1C5A2C),
              size: 24,
            ),
          ),
          title: Text(
            scheme.name,
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isState ? const Color(0xFFFFFBEB) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isState ? const Color(0xFFFDE68A) : const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: Text(
                    scheme.level,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isState ? const Color(0xFF92400E) : const Color(0xFF1E40AF),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    scheme.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  scheme.description,
                  style: GoogleFonts.manrope(fontSize: 13.5, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 14),

                // Eligibility
                Text(
                  'Eligibility Requirements (ಅರ್ಹತೆಗಳು):',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                ...scheme.eligibility.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Color(0xFF16A34A)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(e, style: GoogleFonts.manrope(fontSize: 12.5)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Benefits
                Text(
                  'Financial Benefits & Subsidies (ಸಹಾಯಧನ & ಲಾಭಗಳು):',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                ...scheme.benefits.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.star, size: 16, color: Color(0xFFD97706)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(b, style: GoogleFonts.manrope(fontSize: 12.5)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Application Process
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAF9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to Apply (ಅರ್ಜಿ ಸಲ್ಲಿಸುವುದು ಹೇಗೆ):',
                        style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scheme.applicationProcess,
                        style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openLink(scheme.applicationLink),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Visit Official Scheme Portal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C5A2C),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}