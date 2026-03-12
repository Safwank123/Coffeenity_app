import 'package:coffeenity/core/common_widgets/custom_app_scaffold.dart';
import 'package:coffeenity/core/common_widgets/custom_search_mixin.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:coffeenity/features/home/data/models/favorite_shop_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../config/constants/app_assets.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/common_widgets/custom_image_widget.dart';
import '../bloc/home_bloc.dart';
import '../widgets/shop_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SearchMixin {
  void _fetchData({bool refresh = false}) =>
      context.read<HomeBloc>().add(FetchFavouriteShops(refresh: refresh, limit: _limit));

  void _fetchMoreData() {
    final bloc = context.read<HomeBloc>();
    final state = bloc.state;

    // Only fetch more if we have more favorites and not already loading
    if (state.hasMoreFavorites && !state.isFavoritesLoadingMore) {
      bloc.add(FetchMoreFavouriteShops(limit: _limit));
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
  void onSearchChanged(String searchTerm) => context.read<HomeBloc>().add(FetchFavouriteShops(searchKey: searchTerm));
  
  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
    builder: (context, state) {
      final shops = state.favouriteShops.data;
      final isLoading = state.emitState == HomeEmitState.loading;
      final isLoadingMore = state.emitState == HomeEmitState.loadingMore || state.isFavoritesLoadingMore;
      final hasMoreFavorites = state.hasMoreFavorites;
      final shopsEmpty = shops.isEmpty && state.emitState == HomeEmitState.success;

      return CustomAppScaffold(
        controller: _scrollController,
        onRefresh: () async => _fetchData(refresh: true),
        emptyWidget: shopsEmpty && !isSearching
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("💔", style: TextStyle(fontSize: 64)),
                  Text("No favorites available", style: AppTypography.style20Bold),
                ],
              )
            : null,
        appBar: isSearching ? null : AppBar(title: CustomImageWidget(imageUrl: AppAssets.appBar, width: 200)),
        body: Column(
          children: [
            16.heightBox,
            buildSearchField().px(16),
            if (isLoading && shops.isEmpty)
              ListView.separated(
                itemCount: 5,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 16, bottom: 100, left: 16, right: 16),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => Skeletonizer(
                  enabled: true,
                  child: ShopCard(shop: FavoriteShopModel.fromJson({}).shop, isLike: false),
                ),

                separatorBuilder: (context, index) => 16.heightBox,
              )
            else
              shopsEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("💔", style: TextStyle(fontSize: 64)),
                        Text("No favorites available", style: AppTypography.style20Bold),
                      ],
                    ).wrapCenter().py(100)
                  : ListView.separated(
                itemCount: shops.length + (hasMoreFavorites ? 1 : 1),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 16, bottom: 100, left: 16, right: 16),
                itemBuilder: (context, index) {
                  if (index < shops.length) {
                    final shop = shops[index];
                    return ShopCard(shop: shop.shop, isLike: shop.isLike);
                  } else if (hasMoreFavorites) {
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
                    // No more favorites to load
                    return Padding(padding: const EdgeInsets.symmetric(vertical: 16),
                          
                        );
                  }
                },
                separatorBuilder: (context, index) => 16.heightBox,
              ),
          ],
        ),
      );
    },
  );
}
