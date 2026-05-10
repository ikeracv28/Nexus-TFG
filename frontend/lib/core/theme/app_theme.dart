import 'package:flutter/material.dart';

// ── Paleta estática (siempre modo claro) ──────────────────────────────────────

class NexusColors {
  NexusColors._();

  static const Color primary      = Color(0xFF185FA5);
  static const Color primaryLight = Color(0xFFE6F1FB);
  static const Color primaryText  = Color(0xFF0C447C);

  static const Color success      = Color(0xFF3B6D11);
  static const Color successLight = Color(0xFFEAF3DE);
  static const Color successText  = Color(0xFF27500A);

  static const Color warning      = Color(0xFFBA7517);
  static const Color warningLight = Color(0xFFFAEEDA);
  static const Color warningText  = Color(0xFF633806);

  static const Color danger       = Color(0xFFE24B4A);
  static const Color dangerLight  = Color(0xFFFCEBEB);
  static const Color dangerText   = Color(0xFF791F1F);

  static const Color neutral      = Color(0xFF5F5E5A);
  static const Color neutralLight = Color(0xFFF1EFE8);
  static const Color neutralText  = Color(0xFF444441);

  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceAlt   = Color(0xFFF5F5F3);
  static const Color border       = Color(0xFFE8E6DF);
  static const Color borderStrong = Color(0xFFD3D1C7);

  static const Color ink          = Color(0xFF1A1A18);
  static const Color inkSecondary = Color(0xFF5F5E5A);
  static const Color inkTertiary  = Color(0xFF9C9A94);
}

// ── Paleta estática modo oscuro ───────────────────────────────────────────────

class NexusDarkColors {
  NexusDarkColors._();

  static const Color surface      = Color(0xFF1E1E1C);
  static const Color surfaceAlt   = Color(0xFF161614);
  static const Color border       = Color(0xFF2C2C2A);
  static const Color borderStrong = Color(0xFF3C3C3A);
  static const Color ink          = Color(0xFFF0EFE9);
  static const Color inkSecondary = Color(0xFFA8A6A0);
  static const Color inkTertiary  = Color(0xFF6B6965);
  static const Color primary      = Color(0xFF5BA8F5);
  static const Color primaryLight = Color(0xFF1A3A5A);
}

// ── ThemeExtension: colores adaptativos accesibles via contexto ───────────────

@immutable
class NexusThemeExt extends ThemeExtension<NexusThemeExt> {
  const NexusThemeExt({
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.borderStrong,
    required this.ink,
    required this.inkSecondary,
    required this.inkTertiary,
    required this.primaryColor,
    required this.primaryLight,
  });

  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color borderStrong;
  final Color ink;
  final Color inkSecondary;
  final Color inkTertiary;
  final Color primaryColor;
  final Color primaryLight;

  static const NexusThemeExt light = NexusThemeExt(
    surface:      NexusColors.surface,
    surfaceAlt:   NexusColors.surfaceAlt,
    border:       NexusColors.border,
    borderStrong: NexusColors.borderStrong,
    ink:          NexusColors.ink,
    inkSecondary: NexusColors.inkSecondary,
    inkTertiary:  NexusColors.inkTertiary,
    primaryColor: NexusColors.primary,
    primaryLight: NexusColors.primaryLight,
  );

  static const NexusThemeExt dark = NexusThemeExt(
    surface:      NexusDarkColors.surface,
    surfaceAlt:   NexusDarkColors.surfaceAlt,
    border:       NexusDarkColors.border,
    borderStrong: NexusDarkColors.borderStrong,
    ink:          NexusDarkColors.ink,
    inkSecondary: NexusDarkColors.inkSecondary,
    inkTertiary:  NexusDarkColors.inkTertiary,
    primaryColor: NexusDarkColors.primary,
    primaryLight: NexusDarkColors.primaryLight,
  );

  @override
  NexusThemeExt copyWith({
    Color? surface, Color? surfaceAlt, Color? border, Color? borderStrong,
    Color? ink, Color? inkSecondary, Color? inkTertiary, Color? primaryColor, Color? primaryLight,
  }) => NexusThemeExt(
    surface:      surface      ?? this.surface,
    surfaceAlt:   surfaceAlt   ?? this.surfaceAlt,
    border:       border       ?? this.border,
    borderStrong: borderStrong ?? this.borderStrong,
    ink:          ink          ?? this.ink,
    inkSecondary: inkSecondary ?? this.inkSecondary,
    inkTertiary:  inkTertiary  ?? this.inkTertiary,
    primaryColor: primaryColor ?? this.primaryColor,
    primaryLight: primaryLight ?? this.primaryLight,
  );

  @override
  NexusThemeExt lerp(NexusThemeExt? other, double t) {
    if (other == null) return this;
    return NexusThemeExt(
      surface:      Color.lerp(surface,      other.surface,      t)!,
      surfaceAlt:   Color.lerp(surfaceAlt,   other.surfaceAlt,   t)!,
      border:       Color.lerp(border,       other.border,       t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      ink:          Color.lerp(ink,          other.ink,          t)!,
      inkSecondary: Color.lerp(inkSecondary, other.inkSecondary, t)!,
      inkTertiary:  Color.lerp(inkTertiary,  other.inkTertiary,  t)!,
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
    );
  }
}

// ── Extensión de BuildContext para acceso corto ───────────────────────────────

extension NexusBuildContextExt on BuildContext {
  NexusThemeExt get nxt =>
      Theme.of(this).extension<NexusThemeExt>() ?? NexusThemeExt.light;
}

// ── Tipografía (SIN color — lo provee el tema) ────────────────────────────────

class NexusText {
  NexusText._();

