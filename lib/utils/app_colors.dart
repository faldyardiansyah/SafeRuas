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
  
    // Home Colors
  static const Color homeBlue = Color(0xFF1F5BFF);
  static const Color homeCardTint = Color(0xFFD4E0FF);
  static const Color homeChipTint = Color(0xFFC1DCFF);
  static const Color homeCardBorder = Color(0xE5E2E8F0);
  static const Color yellowAccent = Color(0xFFFCD34D);

  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);

  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);

  static const LinearGradient homeHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1852EE), Color(0xFF1F5BFF), Color(0xFF2B66FF)],
  );

  static const LinearGradient homeWeatherGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF103EBC), Color(0xFF1A4CD2), Color(0xFF2563EB)],
  );
}
