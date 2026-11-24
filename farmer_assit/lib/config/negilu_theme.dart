import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'negilu_tokens.dart';

class NegiluTheme {
  NegiluTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.manropeTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: NegiluColors.surface2, // #FAF6EC warm organic surface
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: NegiluColors.brandGreenDark,     // #1C5A2C
        onPrimary: Colors.white,
        primaryContainer: NegiluColors.brandGreen50, // #E6F1E4
        onPrimaryContainer: NegiluColors.brandGreenDark,
        secondary: NegiluColors.brandWarm,        // #C2562B
        onSecondary: Colors.white,
        secondaryContainer: NegiluColors.brandWarm50, // #F8E5D7
        onSecondaryContainer: NegiluColors.brandWarmDeep,
        surface: NegiluColors.surface,            // #FFFFFF
        onSurface: NegiluColors.textPrimary,      // #13231B
        surfaceContainerHighest: NegiluColors.bg, // #F0E5D6
        outline: Color(0xFFD8CEBF),
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: NegiluColors.textPrimary,
        displayColor: NegiluColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NegiluColors.brandGreenDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.bricolageGrotesque(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: NegiluColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: NegiluRadii.borderFull, // 14px token
          side: const BorderSide(color: Color(0xFFEFE8DB), width: 1.0),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: NegiluColors.surface,
        indicatorColor: NegiluColors.brandGreen50,
        elevation: 6,
        shadowColor: const Color(0x1F000000),
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? NegiluColors.brandGreenDark : NegiluColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? NegiluColors.brandGreenDark : NegiluColors.textMuted,
            size: 22,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NegiluColors.brandGreenDark,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: NegiluRadii.borderFull, // 14px token
          ),
          padding: const EdgeInsets.symmetric(
            vertical: NegiluSpacing.s14,
            horizontal: NegiluSpacing.s18,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NegiluColors.brandGreenDark,
          side: const BorderSide(color: NegiluColors.brandGreenDark, width: 1.5),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: NegiluRadii.borderFull, // 14px token
          ),
          padding: const EdgeInsets.symmetric(
            vertical: NegiluSpacing.s14,
            horizontal: NegiluSpacing.s18,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NegiluColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: NegiluSpacing.s16,
          vertical: NegiluSpacing.s14,
        ),
        border: OutlineInputBorder(
          borderRadius: NegiluRadii.borderFull, // 14px token
          borderSide: const BorderSide(color: Color(0xFFDCCFBD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: NegiluRadii.borderFull,
          borderSide: const BorderSide(color: Color(0xFFDCCFBD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: NegiluRadii.borderFull,
          borderSide: const BorderSide(
            color: NegiluColors.brandGreenDark,
            width: 1.8,
          ),
        ),
        labelStyle: GoogleFonts.manrope(
          color: NegiluColors.textMuted,
          fontSize: 13,
        ),
        hintStyle: GoogleFonts.manrope(
          color: NegiluColors.textSubtle,
          fontSize: 13,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: NegiluColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: NegiluRadii.borderR18, // 18px token
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: NegiluColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(NegiluRadii.r18)),
        ),
      ),
    );
  }
}