  static const TextStyle heading1 = TextStyle(fontSize: 22, fontWeight: FontWeight.w500);
  static const TextStyle heading2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
  static const TextStyle heading3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static const TextStyle body     = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle small    = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
  static const TextStyle caption  = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const TextStyle label    = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.6);
}

// ── Tamaños ───────────────────────────────────────────────────────────────────

class NexusSizes {
  NexusSizes._();

  static const double spaceXS  = 4.0;
  static const double spaceSM  = 8.0;
  static const double spaceMD  = 12.0;
  static const double spaceLG  = 16.0;
  static const double spaceXL  = 20.0;
  static const double space2XL = 24.0;
  static const double space3XL = 32.0;

  static const double radiusSM   = 6.0;
  static const double radiusMD   = 8.0;
  static const double radiusLG   = 12.0;
  static const double radiusFull = 999.0;

  static const double borderWidth = 0.5;
}

// ── Temas ─────────────────────────────────────────────────────────────────────

ThemeData nexusTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.light,
    scaffoldBackgroundColor: NexusColors.surfaceAlt,
    colorScheme: ColorScheme.fromSeed(
      seedColor: NexusColors.primary,
      brightness: Brightness.light,
      surface: NexusColors.surface,
    ),
    extensions: const [NexusThemeExt.light],
    textTheme: const TextTheme(
      displayLarge:   NexusText.heading1,
      headlineMedium: NexusText.heading2,
      titleLarge:     NexusText.heading3,
      bodyLarge:      NexusText.body,
      bodyMedium:     NexusText.small,
      bodySmall:      NexusText.caption,
      labelSmall:     NexusText.label,
    ).apply(bodyColor: NexusColors.ink, displayColor: NexusColors.ink),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: NexusColors.surface,
      foregroundColor: NexusColors.ink,
      titleTextStyle: NexusText.heading3,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: NexusColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NexusSizes.radiusLG),
        side: const BorderSide(color: NexusColors.border, width: NexusSizes.borderWidth),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NexusColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        borderSide: const BorderSide(color: NexusColors.border, width: NexusSizes.borderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        borderSide: const BorderSide(color: NexusColors.border, width: NexusSizes.borderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        borderSide: const BorderSide(color: NexusColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        borderSide: const BorderSide(color: NexusColors.danger, width: NexusSizes.borderWidth),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        borderSide: const BorderSide(color: NexusColors.danger, width: 1.5),
      ),
      hintStyle: TextStyle(fontSize: 13, color: NexusColors.inkTertiary),
      errorStyle: TextStyle(fontSize: 12, color: NexusColors.danger),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NexusColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: NexusColors.border,
      thickness: NexusSizes.borderWidth,
      space: 0,
    ),
  );
}

ThemeData nexusDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: NexusDarkColors.surfaceAlt,
    colorScheme: ColorScheme.dark(
      primary:                  NexusDarkColors.primary,
      onPrimary:                const Color(0xFF0A2A4A),
      surface:                  NexusDarkColors.surface,
      onSurface:                NexusDarkColors.ink,
      surfaceContainerHighest:  NexusDarkColors.surfaceAlt,
      outline:                  NexusDarkColors.border,
      outlineVariant:           NexusDarkColors.borderStrong,
    ),
    extensions: const [NexusThemeExt.dark],
    textTheme: const TextTheme(
      displayLarge:   NexusText.heading1,
      headlineMedium: NexusText.heading2,
      titleLarge:     NexusText.heading3,
      bodyLarge:      NexusText.body,
      bodyMedium:     NexusText.small,
      bodySmall:      NexusText.caption,
      labelSmall:     NexusText.label,
    ).apply(bodyColor: NexusDarkColors.ink, displayColor: NexusDarkColors.ink),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: NexusDarkColors.surface,
      foregroundColor: NexusDarkColors.ink,
      titleTextStyle: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w500,
        color: NexusDarkColors.ink,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: NexusDarkColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NexusSizes.radiusLG),
        side: const BorderSide(color: NexusDarkColors.border, width: NexusSizes.borderWidth),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NexusDarkColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        borderSide: const BorderSide(color: NexusDarkColors.border, width: NexusSizes.borderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        borderSide: const BorderSide(color: NexusDarkColors.border, width: NexusSizes.borderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        borderSide: const BorderSide(color: NexusDarkColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        borderSide: const BorderSide(color: NexusColors.danger, width: NexusSizes.borderWidth),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        borderSide: const BorderSide(color: NexusColors.danger, width: 1.5),
      ),
      hintStyle: const TextStyle(fontSize: 13, color: NexusDarkColors.inkTertiary),
      errorStyle: TextStyle(fontSize: 12, color: NexusColors.danger),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NexusDarkColors.primary,
        foregroundColor: const Color(0xFF0A2A4A),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: NexusDarkColors.border,
      thickness: NexusSizes.borderWidth,
      space: 0,
    ),
  );
}

// ── Componentes reutilizables ─────────────────────────────────────────────────

Widget nexusEstadoBadge(String texto, {required Color bg, required Color textColor}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(NexusSizes.radiusFull),
    ),
    child: Text(
      texto,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textColor),
    ),
  );
}

Widget nexusCard({required Widget child, EdgeInsets? padding, BuildContext? context}) {
  final ext = context != null
      ? (Theme.of(context).extension<NexusThemeExt>() ?? NexusThemeExt.light)
      : NexusThemeExt.light;
  return Container(
    padding: padding ?? const EdgeInsets.all(NexusSizes.spaceLG),
    decoration: BoxDecoration(
      color: ext.surface,
      border: Border.all(color: ext.border, width: NexusSizes.borderWidth),
      borderRadius: BorderRadius.circular(NexusSizes.radiusLG),
    ),
    child: child,
  );
}
