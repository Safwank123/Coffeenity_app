import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/constants/app_assets.dart';
import '../../../../config/local/local_storage_services.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/common_widgets/custom_app_button.dart';
import '../../../../core/common_widgets/custom_image_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoRotation;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _button1Opacity;
  late final Animation<double> _button2Opacity;
  late final Animation<Offset> _button1Slide;
  late final Animation<Offset> _button2Slide;
  
  bool _hasToken = false;
  bool _checkingToken = true;
  bool _isFaceRegistered = false;
  bool _isFaceLoginInProgress = false;
  final LocalAuthentication _auth = LocalAuthentication();
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    // Check if token exists
    final token = LocalStorageServices.getToken();
    // Check if face is registered
    final isFaceRegistered = LocalStorageServices.getData<bool>(LocalStorageKeys.isFace.name) ?? false;

    if (mounted) {
      setState(() {
        _hasToken = token != null;
        _isFaceRegistered = isFaceRegistered;
        _checkingToken = false;
      });

      // Always play the logo animation
      WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());

      // If token exists, check if face login is required
      if (_hasToken) {
        // If face is registered, try face login
        if (_isFaceRegistered) {
          await _attemptFaceLogin();
        } else {
          // No face registration, go directly to home after animation
          _navigateToHomeAfterAnimation();
        }
      }
    }
  }

  Future<void> _attemptFaceLogin() async {
    try {
      // Check if device supports biometrics
      final canAuthenticate = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        // Device doesn't support biometrics, go to home directly
        _navigateToHomeAfterAnimation();
        return;
      }

      // Wait for animation to complete before showing biometric prompt
      await Future.delayed(const Duration(milliseconds: 1800));

      if (!mounted) return;

      setState(() => _isFaceLoginInProgress = true);

      // Trigger biometric authentication
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Authenticate with Face ID to access the app',
        biometricOnly: true,
      );

      if (mounted) {
        if (didAuthenticate) {
          // Face authentication successful
          context.goNamed(RouteNames.home.name);
        } else {
          // Face authentication failed or cancelled
          setState(() => _isFaceLoginInProgress = false);
          // Stay on splash screen showing buttons for manual login
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Face login error: $e');
      if (mounted) {
        setState(() => _isFaceLoginInProgress = false);
        // On error, fall back to manual login
        _navigateToHomeAfterAnimation();
      }
    }
  }

  void _navigateToHomeAfterAnimation() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        context.goNamed(RouteNames.home.name);
      }
    });
  }

  void _initializeAnimations() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));

    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInCubic),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // First button animations
    _button1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    _button1Slide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Second button animations
    _button2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _button2Slide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _navigateWithAnimation(Function navigationFunction) => _controller.reverse().then((_) => navigationFunction());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
@override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.kAppSplashBackground,
    body: SafeArea(
      child: Column(
        children: [
          (kToolbarHeight + 40).heightBox,
          // Enhanced Animated Logo with multiple effects
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => SlideTransition(
              position: _logoSlide,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  // ignore: deprecated_member_use
                  ..scale(_logoScale.value)
                  ..rotateZ(_logoRotation.value),
                child: Opacity(opacity: _logoOpacity.value.clamp(0.0, 1.0), child: child),
              ),
            ),
            child: Hero(
              tag: "splash_logo",
              child: CustomImageWidget(imageUrl: AppAssets.splashLogo),
            ),
          ),

          const Spacer(),

          // Show loading indicator when face login is in progress
          if (_isFaceLoginInProgress) ...[
            Column(
              children: [
                const CircularProgressIndicator(color: AppColors.kAppLightBrown, strokeWidth: 2),
                20.heightBox,
                Text(
                  'Authenticating with Face ID...',
                  style: TextStyle(color: AppColors.kAppTextPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                40.heightBox,
              ],
            ),
          ]
          // Show buttons only when checking is complete
          else if (!_checkingToken) ...[
            // Always show Create Account button for new users
          if (!_hasToken) ...[
            // First Button with staggered animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => SlideTransition(
                position: _button1Slide,
                child: Opacity(opacity: _button1Opacity.value.clamp(0.0, 1.0), child: child),
              ),
              child: CustomAppButton(
                text: "Create an account",
                onPressed: () => _navigateWithAnimation(
                  () => context.goNamed(RouteNames.register.name),
                ),
                backgroundColor: AppColors.kAppLightBrown,
                textColor: AppColors.kAppTextPrimary,
              ).px(16),
            ),
            
            15.heightBox,
            
              // Show login option for new users
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => SlideTransition(
                position: _button2Slide,
                child: Opacity(opacity: _button2Opacity.value.clamp(0.0, 1.0), child: child),
              ),
              child: CustomAppButton(
                text: "I already have an account",
                onPressed: () => _navigateWithAnimation(
                  () => context.goNamed(RouteNames.registerFace.name, extra: RouteNames.login.name),
                ),
                backgroundColor: AppColors.kAppOffWhite,
                textColor: AppColors.kAppTextPrimary,
              ).px(16),
            ),
            ]
            // For existing users with face registered, show only Try Face ID Again button
            else if (_hasToken && _isFaceRegistered) ...[
              CustomAppButton(
                text: "Try Face ID Again",
                onPressed: _attemptFaceLogin,
                backgroundColor: AppColors.kAppPrimary,
                textColor: Colors.white,
              ).px(16),

              15.heightBox,

              // Optional: Add Create Account button even for logged-in users
              // (if you want to allow account switching)
              CustomAppButton(
                text: "Create New Account",
                onPressed: () => _navigateWithAnimation(() => context.goNamed(RouteNames.register.name)),
                backgroundColor: AppColors.kAppLightBrown,
                textColor: AppColors.kAppTextPrimary,
              ).px(16),
            ]
          
          ] else if (_checkingToken) ...[
            // Show loading while checking token
            const SizedBox(height: 60),
            const CircularProgressIndicator(color: AppColors.kAppLightBrown, strokeWidth: 2),
          ],

          // Add bottom padding (adjust based on whether buttons are shown)
          (_hasToken && _isFaceLoginInProgress
                  ? kToolbarHeight
                  : _hasToken && !_isFaceLoginInProgress
                  ? kToolbarHeight * 1.5
                  : kToolbarHeight * 1.5)
              .heightBox,
        ],
      ).wrapCenter(),
    ),
  );
}
