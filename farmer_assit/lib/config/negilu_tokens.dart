import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Negilu Design System Tokens
/// Extracted from https://negilukrishi.in/
class NegiluColors {
  NegiluColors._();

  // Backgrounds
  static const Color bg = Color(0xFFF0E5D6);       // --bg
  static const Color bgAlt = Color(0xFFF1ECE0);    // --bg
  static const Color bg2 = Color(0xFFE9DAC6);      // --bg-2
  static const Color bg2Alt = Color(0xFFE9E3D4);   // --bg-2
  static const Color surface2 = Color(0xFFFAF6EC); // --surface-2
  static const Color surface = Color(0xFFFFFFFF);  // --surface
  static const Color bgWarmSand = Color(0xFFF6EED6); // color-36
  static const Color bgLightSage = Color(0xFFE4F2E4); // color-37
  static const Color bgOffWhite = Color(0xFFF0F0F0);  // color-38

  // Brand Green Scale (Primary)
  static const Color brandGreenDark = Color(0xFF1C5A2C); // --brand-700
  static const Color brandGreen = Color(0xFF2C7A3F);     // --brand
  static const Color brandGreen100 = Color(0xFFCFE6CC);  // --brand-100
  static const Color brandGreen50 = Color(0xFFE6F1E4);   // --brand-50
  static const Color surfaceGreenMuted = Color(0xFFCFE3C4); // color-28 / color-30

  // Brand Terracotta / Warm Scale (Secondary / Accent)
  static const Color brandWarmDeep = Color(0xFF6E2E15);  // --brand-900
  static const Color brandWarmDark = Color(0xFF9C4220);  // --brand-700
  static const Color brandWarm = Color(0xFFC2562B);      // --brand
  static const Color brandWarm100 = Color(0xFFF0CFBB);   // --brand-100
  static const Color brandWarm50 = Color(0xFFF8E5D7);    // --brand-50
  static const Color surfaceWarmMuted = Color(0xFFFBEAE2); // color-37

  // Text Primary & Accents
  static const Color textPrimary = Color(0xFF13231B);    // color-1
  static const Color textForest = Color(0xFF1E4A38);     // color-3
  static const Color textBlue = Color(0xFF15557E);       // color-5
  static const Color textMuted = Color(0xFF5E6E64);
  static const Color textSubtle = Color(0xFF8B9B91);
}

class NegiluSpacing {
  NegiluSpacing._();

  static const double s1 = 1.0;
  static const double s2 = 2.0;
  static const double s3 = 3.0;
  static const double s4 = 4.0;
  static const double s5 = 5.0;
  static const double s6 = 6.0;
  static const double s7 = 7.0;
  static const double s8 = 8.0;
  static const double s9 = 9.0;
  static const double s10 = 10.0;
  static const double s11 = 11.0;
  static const double s12 = 12.0;
  static const double s13 = 13.0;
  static const double s14 = 14.0;
  static const double s15 = 15.0;
  static const double s16 = 16.0;
  static const double s17 = 18.0;
  static const double s18 = 20.0;
  static const double s19 = 22.0; // space-19: 22px
  static const double s20 = 24.0; // space-20: 24px
  static const double s21 = 30.0; // space-21: 30px
  static const double s22 = 31.0; // space-22: 31px
  static const double s23 = 34.0; // space-23: 34px
  static const double s24 = 46.0; // space-24: 46px
}

class NegiluRadii {
  NegiluRadii._();

  static const double sm = 5.0;       // radius-sm: 5px
  static const double md = 6.0;       // radius-md: 6px
  static const double lg = 8.0;       // radius-lg: 8px
  static const double xl = 10.0;      // radius-xl: 10px
  static const double full = 14.0;    // radius-full: 14px
  static const double r18 = 18.0;     // radius-6: 18px
  static const double r20 = 20.0;     // radius-7: 20px
  static const double r24 = 24.0;     // radius-8: 24px
  static const double circular = 999.0; // radius-10: 999px

  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
  static BorderRadius get borderFull => BorderRadius.circular(full);
  static BorderRadius get borderR18 => BorderRadius.circular(r18);
  static BorderRadius get borderR20 => BorderRadius.circular(r20);
  static BorderRadius get borderR24 => BorderRadius.circular(r24);
  static BorderRadius get borderCircular => BorderRadius.circular(circular);
}

