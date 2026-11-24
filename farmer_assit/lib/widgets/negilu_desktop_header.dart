import 'package:flutter/material.dart';
import '../config/negilu_tokens.dart';
import '../data/karnataka_districts.dart';

class NegiluDesktopHeader extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final String selectedDistrict;
  final ValueChanged<String> onDistrictSelected;
  final VoidCallback onShowGuide;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback? onBack;
  final VoidCallback? onForward;

  const NegiluDesktopHeader({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.selectedDistrict,
    required this.onDistrictSelected,
    required this.onShowGuide,
    this.canGoBack = false,
    this.canGoForward = false,
    this.onBack,
    this.onForward,
  });

  @override
  Widget build(BuildContext context) {
    final cleanDistrict = cleanDistrictName(selectedDistrict);

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: NegiluSpacing.s18),
      decoration: const BoxDecoration(
        color: NegiluColors.brandGreenDark, // #1C5A2C
        boxShadow: NegiluShadows.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            children: [
              // 1. Brand Logo & Title (Negilu Krishi)
              InkWell(
                onTap: () => onTabSelected(0),
                borderRadius: NegiluRadii.borderFull,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NegiluSpacing.s6,
                    vertical: NegiluSpacing.s4,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(NegiluSpacing.s7),
                        decoration: BoxDecoration(
                          color: NegiluColors.surface,
                          borderRadius: NegiluRadii.borderXl,
                          boxShadow: NegiluShadows.md,
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: NegiluColors.brandGreenDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: NegiluSpacing.s10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ನೇಗಿಲು',
                                style: NegiluTypography.heading(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: NegiluSpacing.s6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: NegiluSpacing.s6,
                                  vertical: NegiluSpacing.s2,
                                ),
                                decoration: BoxDecoration(
                                  color: NegiluColors.brandWarm, // #C2562B Terracotta accent
                                  borderRadius: NegiluRadii.borderMd,
                                ),
                                child: Text(
                                  'KRISHI',
                                  style: NegiluTypography.body(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'FarmerAssist • ಕೃಷಿ ವೇದಿಕೆ',
                            style: NegiluTypography.body(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: NegiluSpacing.s14),

              // 2. Interactive Navigation Arrows (Back & Forward between menus)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: NegiluRadii.borderXl,
                ),
                padding: const EdgeInsets.all(NegiluSpacing.s2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 15),
                      color: canGoBack ? Colors.white : Colors.white30,
                      tooltip: canGoBack ? 'ಹಿಂದಿನ ಮೆನು (Previous Menu)' : 'No previous menu',
                      onPressed: canGoBack ? onBack : null,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(NegiluSpacing.s6),
                      constraints: const BoxConstraints(),
                    ),
                    Container(width: 1, height: 16, color: Colors.white24),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 15),
                      color: canGoForward ? Colors.white : Colors.white30,
                      tooltip: canGoForward ? 'ಮುಂದಿನ ಮೆನು (Next Menu)' : 'No forward menu',
                      onPressed: canGoForward ? onForward : null,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(NegiluSpacing.s6),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: NegiluSpacing.s16),

              // 3. Desktop Navigation Menu Links
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _navLink(0, 'ಮುಖಪುಟ', 'Home'),
                      const SizedBox(width: NegiluSpacing.s4),
                      _navLink(1, 'ದರಗಳು', 'Mandi Prices'),
                      const SizedBox(width: NegiluSpacing.s4),
                      _navLink(2, 'ಮಾರಾಟ ಸಲಹೆ', 'Sell Advisory', isHighlight: true),
                      const SizedBox(width: NegiluSpacing.s4),
                      _navLink(3, 'ಹವಾಮಾನ', 'Weather'),
                      const SizedBox(width: NegiluSpacing.s4),
                      _navLink(4, 'ಯೋಜನೆಗಳು', 'Schemes'),
                      const SizedBox(width: NegiluSpacing.s4),
                      _navLink(5, 'ವಿಡಿಯೋ & ಸುದ್ದಿ', 'News'),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: NegiluSpacing.s12),

              // 4. Right Tools: District Selector & Help Button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // District Pill Selector
                  PopupMenuButton<String>(
                    tooltip: 'Change District • ಜಿಲ್ಲೆ ಬದಲಾಯಿಸಿ',
                    position: PopupMenuPosition.under,
                    shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderFull),
                    onSelected: onDistrictSelected,
                    itemBuilder: (context) {
                      return karnatakaDistrictsList.map((d) {
                        final isCurrent = d.englishName.toLowerCase() == cleanDistrict.toLowerCase();
                        return PopupMenuItem(
                          value: d.englishName,
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: isCurrent ? NegiluColors.brandGreenDark : NegiluColors.textMuted,
                              ),
                              const SizedBox(width: NegiluSpacing.s8),
                              Expanded(
                                child: Text(
                                  d.displayName,
                                  style: NegiluTypography.body(
                                    fontSize: 13,
                                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                                    color: isCurrent ? NegiluColors.brandGreenDark : NegiluColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                const Icon(Icons.check, size: 16, color: NegiluColors.brandGreenDark),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: NegiluSpacing.s12,
                        vertical: NegiluSpacing.s7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: NegiluRadii.borderCircular,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: NegiluColors.surfaceGreenMuted, size: 16),
                          const SizedBox(width: NegiluSpacing.s6),
                          Text(
                            cleanDistrict,
                            style: NegiluTypography.body(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: NegiluSpacing.s4),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: NegiluSpacing.s10),

                  // Help guide button
                  IconButton(
                    onPressed: onShowGuide,
                    tooltip: 'How to use Negilu Krishi',
                    icon: Container(
                      padding: const EdgeInsets.all(NegiluSpacing.s6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.help_outline, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLink(int index, String knLabel, String enLabel, {bool isHighlight = false}) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: NegiluRadii.borderXl,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: NegiluSpacing.s11,
          vertical: NegiluSpacing.s7,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.18)
              : (isHighlight ? NegiluColors.brandGreen.withValues(alpha: 0.35) : Colors.transparent),
          borderRadius: NegiluRadii.borderXl,
          border: isSelected
              ? Border.all(color: Colors.white38)
              : (isHighlight ? Border.all(color: NegiluColors.brandWarm.withValues(alpha: 0.6)) : null),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  knLabel,
                  style: NegiluTypography.kannada(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (isHighlight) ...[
                  const SizedBox(width: NegiluSpacing.s4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: NegiluColors.brandWarm,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              enLabel,
              style: NegiluTypography.body(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
