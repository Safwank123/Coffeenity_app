import 'package:coffeenity/config/typography/app_typography.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:coffeenity/core/helper/app_helper.dart';
import 'package:coffeenity/features/home/data/models/shop_menu_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../config/colors/app_colors.dart';
import '../bloc/home_bloc.dart';

class ShopMenuScreen extends StatefulWidget {
  const ShopMenuScreen({super.key, required this.shopId, this.isRecordingActive = false, required this.onPressed});
  final String shopId;
  final bool isRecordingActive;
  final VoidCallback onPressed;

  @override
  State<ShopMenuScreen> createState() => _ShopMenuScreenState();
}

class _ShopMenuScreenState extends State<ShopMenuScreen> {
  void _fetchData() => context.read<HomeBloc>().add(FetchShopMenu(shopId: widget.shopId));

  @override
  void initState() {
    super.initState();
    _fetchData();
    _isRecordingActive = widget.isRecordingActive;
  }

  bool _isRecordingActive = false;

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
    builder: (context, state) {
      final menus = state.shopMenu.data;
      final shop = state.nearbyShops.data.firstWhereOrNull((shop) => shop.id == widget.shopId);
      return DraggableScrollableSheet(
        initialChildSize: .9,
        builder: (context, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: GestureDetector(
              onTap: () {
                setState(() => _isRecordingActive = !_isRecordingActive);
                widget.onPressed.call();
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecordingActive ? AppColors.kAppError : AppColors.kAppPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecordingActive ? AppColors.kAppError : AppColors.kAppPrimary).withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 16),
                child: Icon(_isRecordingActive ? Icons.stop : Icons.mic, size: 40, color: AppColors.kAppWhite),
              ),
            ),
            // decoration: BoxDecoration(color: AppColors.kAppSurface, borderRadius: BorderRadius.circular(16)),
            body: RefreshIndicator(
              onRefresh: () async => _fetchData(),
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                controller: scrollController,
                children: [
                  AppHelper.dragHandle(),
                  30.heightBox,
                  if (shop != null) ...[
                    Text(shop.name, style: AppTypography.style24SemiBold),
                    Text(shop.address, style: AppTypography.style16Regular),
                  ],
                  menus.isEmpty && state.emitState == HomeEmitState.success
                      ? AppHelper.emptyState(title: 'No menus found', subtitle: 'Try again later').py(200)
                      : ListView.separated(
                          itemBuilder: (context, index) {
                            final menu = menus.isEmpty ? ShopMenuModel.fromJson({}) : menus[index];
                            return Skeletonizer(
                              enabled: state.emitState == HomeEmitState.loading,
                              child: EnhancedMenuExpansionTile(menu: menu),
                            );
                          },
                          separatorBuilder: (_, _) => 16.heightBox,
                          itemCount: menus.isEmpty ? 5 : menus.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: NeverScrollableScrollPhysics(),
                        ),
                ],
              ),
            ),
          ),
        )
      );
    },
  );
}


class EnhancedMenuExpansionTile extends StatelessWidget {
  final ShopMenuModel menu;
  final VoidCallback? onAddToCart;
  final VoidCallback? onCustomize;
  final Function(double)? onRatingUpdate;

