part of 'home_bloc.dart';


class HomeState extends Equatable {
  const HomeState({
    this.emitState = HomeEmitState.success,
    this.nearbyShops = const ApiListResponse(),
    this.favouriteShops = const ApiListResponse(),
    this.orderList = const ApiListResponse(),
    this.shopMenu = const ApiListResponse(),
    this.userDetails = const ApiResponse(),
    this.voiceOrder = const ApiResponse(),
    this.paymentLink,
    this.hasMoreOrders = true,
    this.hasMoreNearbyShops = true,
    this.hasMoreFavorites = true,
    this.isOrdersLoadingMore = false,
    this.isNearbyShopsLoadingMore = false,
    this.isFavoritesLoadingMore = false,
  });

  final HomeEmitState emitState;
  final ApiListResponse<ShopModel> nearbyShops;
  final ApiListResponse<FavoriteShopModel> favouriteShops;
  final ApiListResponse<OrderModel> orderList;
  final ApiListResponse<ShopMenuModel> shopMenu;
  final ApiResponse<UserModel> userDetails;
  final ApiResponse<VoiceOrderModel> voiceOrder;
  final String? paymentLink;

  // Pagination states
  final bool hasMoreOrders;
  final bool hasMoreNearbyShops;
  final bool hasMoreFavorites;
  final bool isOrdersLoadingMore;
  final bool isNearbyShopsLoadingMore;
  final bool isFavoritesLoadingMore;

  HomeState copyWith({
    HomeEmitState? emitState,
    ApiListResponse<ShopModel>? nearbyShops,
    ApiListResponse<FavoriteShopModel>? favouriteShops,
    ApiListResponse<OrderModel>? orderList,
    ApiListResponse<ShopMenuModel>? shopMenu,
    ApiResponse<UserModel>? userDetails,
    String? paymentLink,
    ApiResponse<VoiceOrderModel>? voiceOrder,
    bool? hasMoreOrders,
    bool? hasMoreNearbyShops,
    bool? hasMoreFavorites,
    bool? isOrdersLoadingMore,
    bool? isNearbyShopsLoadingMore,
    bool? isFavoritesLoadingMore,
  }) => HomeState(
    emitState: emitState ?? this.emitState,
    nearbyShops: nearbyShops ?? this.nearbyShops,
    favouriteShops: favouriteShops ?? this.favouriteShops,
    orderList: orderList ?? this.orderList,
    shopMenu: shopMenu ?? this.shopMenu,
    userDetails: userDetails ?? this.userDetails,
    paymentLink: paymentLink,
    voiceOrder: voiceOrder ?? this.voiceOrder,
    hasMoreOrders: hasMoreOrders ?? this.hasMoreOrders,
    hasMoreNearbyShops: hasMoreNearbyShops ?? this.hasMoreNearbyShops,
    hasMoreFavorites: hasMoreFavorites ?? this.hasMoreFavorites,
    isOrdersLoadingMore: isOrdersLoadingMore ?? this.isOrdersLoadingMore,
    isNearbyShopsLoadingMore: isNearbyShopsLoadingMore ?? this.isNearbyShopsLoadingMore,
    isFavoritesLoadingMore: isFavoritesLoadingMore ?? this.isFavoritesLoadingMore,
  );

  @override
  List<Object?> get props => [
    emitState,
    nearbyShops,
    favouriteShops,
    orderList,
    shopMenu,
    userDetails,
    voiceOrder,
    hasMoreOrders,
    hasMoreNearbyShops,
    hasMoreFavorites,
    isOrdersLoadingMore,
    isNearbyShopsLoadingMore,
    isFavoritesLoadingMore,
  ];
}

enum HomeEmitState {
  loading,
  loadingMore,
  success,
  orderCreated,
  checkoutOrderSuccess,
  reviewSubmitted,
  orderFetched,
  orderDeleted,
  reOrderSuccess,
}