class NegiluShadows {
  NegiluShadows._();

  // shadow-sm: rgb(228, 242, 228) 0px 0px 0px 4px
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0xFFE4F2E4),
      offset: Offset.zero,
      blurRadius: 0,
      spreadRadius: 4,
    ),
  ];

  // shadow-md: rgba(21, 32, 23, 0.05) 0px 1px 2px 0px, rgba(21, 32, 23, 0.06) 0px 6px 18px 0px
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0D152017),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
    BoxShadow(
      color: Color(0x0F152017),
      offset: Offset(0, 6),
      blurRadius: 18,
    ),
  ];

  // shadow-lg: rgba(0, 0, 0, 0.18) 0px 1px 4px 0px
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x2E000000),
      offset: Offset(0, 1),
      blurRadius: 4,
    ),
  ];

  // shadow-xl: rgba(0, 0, 0, 0.16) 0px 1px 5px 0px
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x29000000),
      offset: Offset(0, 1),
      blurRadius: 5,
    ),
  ];

  // shadow-5: rgba(0, 0, 0, 0.12) 0px 2px 8px 0px
  static const List<BoxShadow> s5 = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  // shadow-7: rgba(0, 0, 0, 0.28) 0px 6px 20px 0px
  static const List<BoxShadow> s7 = [
    BoxShadow(
      color: Color(0x47000000),
      offset: Offset(0, 6),
      blurRadius: 20,
    ),
  ];

  // shadow-8: rgba(28, 90, 44, 0.5) 0px 10px 24px -12px
  static const List<BoxShadow> brandAccent = [
    BoxShadow(
      color: Color(0x801C5A2C),
      offset: Offset(0, 10),
      blurRadius: 24,
      spreadRadius: -12,
    ),
  ];

  // shadow-9: rgba(0, 0, 0, 0.2) 0px 10px 34px 0px
  static const List<BoxShadow> s9 = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 10),
      blurRadius: 34,
    ),
  ];
}

class NegiluTypography {
  NegiluTypography._();

  // Font Stacks:
  // Headings & Brand: Bricolage Grotesque
  // Kannada Display / Regional: Noto Sans Kannada
  // Body & UI: Manrope

  static TextStyle heading({
    double fontSize = 20.0,
    FontWeight fontWeight = FontWeight.w700,
    Color color = NegiluColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle kannada({
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.w600,
    Color color = NegiluColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.notoSansKannada(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double fontSize = 13.0, // text-base default is 13px
    FontWeight fontWeight = FontWeight.w400,
    Color color = NegiluColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Token scale helpers
  static TextStyle get textXs => body(fontSize: 10.0);
  static TextStyle get textSm => body(fontSize: 11.0);
  static TextStyle get textBase => body(fontSize: 13.0);
  static TextStyle get textLg => body(fontSize: 14.0, fontWeight: FontWeight.w600);
  static TextStyle get textXl => heading(fontSize: 16.0);
  static TextStyle get text2Xl => heading(fontSize: 18.0);
  static TextStyle get text3Xl => heading(fontSize: 20.0);
  static TextStyle get text4Xl => heading(fontSize: 22.0);
  static TextStyle get text9 => heading(fontSize: 24.0);
  static TextStyle get text10 => heading(fontSize: 26.0);
  static TextStyle get text11 => heading(fontSize: 28.0);
  static TextStyle get text12 => heading(fontSize: 32.0);
  static TextStyle get text13 => heading(fontSize: 42.0);
  static TextStyle get text14 => heading(fontSize: 52.0);
  static TextStyle get text15 => heading(fontSize: 56.0);
}
