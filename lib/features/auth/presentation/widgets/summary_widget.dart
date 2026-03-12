import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/material.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/typography/app_typography.dart';

class SummaryWidget extends StatefulWidget {
  const SummaryWidget({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.zipCode,
    required this.coffees,
    required this.shareLocation,
    required this.onChanged,
    required this.selectedCoffeeShops,
    required this.onUserInfoTap,
    required this.onCoffeeFlavorsTap,
    required this.onCoffeeShopsTap,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String zipCode;
  final bool shareLocation;
  final ValueChanged<bool> onChanged;
  final List<String> coffees;
  final List<String> selectedCoffeeShops;
  final VoidCallback onUserInfoTap;
  final VoidCallback onCoffeeFlavorsTap;
  final VoidCallback onCoffeeShopsTap;

  @override
  State<SummaryWidget> createState() => _SummaryWidgetState();
}

class _SummaryWidgetState extends State<SummaryWidget> with TickerProviderStateMixin {
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
    const int totalFields = 5;

    _animationControllers = List.generate(
      totalFields,
      (index) => AnimationController(
        duration: Duration(milliseconds: baseDuration + (index * staggerDelay)),
        vsync: this,
      )
    );

    _fadeAnimations = _animationControllers
        .map(
          (controller) =>
              Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();

    _slideAnimations = _animationControllers
        .map(
          (controller) => Tween<Offset>(
        begin: const Offset(0.0, 0.9),
        end: Offset.zero,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();

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
      16.heightBox,
      _buildAnimatedUserInfo(),
      20.heightBox,
      _buildAnimatedCoffeeFlavors(),
      // 20.heightBox,
      // _buildAnimatedCoffeeShops(),
      20.heightBox,
      _buildAnimatedLocationSetting(),
      
      150.heightBox,
    ],
  );

  Widget _buildAnimatedTitle() => FadeTransition(
    opacity: _fadeAnimations[0],
    child: SlideTransition(
      position: _slideAnimations[0],
      child: Text("Profile Summary", style: AppTypography.style24Bold),
    ),
  );

  Widget _buildAnimatedUserInfo() => FadeTransition(
    opacity: _fadeAnimations[1],
    child: SlideTransition(
      position: _slideAnimations[1],
      child: GestureDetector(
        onTap: widget.onUserInfoTap,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.kAppWhite, borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            title: Text("User Info", style: AppTypography.style18Bold.copyWith(color: AppColors.kAppBlack)),
            trailing: Icon(Icons.person_outline, color: AppColors.kAppSecondary, size: 30),
            subtitle: Text(
              "Name:${widget.firstName} ${widget.lastName}\nEmail:${widget.email}\nPhone:${widget.phoneNumber}\nZip:${widget.zipCode}",
              style: AppTypography.style14Regular.copyWith(color: AppColors.kAppBlack.withValues(alpha: .5)),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildAnimatedCoffeeFlavors() => FadeTransition(
    opacity: _fadeAnimations[2],
    child: SlideTransition(
      position: _slideAnimations[2],
      child: GestureDetector(
        onTap: widget.onCoffeeFlavorsTap,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.kAppWhite, borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            title: Text("Coffee Flavors", style: AppTypography.style18Bold.copyWith(color: AppColors.kAppBlack)),
            trailing: Icon(Icons.coffee_outlined, color: AppColors.kAppSecondary, size: 30),
          subtitle: Text(
            widget.coffees.map((e) => e).join(", "),
            style: AppTypography.style14Regular.copyWith(color: AppColors.kAppBlack.withValues(alpha: .5)),
          ),
        ),
      ),
      ),
    ),
  );

  // Widget _buildAnimatedCoffeeShops() => FadeTransition(
  //   opacity: _fadeAnimations[3],
  //   child: SlideTransition(
  //     position: _slideAnimations[3],
  //     child: GestureDetector(
  //       onTap: widget.onCoffeeShopsTap,
  //       child: Container(
  //         padding: EdgeInsets.all(16),
  //         decoration: BoxDecoration(color: AppColors.kAppWhite, borderRadius: BorderRadius.circular(15)),
  //         child: ListTile(
  //           title: Text("Coffee Shops", style: AppTypography.style18Bold.copyWith(color: AppColors.kAppBlack)),
  //           trailing: Icon(Icons.store_mall_directory_outlined, color: AppColors.kAppSecondary, size: 30),
  //         subtitle: Text(
  //           widget.selectedCoffeeShops.map((e) => e).join(", "),
  //           style: AppTypography.style14Regular.copyWith(color: AppColors.kAppBlack.withValues(alpha: .5)),
  //         ),
  //       ),
  //     ),
  //     ),
  //   ),
  // );

  Widget _buildAnimatedLocationSetting() => FadeTransition(
    opacity: _fadeAnimations[4],
    child: SlideTransition(
      position: _slideAnimations[4],
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.kAppWhite, borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          title: Text("Share Location", style: AppTypography.style18Bold.copyWith(color: AppColors.kAppBlack)),
          trailing: Switch(
            value: widget.shareLocation,
            onChanged: widget.onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
            activeThumbColor: AppColors.kAppSecondary,
          ),
          subtitle: Text(
            "Let me know when a shop has coffee that matches my taste",
            style: AppTypography.style14Regular.copyWith(color: AppColors.kAppBlack.withValues(alpha: .5)),
          ),
        ),
      ),
    ),
  );
}
