import 'package:flutter/material.dart';

import '../../main.dart';

abstract class AppColors {
  static final _context = navigatorKey.currentContext!;
  static ColorScheme get _colorScheme => Theme.of(_context).colorScheme;

  static Color get kAppPrimary => _colorScheme.primary;
  static Color get kAppSecondary => _colorScheme.secondary;
  static Color get kAppSurface => _colorScheme.surface;
  static Color get kAppOnPrimary => _colorScheme.onPrimary;
  static Color get kAppOnSecondary => _colorScheme.onSecondary;
  static Color get kAppOnSurface => _colorScheme.onSurface;
  static Color get kAppDisabled => Theme.of(_context).disabledColor;
  static const Color kPendingColor = Color(0xFFFFA726); // Orange
  static const Color kInProgressColor = Color(0xFF29B6F6); // Blue
  static const Color kSuccessColor = Color(0xFF66BB6A); // Green
  static const Color kErrorColor = Color(0xFFEF5350); // Red
  static const Color kTextSecondary = Color(0xFF757575); // Grey
  static const Color kAppWhite = Color(0xFFFFFFFF);
  static const Color kAppBlack = Color(0xFF000000);

  static const Color kAppTextPrimary = Color(0xFF20170D);
  static const Color kAppCardColor = Color(0xFF2C1910);

  static const Color kAppSplashBackground = Color(0xFF211706);
  static const Color kAppLightBrown = Color(0xFFE4B078);
  static const Color kAppOffWhite = Color(0xFFF5F5F5);
  static const Color kAppAmber = Color(0xFFFFC107);
  static const Color kAppRed = Color(0xFFFF0000);
  static const Color kAppHeart = Color(0xFFF95692);

  static const Color kAppInfo = Color(0xFF1E88E5);
  static const Color kAppSuccess = Color(0xFF2E7D32);
  static const Color kAppError = Color(0xFFB71C1C);
  static const Color kAppWarning = Color(0xFFD84315);
}
