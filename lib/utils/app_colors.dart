import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF29B6F6);
  static const Color primaryDark = Color(0xFF078BCE);
  static const Color primaryLight = Color(0xFF81D4FA);

  // Background Colors
  static const Color background = Color(0xFFB3E5FC);
  static const Color backgroundLight = Color(0xFFD8F3FF);
  static const Color surface = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF172B3A);
  static const Color textSecondary = Color(0xFF526A79);
  static const Color textMuted = Color(0xFF78909C);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Accent Colors
  static const Color teal = Color(0xFF258F89);
  static const Color tealDark = Color(0xFF16766F);

  // Progress Colors
  static const Color progressTrack = Color(0xFFE4F2FA);
  static const Color progressValue = Color(0xFF168F80);

  // Status Colors
  static const Color success = Color(0xFF2E9D79);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF29B6F6);

  // Other Colors
  static const Color divider = Color(0xFFD6EAF5);
  static const Color shadow = Color(0x1F078BCE);

  // Onboarding Colors
  static const Color onboardingBackground = Color(0xFFF9FAFF);
  static const Color onboardingPrimary = Color(0xFF2450E8);
  static const Color onboardingHeading = Color(0xFF17264A);
  static const Color onboardingMuted = Color(0xFF68748D);
  static const Color onboardingChipBorder = Color(0xFFE9ECF5);
  static const Color onboardingIndicatorInactive = Color(0xFFD7DDF0);
  static const Color onboardingSecondaryText = Color(0xFF46516A);

  // Map Illustration Colors
  static const Color mapBackground = Color(0xFFF0F2FF);
  static const Color mapBorder = Color(0xFFE3E7FA);
  static const Color mapRoadLine = Color(0xFFD9DEEE);
  static const Color mapDot = Color(0xFFDCE2F8);

  // Road Condition Colors
  static const Color dangerRed = Color(0xFFD92735);
  static const Color warningYellow = Color(0xFFFFC857);
  static const Color infoBlue = Color(0xFF3156E8);

  // Gradients
  static const LinearGradient onboardingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, Color(0xFF70D5FA), Color(0xFFBCEBFF), backgroundLight],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
}
