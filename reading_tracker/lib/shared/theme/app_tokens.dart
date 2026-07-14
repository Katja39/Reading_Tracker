// Shared design tokens for spacing, radii, sizes, insets, and layout widths
import 'package:flutter/material.dart';

// Shared spacing values used to keep screen layouts visually consistent
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

// Shared corner radii for cards, buttons, inputs, and pill-shaped controls
class AppRadii {
  AppRadii._();

  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 999.0;
}

// Shared component dimensions that should match across screens
class AppSizes {
  AppSizes._();

  static const detailProgressWidth = 260.0;
  static const progressMinWidth = 180.0;
  static const progressMaxWidth = 240.0;
  static const compactProgressMinWidth = 96.0;
  static const compactProgressMaxWidth = 128.0;
  static const buttonHeight = 36.0;
  static const compactButtonHeight = 30.0;
  static const homeReadingCardWidthLarge = 360.0;
  static const homeReadingCardWidthMedium = 330.0;
  static const homeReadingCardWidthSmall = 300.0;
  static const homeReadingCoverWidthLarge = 96.0;
  static const homeReadingCoverWidthMedium = 90.0;
  static const homeReadingCoverWidthSmall = 84.0;
}

// Shared insets for common controls
class AppInsets {
  AppInsets._();

  static const inputContent = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.md,
  );

  static const button = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.sm,
  );

  static const compactButton = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );
}

// Shared responsive layout widths for primary application surfaces
class AppLayout {
  AppLayout._();

  static double detailContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (screenWidth >= 1600) {
      return 1100;
    }
    if (screenWidth >= 1200) {
      return 920;
    }
    if (screenWidth >= 900) {
      return 760;
    }
    return screenWidth;
  }

  static double libraryContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (screenWidth >= 1600) {
      return 1360;
    }
    if (screenWidth >= 1300) {
      return 1120;
    }
    if (screenWidth >= 1000) {
      return 920;
    }
    if (screenWidth >= 800) {
      return 760;
    }
    return screenWidth;
  }
}