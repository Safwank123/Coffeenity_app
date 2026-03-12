import 'package:coffeenity/config/colors/app_colors.dart';
import 'package:coffeenity/config/typography/app_typography.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  static const _fontFamily = "OpenSans";
  static const _primary = Color(0xFF592701);
  static const _secondary = Color(0xFF606AEF);
  static const _surface = Color(0xFF3F2100);
  static const _onPrimary = Color(0xFFFFFFFF);
  static const _onSecondary = Color(0xFFFFFFFF);
  static const _onSurface = Color(0xFFFFFFFF);
  static const _disabled = Color(0xFFBDBDBD);
  // static const _brownSurface = Color(0xFF1A0800);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,
    disabledColor: _disabled,
    colorScheme: ColorScheme(
      primary: _primary,
      secondary: _secondary,
      surface: _surface,
      onPrimary: _onPrimary,
      onSecondary: _onSecondary,
      onSurface: _onSurface,
      error: Colors.red,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: _surface,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.kAppSplashBackground,
      foregroundColor: _onPrimary,
      centerTitle: true,
      elevation: 0,
      toolbarHeight: 70,
      titleTextStyle: AppTypography.style20SemiBold,
      actionsPadding: EdgeInsets.only(right: 16),
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFDBDBDB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFDBDBDB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: _onSurface),
      ),
      filled: true,
      fillColor: _onSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      floatingLabelStyle: const TextStyle(color: _primary),
      labelStyle: const TextStyle(color: AppColors.kAppTextPrimary),
      hintStyle: const TextStyle(color: AppColors.kAppTextPrimary),
      
    ),
  );
}
