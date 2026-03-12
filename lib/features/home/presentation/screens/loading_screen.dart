import 'dart:async';

import 'package:coffeenity/config/typography/app_typography.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/constants/app_assets.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/common_widgets/custom_image_widget.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    // Set up animations
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fadeAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: Colors.grey[300],
      end: AppColors.kAppSurface.withValues(alpha: 0.5),
    ).animate(_controller);

    // // Navigate after delay
    Timer(const Duration(seconds: 3), () async {
      if (mounted) context.goNamed(RouteNames.home.name);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        color: _colorAnimation.value,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Hero(
              tag: "logo",
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: CustomImageWidget(imageUrl: AppAssets.appBar, height: 60).pOnly(right: 13),
                ),
              ),
            ).pOnly(bottom: 90),
            // Animated progress indicator
            Column(
              children: [
                LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.kAppPrimary),
                  backgroundColor: Colors.grey[200],
                  value: _controller.value,
                ).w(200),
                10.heightBox,

                // Animated text
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text("Getting things ready...", style: AppTypography.style14Regular),
                ),

                10.heightBox,

                // Pulsing dots for visual interest
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildPulsingDot(0), _buildPulsingDot(200), _buildPulsingDot(400)],
                ),
              ],
            ).positioned(bottom: 0),
          ],
        ).wrapCenter(),
      ),
    ),
  );

  Widget _buildPulsingDot(int delay) => AnimatedContainer(
    margin: const EdgeInsets.symmetric(horizontal: 4.0),
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeInOut,
    height: 8,
    width: 8,
    decoration: BoxDecoration(
      color: _controller.value > (delay / 1000) % 1.0 ? AppColors.kAppPrimary : Colors.grey[300],
      shape: BoxShape.circle,
    ),
  );
}
