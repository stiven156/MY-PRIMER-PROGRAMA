import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Material 3 theme for the Mercados supermarket management app.
///
/// Primary palette: deep teal/green – conveys freshness and trust.
/// The seed colour is used to generate the entire tonal palette so that
/// every surface, container and on-colour automatically follows M3 rules.
class AppTheme {
  AppTheme._();

  // ──────────────────────────────────────────
  // Brand colours (used as seeds / overrides)
  // ──────────────────────────────────────────
  static const Color _seedPrimary = Color(0xFF00695C); // deep teal-green
  static const Color _seedSecondary = Color(0xFF2E7D32); // deep green accent
  static const Color _seedTertiary = Color(0xFF0277BD); // blue accent

  static const Color _errorColor = Color(0xFFB00020);
  static const Color _successColor = Color(0xFF2E7D32);
  static const Color _warningColor = Color(0xFFF57F17);
  static const Color _infoColor = Color(0xFF0277BD);

  // Neutral surface shades used in cards / backgrounds
  static const Color _surfaceLight = Color(0xFFF4F6F4);
  static const Color _surfaceDark = Color(0xFF121212);

  // ──────────────────────────────────────────
  // Semantic colour getters (theme-independent)
  // ──────────────────────────────────────────
  static Color get successColor => _successColor;
  static Color get warningColor => _warningColor;
  static Color get errorColor => _errorColor;
  static Color get infoColor => _infoColor;

