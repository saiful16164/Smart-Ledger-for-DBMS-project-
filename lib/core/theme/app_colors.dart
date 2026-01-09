import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF1E3A5F); // Deep Blue
  static const Color accent = Color(0xFF00B4A6); // Teal

  // Status Colors
  static const Color success = Color(0xFF10B981); // Green (Receivable)
  static const Color error = Color(0xFFEF4444); // Red (Payable)
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Aliases for common usage (defaulting to Light theme for now as simple fix)
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;

  // Cashbook Categories
  static const Color cashIn = Color(0xFF10B981);
  static const Color cashOut = Color(0xFFEF4444);
  static const Color ownerGave = Color(0xFF8B5CF6); // Purple
  static const Color ownerTook = Color(0xFFEC4899); // Pink
}
