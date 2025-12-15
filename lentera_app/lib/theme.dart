import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Branding palette for Modern Serenity (unisex, calming)
/// Use these tokens across the app. Avoid hard-coding raw colors elsewhere.
class BrandingColors extends ThemeExtension<BrandingColors> {
  /// Calming Teal #2A9D8F (Primary)
  final Color deepTeal;
  /// Dark Slate Blue #264653 (Headings / strong text)
  final Color slateBlue;
  /// Soft Off-White background #F8F9FA
  final Color lightTealBg;
  /// Light Grey background (cards/backdrops)
  final Color lightGreyBg;
  /// Sandy Gold #E9C46A (Accent/Warning/Pending)
  final Color softSage;

  const BrandingColors({
    required this.deepTeal,
    required this.slateBlue,
    required this.lightTealBg,
    required this.lightGreyBg,
    required this.softSage,
  });

  static const BrandingColors light = BrandingColors(
    deepTeal: Color(0xFF2A9D8F),
    slateBlue: Color(0xFF264653),
    lightTealBg: Color(0xFFF8F9FA),
    lightGreyBg: Color(0xFFF2F4F5),
    softSage: Color(0xFFE9C46A),
  );

  static const BrandingColors dark = BrandingColors(
    deepTeal: Color(0xFF2A9D8F),
    slateBlue: Color(0xFFBFD1DA),
    lightTealBg: Color(0xFF0F1415),
    lightGreyBg: Color(0xFF15191B),
    softSage: Color(0xFFE9C46A),
  );

  @override
  BrandingColors copyWith({
    Color? deepTeal,
    Color? slateBlue,
    Color? lightTealBg,
    Color? lightGreyBg,
    Color? softSage,
  }) => BrandingColors(
        deepTeal: deepTeal ?? this.deepTeal,
        slateBlue: slateBlue ?? this.slateBlue,
        lightTealBg: lightTealBg ?? this.lightTealBg,
        lightGreyBg: lightGreyBg ?? this.lightGreyBg,
        softSage: softSage ?? this.softSage,
      );

  @override
  BrandingColors lerp(ThemeExtension<BrandingColors>? other, double t) {
    if (other is! BrandingColors) return this;
    return BrandingColors(
      deepTeal: Color.lerp(deepTeal, other.deepTeal, t) ?? deepTeal,
      slateBlue: Color.lerp(slateBlue, other.slateBlue, t) ?? slateBlue,
      lightTealBg: Color.lerp(lightTealBg, other.lightTealBg, t) ?? lightTealBg,
      lightGreyBg: Color.lerp(lightGreyBg, other.lightGreyBg, t) ?? lightGreyBg,
      softSage: Color.lerp(softSage, other.softSage, t) ?? softSage,
    );
  }
}

class AppSpacing {
  // Spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Edge insets shortcuts
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Horizontal padding
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

/// Border radius constants for consistent rounded corners
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

// =============================================================================
// TEXT STYLE EXTENSIONS
// =============================================================================

/// Extension to add text style utilities to BuildContext
/// Access via context.textStyles
extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

/// Helper methods for common text style modifications
extension TextStyleExtensions on TextStyle {
  /// Make text bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Make text semi-bold
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Make text medium weight
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Make text normal weight
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);

  /// Make text light
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// Add custom color
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Add custom size
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

// =============================================================================
// COLORS
// =============================================================================

/// Semantic brand extension colors (kept for backward compatibility)
class AppColors extends ThemeExtension<AppColors> {
  final Color sage; // calming sage green
  final Color slateBlue; // muted slate blue
  final Color amber; // soft amber accent
  final Color slateGrey; // slate grey text
  final Color goodDot; // indicator for good mood
  final Color okDot; // indicator for okay mood
  final Color lowDot; // indicator for low mood

  const AppColors({
    required this.sage,
    required this.slateBlue,
    required this.amber,
    required this.slateGrey,
    required this.goodDot,
    required this.okDot,
    required this.lowDot,
  });

  // Top-level fallbacks are also provided below as kAppColorsLight/Dark to avoid
  // referencing static properties from JS-compiled code paths on web.
  static const AppColors light = AppColors(
    sage: Color(0xFF2A9D8F), // primary
    slateBlue: Color(0xFF264653), // heading text
    amber: Color(0xFFE9C46A), // pending/warning
    slateGrey: Color(0xFF5A6772),
    goodDot: Color(0xFF2A9D8F),
    okDot: Color(0xFFE9C46A),
    lowDot: Color(0xFFB8C2CC),
  );