  // ──────────────────────────────────────────
  // Light theme
  // ──────────────────────────────────────────
  static ThemeData get light {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _seedPrimary,
      secondary: _seedSecondary,
      tertiary: _seedTertiary,
      error: _errorColor,
      surface: _surfaceLight,
      brightness: Brightness.light,
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  // ──────────────────────────────────────────
  // Dark theme
  // ──────────────────────────────────────────
  static ThemeData get dark {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _seedPrimary,
      secondary: _seedSecondary,
      tertiary: _seedTertiary,
      error: _errorColor,
      surface: _surfaceDark,
      brightness: Brightness.dark,
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  // ──────────────────────────────────────────
  // Shared builder
  // ──────────────────────────────────────────
  static ThemeData _buildTheme(ColorScheme cs, Brightness brightness) {
    final bool isLight = brightness == Brightness.light;

    // System UI overlay style
    final SystemUiOverlayStyle overlayStyle = isLight
        ? SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: cs.surface,
            systemNavigationBarIconBrightness: Brightness.dark,
          )
        : SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: cs.surface,
            systemNavigationBarIconBrightness: Brightness.light,
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      brightness: brightness,

      // ── Typography ────────────────────────
      textTheme: _buildTextTheme(cs),

      // ── AppBar ────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        systemOverlayStyle: overlayStyle,
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
        actionsIconTheme: IconThemeData(color: cs.onSurfaceVariant),
        centerTitle: false,
      ),

      // ── Card ──────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: isLight ? Colors.white : const Color(0xFF1E1E1E),
        surfaceTintColor: cs.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isLight
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF2C2C2C),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),

      // ── Elevated Button ───────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Filled Button ─────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Outlined Button ───────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Text Button ───────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input Decoration ──────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? const Color(0xFFF5F5F5)
            : const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isLight
                ? const Color(0xFFE0E0E0)
                : const Color(0xFF3A3A3A),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        labelStyle: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: cs.onSurfaceVariant.withAlpha(153),
          fontSize: 14,
        ),
        prefixIconColor: cs.onSurfaceVariant,
        suffixIconColor: cs.onSurfaceVariant,
        errorStyle: TextStyle(color: cs.error, fontSize: 12),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),

      // ── Chip ──────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // ── Navigation Rail ───────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor:
            isLight ? const Color(0xFFF0F4F0) : const Color(0xFF1A1A1A),
        selectedIconTheme: IconThemeData(color: cs.primary, size: 24),
        unselectedIconTheme:
            IconThemeData(color: cs.onSurfaceVariant, size: 24),
        selectedLabelTextStyle: TextStyle(
          color: cs.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: cs.primaryContainer,
        elevation: 0,
        useIndicator: true,
        labelType: NavigationRailLabelType.all,
      ),

      // ── Navigation Bar (mobile bottom) ────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isLight ? Colors.white : const Color(0xFF1A1A1A),
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: cs.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: cs.onPrimaryContainer, size: 24);
          }
          return IconThemeData(color: cs.onSurfaceVariant, size: 24);
        }),
        elevation: 2,
      ),

      // ── Drawer ────────────────────────────
      drawerTheme: DrawerThemeData(
        backgroundColor:
            isLight ? const Color(0xFFF0F4F0) : const Color(0xFF1A1A1A),
        width: 260,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        elevation: 2,
      ),

      // ── List Tile ─────────────────────────
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        iconColor: cs.onSurfaceVariant,
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 12,
        ),
      ),

      // ── Divider ───────────────────────────
      dividerTheme: DividerThemeData(
        color: isLight
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF2C2C2C),
        thickness: 1,
        space: 1,
      ),

      // ── Floating Action Button ────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Snack Bar ─────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isLight ? const Color(0xFF323232) : const Color(0xFFE0E0E0),
        contentTextStyle: TextStyle(
          color: isLight ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        actionTextColor: cs.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
      ),

      // ── Dialog ────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: isLight ? Colors.white : const Color(0xFF1E1E1E),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 14,
          height: 1.5,
        ),
      ),

      // ── Bottom Sheet ──────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? Colors.white : const Color(0xFF1E1E1E),
        modalBackgroundColor:
            isLight ? Colors.white : const Color(0xFF1E1E1E),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        elevation: 8,
        modalElevation: 16,
        showDragHandle: true,
        dragHandleColor: isLight
            ? const Color(0xFFBDBDBD)
            : const Color(0xFF616161),
      ),

      // ── Tab Bar ───────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: cs.primary, width: 2.5),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
        indicatorSize: TabBarIndicatorSize.label,
      ),

      // ── Data Table ────────────────────────
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
          isLight
              ? const Color(0xFFF5F5F5)
              : const Color(0xFF242424),
        ),
        headingTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 13,
        ),
        dividerThickness: 1,
        horizontalMargin: 16,
        columnSpacing: 24,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 56,
      ),

      // ── Tooltip ───────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isLight
              ? const Color(0xFF424242)
              : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: TextStyle(
          color: isLight ? Colors.white : Colors.black87,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      // ── Switch ────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.onPrimary;
          return cs.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primary;
          return cs.surfaceContainerHighest;
        }),
      ),

      // ── Checkbox ──────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(cs.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: cs.outline, width: 1.5),
      ),

      // ── Radio ─────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primary;
          return cs.outline;
        }),
      ),

      // ── Progress Indicator ────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.primaryContainer,
        circularTrackColor: cs.primaryContainer,
      ),

      // ── Scrollbar ─────────────────────────
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          cs.onSurface.withAlpha(77),
        ),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(4),
        crossAxisMargin: 2,
      ),

      // ── Icon ──────────────────────────────
      iconTheme: IconThemeData(color: cs.onSurface, size: 24),
      primaryIconTheme: IconThemeData(color: cs.onPrimary, size: 24),
    );
  }

  // ──────────────────────────────────────────
  // Text theme
  // ──────────────────────────────────────────
  static TextTheme _buildTextTheme(ColorScheme cs) {
    return TextTheme(
      // Display
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: cs.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: cs.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: cs.onSurface,
      ),
      // Headline
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
      // Title
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: cs.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: cs.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: cs.onSurface,
      ),
      // Label
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: cs.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: cs.onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: cs.onSurfaceVariant,
      ),
      // Body
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: cs.onSurface,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: cs.onSurface,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: cs.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }
}
