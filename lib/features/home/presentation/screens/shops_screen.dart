import 'package:coffeenity/config/typography/app_typography.dart';
import 'package:coffeenity/core/common_widgets/custom_app_scaffold.dart';
import 'package:coffeenity/core/common_widgets/custom_search_mixin.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:coffeenity/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/constants/app_assets.dart';
import '../../../../core/common_widgets/custom_image_widget.dart';
import '../../../../core/helper/app_helper.dart';
import '../../data/models/shop_model.dart';
import '../widgets/shop_card.dart';

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({super.key});

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> with SearchMixin {
  void _fetchData({bool refresh = false}) =>
      context.read<HomeBloc>().add(FetchNearbyShops(refresh: refresh, limit: _limit));

  void _fetchMoreData() {
    final bloc = context.read<HomeBloc>();
    final state = bloc.state;

    // Only fetch more if we have more shops and not already loading
    if (state.hasMoreNearbyShops && !state.isNearbyShopsLoadingMore) {
      bloc.add(FetchMoreNearbyShops(limit: _limit));
    }
  }

  late final ScrollController _scrollController;
  final int _limit = 10; // Items per page

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchData();
  }

  void _scrollListener() {
    // Load more when near bottom
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _fetchMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  @override
  void onSearchChanged(String searchTerm) => context.read<HomeBloc>().add(FetchNearbyShops(searchKey: searchTerm));
  

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
    builder: (context, state) {
      final shops = state.nearbyShops.data;
      final isLoadingMore = state.emitState == HomeEmitState.loadingMore || state.isNearbyShopsLoadingMore;
      final hasMoreShops = state.hasMoreNearbyShops;
      final shopsEmpty = shops.isEmpty && state.emitState == HomeEmitState.success && searchController.text.isNotEmpty;

      return CustomAppScaffold(
        controller: _scrollController,
        onRefresh: () async => _fetchData(refresh: true),
        appBar: isSearching
            ? null
            : AppBar(
          title: Hero(
            tag: "logo",
            child: CustomImageWidget(imageUrl: AppAssets.appBar, width: 200),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchField(),
            16.heightBox,
            if (!isSearching) ...[
              Text("AI-Prompted Coffee Shops", style: AppTypography.style24Bold),
            5.heightBox,
            Text.rich(
              TextSpan(
                text: 'These newly discovered coffee shops just might be your cup of ',
                style: AppTypography.style16Regular,
                children: <TextSpan>[
                  TextSpan(
                    text: 'tea',
                    style: AppTypography.style18Regular.copyWith(
                      color: AppColors.kAppRed,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  TextSpan(text: ' coffee. ☕'),
                ],
              ),
            ),
            16.heightBox,
            ],

            if (shops.isEmpty && !shopsEmpty)
              ListView.separated(
                itemCount: 5,
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 100),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) =>
                    Skeletonizer(enabled: true, child: ShopCard(shop: ShopModel.fromJson({}), isLike: false)),
                separatorBuilder: (context, index) => 16.heightBox,
              )
            else
              shopsEmpty
                  ? AppHelper.emptyState(
                      title: "No shops found",
                      subtitle: "We couldn't find any shops near you.",
                    ).wrapCenter().py(100)
                  : ListView.separated(
                itemCount: shops.length + (hasMoreShops ? 1 : 1),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                itemBuilder: (context, index) {
                  if (index < shops.length) {
                    final shop = shops[index];
                    return ShopCard(shop: shop, isLike: shop.isLiked);
                  } else if (hasMoreShops) {
                    // Show loading indicator at the bottom
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: isLoadingMore
                            ? CircularProgressIndicator()
                            : IconButton(icon: Icon(Icons.refresh), onPressed: _fetchMoreData),
                      ),
                    );
                  } else {
                    // No more shops to load
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No more shops',
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                    );
                  }
                },
                separatorBuilder: (context, index) => 16.heightBox,
              ),
          ],
        ).pAll(16),
      );
    },
  );
}