  static const AppColors dark = AppColors(
    sage: Color(0xFF2A9D8F),
    slateBlue: Color(0xFFBFD1DA),
    amber: Color(0xFFE9C46A),
    slateGrey: Color(0xFFCDD5DB),
    goodDot: Color(0xFF2A9D8F),
    okDot: Color(0xFFE9C46A),
    lowDot: Color(0xFF66717B),
  );

  @override
  AppColors copyWith({
    Color? sage,
    Color? slateBlue,
    Color? amber,
    Color? slateGrey,
    Color? goodDot,
    Color? okDot,
    Color? lowDot,
  }) {
    return AppColors(
      sage: sage ?? this.sage,
      slateBlue: slateBlue ?? this.slateBlue,
      amber: amber ?? this.amber,
      slateGrey: slateGrey ?? this.slateGrey,
      goodDot: goodDot ?? this.goodDot,
      okDot: okDot ?? this.okDot,
      lowDot: lowDot ?? this.lowDot,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      sage: Color.lerp(sage, other.sage, t) ?? sage,
      slateBlue: Color.lerp(slateBlue, other.slateBlue, t) ?? slateBlue,
      amber: Color.lerp(amber, other.amber, t) ?? amber,
      slateGrey: Color.lerp(slateGrey, other.slateGrey, t) ?? slateGrey,
      goodDot: Color.lerp(goodDot, other.goodDot, t) ?? goodDot,
      okDot: Color.lerp(okDot, other.okDot, t) ?? okDot,
      lowDot: Color.lerp(lowDot, other.lowDot, t) ?? lowDot,
    );
  }
}

/// Extension palette for chat-specific colors (Modern Serenity)
class ChatColors extends ThemeExtension<ChatColors> {
  final Color deepTeal; // #2A9D8F for user bubbles & accents
  final Color slateBlue; // #264653 for titles/icons
  final Color bubbleGrey; // backdrop / page tint
  final Color onlineGreen; // online indicator

  // New: explicit tokens to ensure perfect contrast in dark/light
  final Color incomingBg; // assistant bubble background
  final Color incomingFg; // assistant text color
  final Color incomingBorder; // assistant bubble border in light/dark
  final Color outgoingBg; // user bubble background
  final Color outgoingFg; // user text color
  final Color inputBg; // message input background
  final Color inputBorder; // message input border
  final Color timestamp; // subtle timestamp color

  const ChatColors({
    required this.deepTeal,
    required this.slateBlue,
    required this.bubbleGrey,
    required this.onlineGreen,
    required this.incomingBg,
    required this.incomingFg,
    required this.incomingBorder,
    required this.outgoingBg,
    required this.outgoingFg,
    required this.inputBg,
    required this.inputBorder,
    required this.timestamp,
  });

  static const ChatColors light = ChatColors(
    deepTeal: Color(0xFF2A9D8F),
    slateBlue: Color(0xFF264653),
    bubbleGrey: Color(0xFFF8F9FA),
    onlineGreen: Color(0xFF2ECC71),
    incomingBg: Color(0xFFFFFFFF),
    incomingFg: Color(0xFF1C1B1F),
    incomingBorder: Color(0xFFE6E6E6),
    outgoingBg: Color(0xFF2A9D8F),
    outgoingFg: Color(0xFFFFFFFF),
    inputBg: Color(0xFFFFFFFF),
    inputBorder: Color(0xFFDDDDDD),
    timestamp: Color(0xFF6B7C93),
  );

  static const ChatColors dark = ChatColors(
    deepTeal: Color(0xFF2A9D8F),
    slateBlue: Color(0xFFBFD1DA),
    bubbleGrey: Color(0xFF121415),
    onlineGreen: Color(0xFF27AE60),
    incomingBg: Color(0xFF1D2224),
    incomingFg: Color(0xFFE6E1E5),
    incomingBorder: Color(0xFF2A2F31),
    outgoingBg: Color(0xFF2A9D8F),
    outgoingFg: Color(0xFF0B0F10),
    inputBg: Color(0xFF171B1D),
    inputBorder: Color(0xFF2A2F31),
    timestamp: Color(0xFF9AA0A6),
  );

