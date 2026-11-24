import 'package:flutter/material.dart';
import '../config/negilu_tokens.dart';

class NegiluFooter extends StatelessWidget {
  final ValueChanged<int>? onNavigate;

  const NegiluFooter({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: NegiluColors.textPrimary, // #13231B Deep Negilu dark tone
      padding: const EdgeInsets.symmetric(
        vertical: NegiluSpacing.s22,
        horizontal: NegiluSpacing.s19,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Brand & Mission + Links
              Wrap(
                spacing: 40,
                runSpacing: 24,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  // Brand column
                  SizedBox(
                    width: 320,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(NegiluSpacing.s8),
                              decoration: const BoxDecoration(
                                color: NegiluColors.brandGreen, // #2C7A3F
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.agriculture, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: NegiluSpacing.s10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ನೇಗಿಲು (Negilu)',
                                  style: NegiluTypography.heading(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'FarmerAssist • ಕೃಷಿ ವೇದಿಕೆ',
                                  style: NegiluTypography.body(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: NegiluSpacing.s12),
                        Text(
                          'ಕರ್ನಾಟಕದ ರೈತ ಬಾಂಧವರಿಗಾಗಿ ನಿಖರವಾದ ಮಾರುಕಟ್ಟೆ ದರಗಳು, ಎಂಎಲ್ ಮಾರಾಟ ಸಲಹೆ, ಹವಾಮಾನ ಎಚ್ಚರಿಕೆ ಮತ್ತು ಸರ್ಕಾರಿ ಯೋಜನೆಗಳ ಡಿಜಿಟಲ್ ವೇದಿಕೆ.',
                          style: NegiluTypography.body(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Links
                  _footerLinkGroup(
                    title: 'ಕೃಷಿ ಸೇವೆಗಳು (Services)',
                    links: [
                      _LinkItem('ಮಾರುಕಟ್ಟೆ ದರಗಳು (Mandi Prices)', 1),
                      _LinkItem('ಮಾರಾಟ ಸಲಹೆ (ML Sell Advisory)', 2),
                      _LinkItem('ಹವಾಮಾನ ಎಚ್ಚರಿಕೆಗಳು (Weather)', 3),
                      _LinkItem('ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು (Schemes)', 4),
                      _LinkItem('ಕೃಷಿ ವಿಡಿಯೋಗಳು (Videos)', 5),
                    ],
                  ),

                  // Data Sources
                  SizedBox(
                    width: 260,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ಮಾಹಿತಿ ಮೂಲಗಳು (Data Sources)',
                          style: NegiluTypography.body(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: NegiluSpacing.s10),
                        _sourceItem('Agmarknet (data.gov.in)'),
                        _sourceItem('KRAMA (Karnataka Market Board)'),
                        _sourceItem('OpenWeatherMap & IMD'),
                        _sourceItem('Karnataka Raitha Mitra'),
                        const SizedBox(height: NegiluSpacing.s10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: NegiluSpacing.s10,
                            vertical: NegiluSpacing.s6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: NegiluRadii.borderLg,
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            'ನೇಗಿಲು ಒಂದು ಸ್ವತಂತ್ರ ಕೃಷಿ ಮಾಹಿತಿ ವೇದಿಕೆ',
                            style: NegiluTypography.body(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: NegiluSpacing.s20),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: NegiluSpacing.s14),

              // Disclaimers (Exact Negilu Krishi style)
              Text(
                'ದರಗಳು ಸಾರ್ವಜನಿಕ ಮಂಡಿ ಮಾಹಿತಿಯಿಂದ ಸೂಚಕ ಮಾತ್ರ — ವ್ಯಾಪಾರಕ್ಕೆ ಮುನ್ನ ಪರಿಶೀಲಿಸಿ. ನೇಗಿಲು ಸ್ವತಂತ್ರ ಆ್ಯಪ್ — ಸರ್ಕಾರಿ ಜಾಲತಾಣ ಅಲ್ಲ.',
                style: NegiluTypography.body(color: Colors.white38, fontSize: 11.5, height: 1.4),
              ),
              const SizedBox(height: NegiluSpacing.s10),

              // Bottom Disclaimer & Copyright
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2026 Negilu · ಅಭಿವೃದ್ಧಿಪಡಿಸಿದವರು FarmerAssist',
                    style: NegiluTypography.body(color: Colors.white54, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: NegiluColors.surfaceGreenMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: NegiluSpacing.s6),
                      Text(
                        'ಕರ್ನಾಟಕದ ರೈತರಿಗಾಗಿ 🌱',
                        style: NegiluTypography.body(
                          color: NegiluColors.surfaceGreenMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLinkGroup({
    required String title,
    required List<_LinkItem> links,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: NegiluTypography.body(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: NegiluSpacing.s10),
        ...links.map(
          (l) => Padding(
            padding: const EdgeInsets.only(bottom: NegiluSpacing.s6),
            child: InkWell(
              onTap: () => onNavigate?.call(l.index),
              child: Text(
                l.title,
                style: NegiluTypography.body(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sourceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NegiluSpacing.s4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 14, color: NegiluColors.surfaceGreenMuted),
          const SizedBox(width: NegiluSpacing.s6),
          Text(
            text,
            style: NegiluTypography.body(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LinkItem {
  final String title;
  final int index;
  _LinkItem(this.title, this.index);
}
