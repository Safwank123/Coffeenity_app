import 'package:badges/badges.dart' as badges;
import 'package:coffeenity/config/colors/app_colors.dart';
import 'package:coffeenity/config/typography/app_typography.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/home/data/models/shop_model.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../common_widgets/custom_app_button.dart';
import '../common_widgets/custom_text_field.dart';
import '../utils/app_prompts.dart';

abstract class AppHelper {
  static Widget badge({required Widget child, required String value, required BuildContext context}) => badges.Badge(
    position: badges.BadgePosition.topEnd(top: -10, end: 0),
    showBadge: true,
    ignorePointer: false,
    onTap: null,
    badgeContent: Text(value, style: TextStyle(color: Colors.white)),
    badgeAnimation: const badges.BadgeAnimation.scale(
      animationDuration: Duration(seconds: 1),
      colorChangeAnimationDuration: Duration(seconds: 1),
      loopAnimation: false,
      curve: Curves.fastOutSlowIn,
      colorChangeAnimationCurve: Curves.easeInCubic,
    ),
    badgeStyle: badges.BadgeStyle(
      shape: badges.BadgeShape.circle,
      borderSide: BorderSide(color: Colors.white, width: 2),
      padding: EdgeInsets.all(5),
      elevation: 0,
      badgeColor: AppColors.kAppRed,
    ),
    child: child,
  );

  static Widget dragHandle() => Container(
    width: 50,
    height: 4,
    margin: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(color: AppColors.kAppOnSurface, borderRadius: BorderRadius.circular(2)),
  ).wrapCenter();

  static Widget emptyState({required String title, required String subtitle}) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(title, style: AppTypography.style20Bold),
      Text(subtitle, style: AppTypography.style16SemiBold),
    ],
  );

  static Widget ratingBar({required ShopModel shop, required BuildContext context}) => Row(
    children: [
      RatingBar.builder(
        allowHalfRating: true,
        initialRating: shop.rating.toDouble(),
        itemBuilder: (_, index) => const Icon(Icons.grade, color: AppColors.kAppAmber),
        onRatingUpdate: (value) => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _RateShopSheet(shop: shop, rating: value),
        ),

        itemCount: 5,
        itemSize: 24,
      ),
      4.widthBox,
      Text("(${shop.reviewCount})", style: AppTypography.style14Regular),
    ],
  );

  static void showPermissionSettingsDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Microphone Permission Required'),
      content: Text(
        'Microphone permission is permanently denied. Please enable it in your device settings to use voice ordering.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppColors.kAppWhite),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.kAppWhite),
          child: Text('Open Settings'),
        ),
      ],
    ),
  );
}

class _RateShopSheet extends StatefulWidget {
  const _RateShopSheet({required this.shop, required this.rating});

  final ShopModel shop;
  final double rating;

  @override
  State<_RateShopSheet> createState() => _RateShopSheetState();
}

class _RateShopSheetState extends State<_RateShopSheet> {
  late final TextEditingController _reviewController;
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
    _reviewController = TextEditingController();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.8,
    builder: (context, scrollController) => Container(
      decoration: BoxDecoration(color: AppColors.kAppSurface, borderRadius: BorderRadius.circular(16)),
      child: ListView(
        padding: EdgeInsets.all(16),
        controller: scrollController,
        children: [
          AppHelper.dragHandle(),
          30.heightBox,
          Text(widget.shop.name, style: AppTypography.style24SemiBold),
          Text(widget.shop.address, style: AppTypography.style16Regular),
          20.heightBox,
          RatingBar.builder(
            allowHalfRating: true,
            initialRating: _rating.toDouble(),
            itemBuilder: (_, index) => const Icon(Icons.grade, color: AppColors.kAppAmber),
            onRatingUpdate: (value) => setState(() => _rating = value),
            itemCount: 5,
            itemSize: 50,
          ),
          16.heightBox,
          CustomTextField(hintText: 'Write your review here...', maxLines: 5, controller: _reviewController),

          40.heightBox,
          BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state.emitState == HomeEmitState.reviewSubmitted) {
                Navigator.pop(context);
                AppPrompts.showSuccess(message: 'Review submitted successfully');
              }
            },
            builder: (context, state) => CustomAppButton(
              text: "Submit",
              onPressed: () => context.read<HomeBloc>().add(
                SubmitShopReview(shopId: widget.shop.id, rating: _rating, comment: _reviewController.text.trim()),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
