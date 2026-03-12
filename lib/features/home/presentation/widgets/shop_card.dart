import 'package:coffeenity/config/routes/app_routes.dart';
import 'package:coffeenity/core/common_widgets/custom_image_widget.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:coffeenity/features/home/presentation/screens/shop_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/helper/app_helper.dart';
import '../../data/models/shop_model.dart';
import '../bloc/home_bloc.dart';

class ShopCard extends StatelessWidget {
  final ShopModel shop;
  final bool isLike;

  const ShopCard({super.key, required this.shop, required this.isLike});

  @override
  Widget build(BuildContext context) {
    final shopImage = shop.images.firstOrNull?.media.url ?? '';
    return InkWell(
    onTap: () => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShopDetailsScreen(shop: shop),
    ),
    child: Card(
      color: AppColors.kAppCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Image / Gallery
          
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CustomImageWidget(imageUrl: shopImage),
            ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shop.name, style: AppTypography.style20Bold),
                AppHelper.ratingBar(shop: shop, context: context),
              ],
            ).pOnly(left: 16, right: 16, top: 8, bottom: 4),

          // Address
            if (shop.address.isNotEmpty)
          Text(
            shop.address,
            style: AppTypography.style14Regular.copyWith(color: AppColors.kAppWhite.withValues(alpha: 0.8)),
          ).pOnly(left: 16, right: 16, top: 8, bottom: 4),
            if (shop.phone.isNotEmpty)
          // Phone Number
          Text(
            shop.phone,
            style: AppTypography.style14Regular.copyWith(color: AppColors.kAppWhite.withValues(alpha: 0.8)),
          ).px(16),

          16.heightBox,

          // "Learn More" Button and Heart Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                  onPressed: () => context.pushNamed(RouteNames.aiOrder.name, queryParameters: {'shopId': shop.id}),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color(0xFFC0703B),
                  side: const BorderSide(color: AppColors.kAppWhite),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text('Order with AI', style: AppTypography.style14Bold.copyWith(color: AppColors.kAppWhite)),
              ),
              IconButton(
                  onPressed: () => context.read<HomeBloc>().add(ToggleFavourite(shopId: shop.id, isAdd: !isLike)),
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.kAppWhite,
                    backgroundColor: isLike ? AppColors.kAppHeart : AppColors.kAppWhite,
                  shape: const CircleBorder(side: BorderSide(color: AppColors.kAppHeart)),
                ),
                icon: Icon(
                    isLike ? Icons.favorite : Icons.favorite_border,
                    color: isLike ? AppColors.kAppWhite : AppColors.kAppHeart,
                ),
              ),
            ],
          ).px(16),
        ],
      ).pOnly(bottom: 16),
    ),
  );
  }
}

