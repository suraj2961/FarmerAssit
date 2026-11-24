import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/negilu_tokens.dart';
import '../data/karnataka_districts.dart';

class FarmerDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final String selectedDistrict;
  final ValueChanged<String>? onDistrictSelected;
  final VoidCallback? onShowGuide;

  const FarmerDrawer({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.selectedDistrict,
    this.onDistrictSelected,
    this.onShowGuide,
  });

  void _showDistrictDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderR18),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: NegiluColors.brandGreenDark),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'ಜಿಲ್ಲೆ ಆಯ್ಕೆಮಾಡಿ (Select District)',
                style: NegiluTypography.heading(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 380,
          child: ListView.separated(
            itemCount: karnatakaDistrictsList.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final d = karnatakaDistrictsList[i];
              final isCurrent = d.englishName.toLowerCase() == selectedDistrict.toLowerCase();
              return ListTile(
                dense: true,
                selected: isCurrent,
                selectedTileColor: NegiluColors.brandGreen50,
                shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderLg),
                title: Text(
                  '${d.kannadaName} (${d.englishName})',
                  style: NegiluTypography.body(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    color: isCurrent ? NegiluColors.brandGreenDark : NegiluColors.textPrimary,
                  ),
                ),
                trailing: isCurrent
                    ? const Icon(Icons.check_circle, color: NegiluColors.brandGreenDark, size: 20)
                    : null,
                onTap: () {
                  Navigator.of(ctx).pop();
                  onDistrictSelected?.call(d.englishName);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ಮುಚ್ಚಿ (Close)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: NegiluColors.bg,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // 1. Executive Brand Drawer Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 48,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: NegiluColors.brandGreenDark,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              'assets/images/app_logo_icon.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ನೇಗಿಲು ಕೃಷಿ',
                              style: NegiluTypography.heading(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Negilu Krishi • FarmerAssist',
                              style: NegiluTypography.body(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // District Selector Button
                  InkWell(
                    onTap: () => _showDistrictDialog(context),
                    borderRadius: NegiluRadii.borderFull,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: NegiluRadii.borderFull,
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: NegiluColors.brandWarm100, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'ಜಿಲ್ಲೆ: $selectedDistrict',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: NegiluTypography.body(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                          const Text(
                            'ಬದಲಾಯಿಸಿ ▼',
                            style: TextStyle(
                              color: NegiluColors.brandWarm100,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Navigation List (Big, high-contrast touch targets for farmers)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                children: [
                  _drawerTile(
                    context,
                    index: 0,
                    icon: Icons.home_rounded,
                    title: 'ಮುಖಪುಟ (Home)',
                    subtitle: 'ಕೃಷಿ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ & ತ್ವರಿತ ಸೇವೆಗಳು',
                  ),
                  _drawerTile(
                    context,
                    index: 1,
                    icon: Icons.storefront_rounded,
                    title: 'ಮಾರುಕಟ್ಟೆ ದರಗಳು (APMC Mandi)',
                    subtitle: 'ಕರ್ನಾಟಕದ ಎಲ್ಲಾ ಮಂಡಿಗಳ ಇಂದಿನ ದರ',
                  ),
                  _drawerTile(
                    context,
                    index: 2,
                    icon: Icons.insights_rounded,
                    title: 'ಮಾರಾಟ ಸಲಹೆ • ML Engine',
                    subtitle: 'ಕೃತಕ ಬುದ್ಧಿಮತ್ತೆ (AI) ಬೆಲೆ ಮುನ್ಸೂಚನೆ',
                  ),
                  _drawerTile(
                    context,
                    index: 3,
                    icon: Icons.wb_sunny_rounded,
                    title: 'ಕೃಷಿ ಹವಾಮಾನ (Agri Weather)',
                    subtitle: 'ಸಿಂಪಡಣೆ, ಒಣಗಿಸುವಿಕೆ & ಕೊಯ್ಲು ಸಲಹೆ',
                  ),
                  _drawerTile(
                    context,
                    index: 4,
                    icon: Icons.account_balance_rounded,
                    title: 'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು (Govt Schemes)',
                    subtitle: 'ಸಬ್ಸಿಡಿಗಳು, ಯಂತ್ರಧಾರೆ & ಸಾಲ ಸೌಲಭ್ಯ',
                  ),
                  _drawerTile(
                    context,
                    index: 5,
                    icon: Icons.newspaper_rounded,
                    title: 'ಕೃಷಿ ವಾರ್ತೆಗಳು (Agri News)',
                    subtitle: 'ಕೃಷಿ ವಿಶ್ವವಿದ್ಯಾಲಯ & ಸಂಶೋಧನಾ ವರದಿಗಳು',
                  ),

                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE2D6C3)),
                  const SizedBox(height: 8),

                  // 3. Farmer Toll-Free Helpline Card (Crucial for cognitive accessibility)
                  InkWell(
                    onTap: () async {
                      final uri = Uri.parse('tel:18001801551');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    borderRadius: NegiluRadii.borderLg,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NegiluColors.brandWarm50,
                        borderRadius: NegiluRadii.borderLg,
                        border: Border.all(color: NegiluColors.brandWarm100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.support_agent_rounded, color: NegiluColors.brandWarmDark, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ಕಿಸಾನ್ ಸಹಾಯವಾಣಿ (Toll-Free)',
                                  style: NegiluTypography.body(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: NegiluColors.brandWarmDeep,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '1800-180-1551',
                                style: NegiluTypography.heading(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: NegiluColors.brandWarmDark,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: NegiluColors.brandGreenDark,
                                  borderRadius: NegiluRadii.borderFull,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone_in_talk, size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ಕರೆ ಮಾಡಿ',
                                      style: NegiluTypography.body(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ಬೆಳಿಗ್ಗೆ 6:00 ರಿಂದ ರಾತ್ರಿ 10:00 (ಕನ್ನಡದಲ್ಲೇ ಉಚಿತ ಮಾಹಿತಿ)',
                            style: NegiluTypography.body(
                              fontSize: 11,
                              color: NegiluColors.textForest,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Guide Button
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: NegiluColors.brandGreenDark),
                    title: Text(
                      'ಮಾರ್ಗದರ್ಶಿ (How It Works)',
                      style: NegiluTypography.body(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderLg),
                    onTap: () {
                      Navigator.of(context).pop();
                      onShowGuide?.call();
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: NegiluRadii.borderLg,
                child: Image.asset(
                  'assets/images/app_logo.png',
                  height: 55,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 4. Subtle Negilu Trust Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: NegiluColors.surfaceWarmMuted,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified, size: 14, color: NegiluColors.brandGreenDark),
                  const SizedBox(width: 6),
                  Text(
                    'ನೇಗಿಲು ಕೃಷಿ ವೇದಿಕೆ • 100% ಉಚಿತ ರೈತ ಸೇವೆ',
                    style: NegiluTypography.body(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: NegiluColors.brandGreenDark,
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

  Widget _drawerTile(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected ? NegiluColors.brandGreenDark : Colors.transparent,
        borderRadius: NegiluRadii.borderLg,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : NegiluColors.brandGreenDark,
          size: 22,
        ),
        title: Text(
          title,
          style: NegiluTypography.body(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            fontSize: 13.5,
            color: isSelected ? Colors.white : NegiluColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: NegiluTypography.body(
            fontSize: 11,
            color: isSelected ? Colors.white70 : NegiluColors.textMuted,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white)
            : null,
        onTap: () {
          Navigator.of(context).pop();
          onTabSelected(index);
        },
      ),
    );
  }
}
