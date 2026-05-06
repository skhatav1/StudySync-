import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudySyncTheme {
  static const double radius = 8;
  static const Color _primary = Color(0xFF2563EB);
  static const Color _ink = Color(0xFF0F172A);

  static ThemeData light() {
    final base = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
          seedColor: _primary, brightness: Brightness.light),
      useMaterial3: true,
    );
    final textTheme =
        GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
      displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 34, fontWeight: FontWeight.w800, color: _ink),
      headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 24, fontWeight: FontWeight.w800, color: _ink),
      titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 20, fontWeight: FontWeight.w800, color: _ink),
      titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w700, color: _ink),
      bodyLarge:
          GoogleFonts.plusJakartaSans(fontSize: 15, height: 1.45, color: _ink),
      bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13, height: 1.45, color: const Color(0xFF475569)),
      bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12, height: 1.4, color: const Color(0xFF64748B)),
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: textTheme.bodyMedium,
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: const Color(0xFF94A3B8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: _primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          textStyle: textTheme.titleMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          side: const BorderSide(color: Color(0xFFCBD5E1)),
          textStyle: textTheme.titleMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          textStyle: textTheme.titleMedium,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        backgroundColor: const Color(0xFFF8FAFC),
        labelStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      listTileTheme: ListTileThemeData(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEFF6FF),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.bodySmall?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? _primary
                : const Color(0xFF64748B),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }

  static ThemeData dark() {
    const seed = Color(0xFF8BC6FF);
    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme:
          ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      useMaterial3: true,
    );
    final textTheme =
        GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
      displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
      headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
      titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
      titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
      bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15, height: 1.45, color: const Color(0xFFE2E8F0)),
      bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13, height: 1.45, color: const Color(0xFFCBD5E1)),
      bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12, height: 1.4, color: const Color(0xFF94A3B8)),
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF09111F),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: const Color(0xFF121C2F),
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF121C2F),
        labelStyle: textTheme.bodyMedium,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Color(0xFF263348)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Color(0xFF263348)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: seed, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          textStyle: textTheme.titleMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          textStyle: textTheme.titleMedium,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        labelStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
