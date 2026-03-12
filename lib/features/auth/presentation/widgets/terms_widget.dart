import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/material.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/typography/app_typography.dart';

class TermsWidget extends StatefulWidget {
  const TermsWidget({super.key, required this.selectedOption, required this.onChanged});
  final int selectedOption;
  final ValueChanged<int?> onChanged;

  @override
  State<TermsWidget> createState() => _TermsWidgetState();
}

class _TermsWidgetState extends State<TermsWidget> with TickerProviderStateMixin {
  late final List<AnimationController> _animationControllers;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    const int baseDuration = 500;
    const int staggerDelay = 100;
    const int totalFields = 5; // title + description + legal + radio group

    _animationControllers = List.generate(totalFields, (index) {
      return AnimationController(
        duration: Duration(milliseconds: baseDuration + (index * staggerDelay)),
        vsync: this,
      );
    });

    _fadeAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    _slideAnimations = _animationControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0.0, 0.9),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    // Start animations
    for (final controller in _animationControllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    children: [
      _buildAnimatedTitle(),
      20.heightBox,
      _buildAnimatedDescription(),
      20.heightBox,
      _buildAnimatedLegalText(),
      30.heightBox,
      _buildAnimatedRadioOptions(),
      120.heightBox,
    ],
  );

  Widget _buildAnimatedTitle() => FadeTransition(
    opacity: _fadeAnimations[0],
    child: SlideTransition(
      position: _slideAnimations[0],
      child: Text('Location Data & Security Disclaimer', style: AppTypography.style24Bold),
    ),
  );

  Widget _buildAnimatedDescription() => FadeTransition(
    opacity: _fadeAnimations[1],
    child: SlideTransition(
      position: _slideAnimations[1],
      child: Text(
        'To help you discover nearby coffee shops and receive personalized offers, Coffeenity needs access to your device\'s location. Please enable location permissions for Coffeenity so we can provide the best experience, including shop discovery and exclusive deals tailored to where you are.',
        style: AppTypography.style16Regular.copyWith(color: AppColors.kAppWhite.withValues(alpha: 0.5)),
      ),
    ),
  );

  Widget _buildAnimatedLegalText() => FadeTransition(
    opacity: _fadeAnimations[2],
    child: SlideTransition(
      position: _slideAnimations[2],
      child: Text(
        'Coffeenity ("the App") may collect and process device location information to deliver location-based features, such as identifying nearby coffee venues and providing tailored offers and content. All location data is stored securely in accordance with industry best practices including the use of encryption, restricted access, and regular security audits. Coffeenity will never share, sell, or disclose your location information to third parties for marketing or any other purposes, except as required by law or with your explicit consent. Location data is used exclusively to enhance app functionality and user experience. The App complies with all applicable privacy regulations, including GDPR and California Consumer Privacy Act (CCPA), and obtains explicit user consent prior to collecting any location data. Users may withdraw consent or modify location permissions at any time via device settings or in-app controls, without affecting access to core app features. Coffeenity is committed to maintaining the highest standards of data protection and privacy for all users. For any questions about data usage or privacy practices, please contact our support team.',
        style: AppTypography.style16Regular.copyWith(color: AppColors.kAppWhite.withValues(alpha: 0.5)),
      ),
    ),
  );

  Widget _buildAnimatedRadioOptions() => FadeTransition(
    opacity: _fadeAnimations[3],
    child: SlideTransition(
      position: _slideAnimations[3],
      child: RadioGroup(
        onChanged: widget.onChanged,
        groupValue: widget.selectedOption,
        child: Column(
          children: [
            FadeTransition(
              opacity: _fadeAnimations[4],
              child: SlideTransition(
                position: _slideAnimations[4],
                child: RadioListTile<int>(
                  title: const Text(
                    'I hereby acknowledge and agree to the above terms, and I consent to share my location.',
                  ),
                  value: 0,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFFC07B00),
                  visualDensity: VisualDensity.compact,
                  titleAlignment: ListTileTitleAlignment.top,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimations[4],
              child: SlideTransition(
                position: _slideAnimations[4],
                child: RadioListTile<int>(
                  title: const Text(
                    'I hereby decline to share my location and agree that coffee shop results will be limited to the zip code I provide.',
                  ),
                  value: 1,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFFC07B00),
                  visualDensity: VisualDensity.compact,
                  titleAlignment: ListTileTitleAlignment.top,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