  const EnhancedMenuExpansionTile({
    super.key,
    required this.menu,
    this.onAddToCart,
    this.onCustomize,
    this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.kAppCardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: AppColors.kAppBlack.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    ),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.only(bottom: 16),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu Image with Badge
            if (menu.hasMedia && menu.primaryMedia != null)
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        menu.primaryMedia!.url,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                            ? child
                            : Container(
                                color: AppColors.kAppOffWhite,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                      ),
                    ),
                    // Popular Badge
                    if (menu.reviewCount > 50)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.kAppAmber,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: AppColors.kAppBlack.withValues(alpha: 0.1), blurRadius: 4)],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department, size: 12, color: AppColors.kAppWhite),
                              SizedBox(width: 2),
                              Text('Popular', style: AppTypography.style10Bold),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Menu Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menu.name,
                              style: AppTypography.style16SemiBold.copyWith(fontSize: 17, color: AppColors.kAppWhite),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            6.heightBox,
                            // Category Chips
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (menu.category.name.isNotEmpty)
                                  _buildCategoryChip(
                                    menu.category.name,
                                    AppColors.kAppPrimary.withValues(alpha: 0.1),
                                    AppColors.kAppWhite,
                                  ),
                                if (menu.subCategory.name.isNotEmpty)
                                  _buildCategoryChip(
                                    menu.subCategory.name,
                                    AppColors.kAppSuccess.withValues(alpha: 0.1),
                                    AppColors.kAppWhite,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.kAppSuccess.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          menu.formattedPrice,
                          style: AppTypography.style18Bold.copyWith(color: AppColors.kAppWhite, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  8.heightBox,

                  // Price and Rating Row
                  if (menu.rating != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.kAppAmber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: AppColors.kAppWhite, size: 16),
                          4.widthBox,
                          Text(
                            menu.rating!.toStringAsFixed(1),
                            style: AppTypography.style14SemiBold.copyWith(color: AppColors.kAppWhite),
                          ),
                          2.widthBox,
                          Text(
                            '(${menu.reviewCount})',
                            style: AppTypography.style12Regular.copyWith(
                              color: AppColors.kAppWhite.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        // Description
        subtitle: menu.description.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  menu.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.style14Regular.copyWith(
                    color: AppColors.kAppWhite.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              )
            : null,

        // Trailing Arrow
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: AppColors.kAppWhite.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Icons.keyboard_arrow_down, color: AppColors.kAppWhite, size: 20),
        ),

        children: [
          // Divider
          Divider(height: 1, color: AppColors.kAppWhite.withValues(alpha: 0.1), thickness: 0.5),
          16.heightBox,
          // Media Gallery
          if (menu.hasMedia) _buildMediaGallery(context),

          // Variants Section
          if (menu.hasVariants) _buildVariantsSection(context),
        ],
      ),
    ),
  );

  Widget _buildCategoryChip(String label, Color color, Color textColor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.kAppWhite.withValues(alpha: 0.2), width: 1),
    ),
    child: Text(label, style: AppTypography.style10SemiBold.copyWith(color: textColor, letterSpacing: 0.2)),
  );

  Widget _buildMediaGallery(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.photo_library, size: 18, color: AppColors.kAppWhite),
          8.widthBox,
          Text('Gallery', style: AppTypography.style14SemiBold.copyWith(color: AppColors.kAppWhite)),
          const Spacer(),
          Text(
            '${menu.medias.length} photos',
            style: AppTypography.style12Regular.copyWith(color: AppColors.kAppWhite.withValues(alpha: 0.7)),
          ),
        ],
      ).px(20),
      12.heightBox,
      SizedBox(
        height: 180,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: menu.medias.length,
          itemBuilder: (context, index) => Container(
            width: 140,
            margin: EdgeInsets.only(right: index == menu.medias.length - 1 ? 0 : 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                menu.medias[index].url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                    ? child
                    : Container(
                        color: AppColors.kAppOffWhite,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
              ),
            ),
          ),
        ),
      ),
      20.heightBox,
    ],
  );

  Widget _buildVariantsSection(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.settings_suggest, size: 18, color: AppColors.kAppWhite),
          8.widthBox,
          Text('Customization Group', style: AppTypography.style14SemiBold.copyWith(color: AppColors.kAppWhite)),
        ],
      ).px(20),
      12.heightBox,
      ...menu.variants.map(
        (variant) => Container(
          margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.kAppCardColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.kAppWhite.withValues(alpha: 0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(variant.name, style: AppTypography.style14SemiBold.copyWith(color: AppColors.kAppWhite)),
                  const Spacer(),
                  if (variant.hasCustomizationGroups)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.kAppWhite.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${variant.customizationGroups.length} options',
                        style: AppTypography.style10SemiBold.copyWith(color: AppColors.kAppWhite),
                      ),
                    ),
                ],
              ),
              if (variant.description != null) ...[
                6.heightBox,
                Text(
                  variant.description!,
                  style: AppTypography.style12Regular.copyWith(color: AppColors.kAppWhite.withValues(alpha: 0.7)),
                ),
              ],
              if (variant.hasCustomizationGroups)
                ...variant.customizationGroups.map(
                  (group) => Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      title: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(color: AppColors.kAppWhite, shape: BoxShape.circle),
                          ),
                          12.widthBox,
                          Text(group.name, style: AppTypography.style14SemiBold.copyWith(color: AppColors.kAppWhite)),
                        ],
                      ),
                      subtitle: Text('${group.options?.length ?? 0} options'),
                      children: [
                        ...group.options!.map(
                          (option) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            minLeadingWidth: 0,
                            title: Text(
                              option.name,
                              style: AppTypography.style14Regular.copyWith(color: AppColors.kAppWhite),
                            ),
                            subtitle: option.description != null
                                ? Text(
                                    option.description!,
                                    style: AppTypography.style12Regular.copyWith(
                                      color: AppColors.kAppWhite.withValues(alpha: 0.7),
                                    ),
                                  )
                                : null,
                            trailing: Text(
                              '+ \$${option.price}',
                              style: AppTypography.style12SemiBold.copyWith(color: Colors.green),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      8.heightBox,
    ],
  );
}