  @override
  ChatColors copyWith({
    Color? deepTeal,
    Color? slateBlue,
    Color? bubbleGrey,
    Color? onlineGreen,
    Color? incomingBg,
    Color? incomingFg,
    Color? incomingBorder,
    Color? outgoingBg,
    Color? outgoingFg,
    Color? inputBg,
    Color? inputBorder,
    Color? timestamp,
  }) {
    return ChatColors(
      deepTeal: deepTeal ?? this.deepTeal,
      slateBlue: slateBlue ?? this.slateBlue,
      bubbleGrey: bubbleGrey ?? this.bubbleGrey,
      onlineGreen: onlineGreen ?? this.onlineGreen,
      incomingBg: incomingBg ?? this.incomingBg,
      incomingFg: incomingFg ?? this.incomingFg,
      incomingBorder: incomingBorder ?? this.incomingBorder,
      outgoingBg: outgoingBg ?? this.outgoingBg,
      outgoingFg: outgoingFg ?? this.outgoingFg,
      inputBg: inputBg ?? this.inputBg,
      inputBorder: inputBorder ?? this.inputBorder,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  ChatColors lerp(ThemeExtension<ChatColors>? other, double t) {
    if (other is! ChatColors) return this;
    return ChatColors(
      deepTeal: Color.lerp(deepTeal, other.deepTeal, t) ?? deepTeal,
      slateBlue: Color.lerp(slateBlue, other.slateBlue, t) ?? slateBlue,
      bubbleGrey: Color.lerp(bubbleGrey, other.bubbleGrey, t) ?? bubbleGrey,
      onlineGreen: Color.lerp(onlineGreen, other.onlineGreen, t) ?? onlineGreen,
      incomingBg: Color.lerp(incomingBg, other.incomingBg, t) ?? incomingBg,
      incomingFg: Color.lerp(incomingFg, other.incomingFg, t) ?? incomingFg,
      incomingBorder: Color.lerp(incomingBorder, other.incomingBorder, t) ?? incomingBorder,
      outgoingBg: Color.lerp(outgoingBg, other.outgoingBg, t) ?? outgoingBg,
      outgoingFg: Color.lerp(outgoingFg, other.outgoingFg, t) ?? outgoingFg,
      inputBg: Color.lerp(inputBg, other.inputBg, t) ?? inputBg,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t) ?? inputBorder,
      timestamp: Color.lerp(timestamp, other.timestamp, t) ?? timestamp,
    );
  }
}

// Fallback constants to be used directly at runtime to avoid JS tear-off issues
// when referencing static properties. These are equivalent to AppColors.light/dark.
const kAppColorsLight = AppColors(
  sage: Color(0xFF9BBEAA),
  slateBlue: Color(0xFF6B7C93),
  amber: Color(0xFFFFC563),
  slateGrey: Color(0xFF5A6772),
  goodDot: Color(0xFF46B29D),
  okDot: Color(0xFF6B7C93),
  lowDot: Color(0xFFB8C2CC),
);

const kAppColorsDark = AppColors(
  sage: Color(0xFF88AF9D),
  slateBlue: Color(0xFF8EA0BA),
  amber: Color(0xFFFFC563),
  slateGrey: Color(0xFFCDD5DB),
  goodDot: Color(0xFF60C7B3),
  okDot: Color(0xFF8EA0BA),
  lowDot: Color(0xFF66717B),
);

/// Modern Serenity color palette
class LightModeColors {
  // Primary: Calming Teal
  static const lightPrimary = Color(0xFF2A9D8F);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFB9E5DF);
  static const lightOnPrimaryContainer = Color(0xFF123B36);

  // Secondary: Dark Slate Blue for headings
  static const lightSecondary = Color(0xFF264653);
  static const lightOnSecondary = Color(0xFFFFFFFF);

  // Tertiary: Sandy Gold accents
  static const lightTertiary = Color(0xFFE9C46A);
  static const lightOnTertiary = Color(0xFF3E3110);

  // Error colors
  static const lightError = Color(0xFFD94A4A);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFE6E6);
  static const lightOnErrorContainer = Color(0xFF8B2E2E);

  // Surface and background
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightOnSurface = Color(0xFF1C1B1F);
  static const lightBackground = Color(0xFFF8F9FA);
  static const lightSurfaceVariant = Color(0xFFF1F3F4);
  static const lightOnSurfaceVariant = Color(0xFF495057);

  // Outline and shadow
  static const lightOutline = Color(0xFFCAC4D0);
  static const lightShadow = Color(0xFF000000);
  static const lightInversePrimary = Color(0xFFBDB4E8);
}

