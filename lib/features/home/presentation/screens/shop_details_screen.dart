import 'package:coffeenity/config/colors/app_colors.dart';
import 'package:coffeenity/core/common_widgets/custom_image_widget.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:coffeenity/core/helper/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/utils/app_prompts.dart';
import '../../data/models/shop_model.dart';

class ShopDetailsScreen extends StatefulWidget {
  const ShopDetailsScreen({super.key, required this.shop});
  final ShopModel shop;

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;
    return DraggableScrollableSheet(
      initialChildSize: .9,
      builder: (context, scrollController) => Container(
        color: AppColors.kAppCardColor,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.heightBox,
              // Drag handle
              AppHelper.dragHandle(),
              15.heightBox,
              if (shop.images.isNotEmpty)
              PageView.builder(
                padEnds: false,
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                  itemBuilder: (context, index) => CustomImageWidget(imageUrl: shop.images[index].media.url),
                  itemCount: shop.images.length,
              ).h(250),
              Text(shop.name, style: AppTypography.style20Bold).pOnly(left: 16, right: 16, top: 16, bottom: 8),
              Text(
                "Copperline Coffee is a coffee shop with locations in the heart of Port Orange and Daytona Beach, Florida. We aim to bring small-town charm to coffee culture. Comfortable coffeehouse offering ample seating and healthy options, plus a children's playground.",
                style: AppTypography.style14Regular,
              ).pOnly(left: 16, right: 16, bottom: 4),
              if (shop.website != null)
              GestureDetector(
                onTap: () async {
                  try {
                      await launchUrl(Uri.parse(shop.website!));
                  } catch (e) {
                    AppPrompts.showError(message: e.toString());
                  }
                },
                child: Text(
                    shop.website!,
                  style: AppTypography.style14Regular.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                  ),
                ).pOnly(left: 16, right: 16, top: 8, bottom: 4),
              ),

              Row(
                children: [
                  Text("Rate this coffee shop:", style: AppTypography.style16SemiBold).expanded(),
                  12.widthBox,
                
                  AppHelper.ratingBar(shop: shop, context: context),
                ],
              ).pOnly(left: 16, right: 16, top: 8, bottom: 4),
              20.heightBox,
              OutlinedButton(
                onPressed: () => context.pushNamed(RouteNames.aiOrder.name, queryParameters: {'shopId': shop.id}),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color(0xFFC0703B),
                  side: const BorderSide(color: AppColors.kAppWhite),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text('Order with AI', style: AppTypography.style14Bold.copyWith(color: AppColors.kAppWhite)),
              ).px(16),
            ],
          ),
        ),
      ),
    );
  }
}
