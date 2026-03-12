import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../config/colors/app_colors.dart';
import '../../config/typography/app_typography.dart';

abstract class AppPrompts {
  static void showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? confirmText,
    String? cancelText,
  }) => showAppDialog(
    context,
    child: Platform.isIOS
        ? CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(cancelText ?? 'No')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: Text(confirmText ?? "Yes"),
              ),
            ],
          )
        : AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(cancelText ?? 'No', style: TextStyle(color: AppColors.kAppWhite)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: Text(confirmText ?? "Yes", style: TextStyle(color: AppColors.kAppWhite)),
              ),
            ],
          ),
  );
  static void showAppDialog(BuildContext context, {required Widget child}) => showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionBuilder: (context, animation, _, _) => ScaleTransition(
      scale: Tween<double>(begin: .5, end: 1).animate(animation),
      child: FadeTransition(opacity: Tween<double>(begin: .5, end: 1).animate(animation), child: child),
    ),
  );
  // Toast positioning options
  static AlignmentGeometry defaultAlignment = Alignment.topCenter;

  /// Shows an informational toast with gentle pulse animation
  static void showInfo({
    required String message,
    Duration duration = const Duration(seconds: 3),
    Widget? customIcon,
    AlignmentGeometry? alignment,
  }) => _showToast(
    message: message,
    duration: duration,
    alignment: alignment,
    type: ToastificationType.info,
    primaryColor: AppColors.kAppInfo,
    secondaryColor: AppColors.kAppInfo.withValues(alpha: 0.2),
    icon: customIcon ?? const Icon(Icons.info_outline_rounded, size: 24, color: AppColors.kAppInfo),
    animationType: AnimationType.pulse,
  );

  /// Shows a success toast with slide and scale animation
  static void showSuccess({
    required String message,
    Duration duration = const Duration(seconds: 2),
    Widget? customIcon,
    bool showProgress = false,
    AlignmentGeometry? alignment,
  }) => _showToast(
    showProgress: showProgress,
    message: message,
    duration: duration,
    alignment: alignment,
    type: ToastificationType.success,
    primaryColor: AppColors.kAppSuccess,
    secondaryColor: AppColors.kAppSuccess.withValues(alpha: 0.2),
    icon: customIcon ?? const Icon(Icons.check_circle, size: 24, color: AppColors.kAppSuccess),
    animationType: AnimationType.slideScale,
  );

  /// Shows an error toast with shake and glow animation
  static void showError({
    required String message,
    Duration duration = const Duration(seconds: 3),
    Widget? customIcon,
    AlignmentGeometry? alignment,
  }) => _showToast(
    message: message,
    duration: duration,
    alignment: alignment,
    type: ToastificationType.error,
    primaryColor: AppColors.kAppError,
    secondaryColor: AppColors.kAppError.withValues(alpha: 0.2),
    icon: customIcon ?? Icon(Icons.error_outline_rounded, size: 24, color: AppColors.kAppError),
    animationType: AnimationType.pulse,
  );

  /// Shows a warning toast with gentle bounce animation
  static void showWarning({
    required String message,
    Duration duration = const Duration(seconds: 4),
    Widget? customIcon,
    AlignmentGeometry? alignment,
  }) => _showToast(
    message: message,
    duration: duration,
    alignment: alignment,
    type: ToastificationType.warning,
    primaryColor: AppColors.kAppWarning,
    secondaryColor: AppColors.kAppWarning.withValues(alpha: 0.2),
    icon: customIcon ?? Icon(Icons.warning_amber_rounded, size: 24, color: AppColors.kAppWarning),
    animationType: AnimationType.bounce,
  );

  /// Shows a loading indicator toast with progress and subtle pulse
  static void showLoading({
    required String message,
    Duration duration = const Duration(seconds: 10),
    bool showProgress = true,
    AlignmentGeometry? alignment,
  }) => _showToast(
    message: message,
    duration: duration,
    alignment: alignment,
    type: ToastificationType.info,
    primaryColor: AppColors.kAppPrimary,
    secondaryColor: AppColors.kAppPrimary.withValues(alpha: 0.2),
    icon: showProgress
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: AppColors.kAppPrimary, strokeWidth: 3),
          )
        : null,
    animationType: AnimationType.pulse,
    showProgress: showProgress,
  );

  /// Shows a custom toast with gradient background
  static void showGradient({
    required String message,
    required List<Color> gradientColors,
    Widget? icon,
    Duration duration = const Duration(seconds: 3),
    AlignmentGeometry? alignment,
  }) {
    toastification.show(
      context: null, // Will use the navigator key context
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(
        message,
        style: AppTypography.style16Regular.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      autoCloseDuration: duration,
      icon: icon,
      alignment: alignment ?? defaultAlignment,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ],
      animationBuilder: (context, animation, alignment, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: gradientColors.last.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 1),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Private method to handle common toast display logic
  static void _showToast({
    required String message,
    required ToastificationType type,
    required Widget? icon,
    required Color primaryColor,
    Color? secondaryColor,
    required Duration duration,
    AlignmentGeometry? alignment,
    required AnimationType animationType,
    bool showProgress = false,
  }) => toastification.show(
    context: null, // Will use the navigator key context
    showProgressBar: showProgress,
    type: type,
    style: ToastificationStyle.flatColored,
    title: Text(
      message,
      style: AppTypography.style16Regular.copyWith(color: primaryColor, fontWeight: FontWeight.w500),
    ),
    autoCloseDuration: duration,
    icon: icon,
    alignment: alignment ?? defaultAlignment,
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    margin: const EdgeInsets.all(20),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 8),
      ),
    ],
    progressBarTheme: ProgressIndicatorThemeData(
      color: Colors.white,
      linearTrackColor: Colors.white.withValues(alpha: 0.3),
    ),
    animationBuilder: _getAnimationBuilder(animationType, primaryColor),
  );

  static Widget Function(BuildContext, Animation<double>, Alignment, Widget) _getAnimationBuilder(
    AnimationType type,
    Color color,
  ) {
    switch (type) {
      case AnimationType.bounce:
        return (context, animation, alignment, child) => BounceTransition(animation: animation, child: child);

      case AnimationType.pulse:
        return (context, animation, alignment, child) => PulseTransition(animation: animation, child: child);

      case AnimationType.slideScale:
        return (context, animation, alignment, child) => SlideScaleTransition(animation: animation, child: child);

      case AnimationType.flip:
        return (context, animation, alignment, child) => FlipTransition(animation: animation, child: child);
    }
  }

  /// Dismisses all currently showing toasts
  static void dismissAll() => toastification.dismissAll();

  /// Change the default alignment for toasts
  static void setDefaultAlignment(AlignmentGeometry alignment) {
    defaultAlignment = alignment;
  }
}

// Extended animation types
enum AnimationType { slideScale, bounce, pulse, flip }

// Custom animation transitions
class BounceTransition extends AnimatedWidget {
  const BounceTransition({super.key, required Animation<double> animation, required this.child})
    : super(listenable: animation);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
        ),
      ),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

class PulseTransition extends AnimatedWidget {
  const PulseTransition({super.key, required Animation<double> animation, required this.child})
    : super(listenable: animation);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    //final pulseValue = sin(animation.value * 2 * pi) * 0.05 + 1.0;

    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

class SlideScaleTransition extends AnimatedWidget {
  const SlideScaleTransition({super.key, required Animation<double> animation, required this.child})
    : super(listenable: animation);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
          ),
        ),
        child: FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

class FlipTransition extends AnimatedWidget {
  const FlipTransition({super.key, required Animation<double> animation, required this.child})
    : super(listenable: animation);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    final rotation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

    return RotationTransition(
      turns: rotation,
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