/// Dark mode colors with soothing contrast (Modern Serenity)
class DarkModeColors {
  // Primary: Calming Teal glow
  static const darkPrimary = Color(0xFF2A9D8F);
  static const darkOnPrimary = Color(0xFF0B0F10);
  static const darkPrimaryContainer = Color(0xFF1E4943);
  static const darkOnPrimaryContainer = Color(0xFFCDEDE8);

  // Secondary: Slate accents
  static const darkSecondary = Color(0xFF8EA0BA);
  static const darkOnSecondary = Color(0xFF081217);

  // Tertiary: Sandy Gold
  static const darkTertiary = Color(0xFFE9C46A);
  static const darkOnTertiary = Color(0xFF221C07);

  // Error colors
  static const darkError = Color(0xFFFF8A80);
  static const darkOnError = Color(0xFF5C1C1C);
  static const darkErrorContainer = Color(0xFFAB3535);
  static const darkOnErrorContainer = Color(0xFFFFE6E6);

  // Surface and background
  static const darkSurface = Color(0xFF0F1415);
  static const darkOnSurface = Color(0xFFE6E1E5);
  static const darkSurfaceVariant = Color(0xFF171B1D);
  static const darkOnSurfaceVariant = Color(0xFFB0B6BB);

  // Outline and shadow
  static const darkOutline = Color(0xFF31373B);
  static const darkShadow = Color(0xFF000000);
  static const darkInversePrimary = Color(0xFFB9E5DF);
}

/// Font size constants
class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

// =============================================================================
// THEMES
// =============================================================================

/// Light theme with modern, neutral aesthetic
ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: LightModeColors.lightPrimary,
    onPrimary: LightModeColors.lightOnPrimary,
    primaryContainer: LightModeColors.lightPrimaryContainer,
    onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
    secondary: LightModeColors.lightSecondary,
    onSecondary: LightModeColors.lightOnSecondary,
    tertiary: LightModeColors.lightTertiary,
    onTertiary: LightModeColors.lightOnTertiary,
    error: LightModeColors.lightError,
    onError: LightModeColors.lightOnError,
    errorContainer: LightModeColors.lightErrorContainer,
    onErrorContainer: LightModeColors.lightOnErrorContainer,
    surface: LightModeColors.lightSurface,
    onSurface: LightModeColors.lightOnSurface,
    surfaceContainerHighest: LightModeColors.lightSurfaceVariant,
    onSurfaceVariant: LightModeColors.lightOnSurfaceVariant,
    outline: LightModeColors.lightOutline,
    shadow: LightModeColors.lightShadow,
    inversePrimary: LightModeColors.lightInversePrimary,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: LightModeColors.lightBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: LightModeColors.lightOnSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: LightModeColors.lightOutline.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
  ),
  extensions: const <ThemeExtension<dynamic>>[
    kAppColorsLight,
    ChatColors.light,
    BrandingColors.light,
  ],
  textTheme: _buildTextTheme(Brightness.light),
);

/// Dark theme with good contrast and readability
ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: DarkModeColors.darkPrimary,
    onPrimary: DarkModeColors.darkOnPrimary,
    primaryContainer: DarkModeColors.darkPrimaryContainer,
    onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
    secondary: DarkModeColors.darkSecondary,
    onSecondary: DarkModeColors.darkOnSecondary,
    tertiary: DarkModeColors.darkTertiary,
    onTertiary: DarkModeColors.darkOnTertiary,
    error: DarkModeColors.darkError,
    onError: DarkModeColors.darkOnError,
    errorContainer: DarkModeColors.darkErrorContainer,
    onErrorContainer: DarkModeColors.darkOnErrorContainer,
    surface: DarkModeColors.darkSurface,
    onSurface: DarkModeColors.darkOnSurface,
    surfaceContainerHighest: DarkModeColors.darkSurfaceVariant,
    onSurfaceVariant: DarkModeColors.darkOnSurfaceVariant,
    outline: DarkModeColors.darkOutline,
    shadow: DarkModeColors.darkShadow,
    inversePrimary: DarkModeColors.darkInversePrimary,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: DarkModeColors.darkSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: DarkModeColors.darkOnSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: DarkModeColors.darkOutline.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
  ),
  extensions: const <ThemeExtension<dynamic>>[
    kAppColorsDark,
    ChatColors.dark,
    BrandingColors.dark,
  ],
  textTheme: _buildTextTheme(Brightness.dark),
);

/// Build text theme using Inter font family
TextTheme _buildTextTheme(Brightness brightness) {
  return TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
  );
}
