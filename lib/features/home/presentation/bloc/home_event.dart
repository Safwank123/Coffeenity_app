part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// --- Shop Discovery Events ---



class FetchShopDetails extends HomeEvent {
  final String shopId;

  const FetchShopDetails(this.shopId);

  @override
  List<Object?> get props => [shopId];
}

class FetchShopMenu extends HomeEvent {
  final String shopId;
  final String? searchKey;

  const FetchShopMenu({required this.shopId, this.searchKey});

  @override
  List<Object?> get props => [shopId, searchKey];
}

/// --- Order Events ---

class CreateOrder extends HomeEvent {
  final OrderRequestModel orderRequest;

  const CreateOrder(this.orderRequest);

  @override
  List<Object?> get props => [orderRequest];
}

class CheckoutOrder extends HomeEvent {
  final String orderId;

  const CheckoutOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// --- Engagement & Social Events ---

class ToggleFavourite extends HomeEvent {
  final String shopId;
  final bool isAdd;

  const ToggleFavourite({required this.shopId, required this.isAdd});

  @override
  List<Object?> get props => [shopId, isAdd];
}



class SubmitShopReview extends HomeEvent {
  final String shopId;
  final double rating;
  final String? comment;
  final String? mediaId;

  const SubmitShopReview({required this.shopId, required this.rating, this.comment, this.mediaId});

  @override
  List<Object?> get props => [shopId, rating, comment, mediaId];
}

final class FetchUserDetails extends HomeEvent {}

final class UploadVoiceOrder extends HomeEvent {
  final String filePath;
  final String shopId;

  const UploadVoiceOrder({required this.filePath, required this.shopId});

  @override
  List<Object?> get props => [filePath, shopId];
}

final class DeleteOrder extends HomeEvent {
  final String orderId;

  const DeleteOrder({required this.orderId});



  @override
  List<Object?> get props => [orderId];
}

final class ReOrder extends HomeEvent {
  final String orderId;

  const ReOrder({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
final class ViewReceipt extends HomeEvent {
  final String id;

  const ViewReceipt({required this.id});

  @override
  List<Object?> get props => [id];
}



class FetchNearbyShops extends HomeEvent {
  final bool showLoader;
  final bool refresh;
  final double? lat;
  final double? lng;
  final String? searchKey;
  final int? limit;

  const FetchNearbyShops({
    this.showLoader = true,
    this.refresh = false,
    this.lat,
    this.lng,
    this.searchKey,
    this.limit,
  });

  @override
  List<Object?> get props => [showLoader, refresh, lat, lng, searchKey, limit];
}

class FetchMoreNearbyShops extends HomeEvent {
  final int? limit;

  const FetchMoreNearbyShops({this.limit});

  @override
  List<Object?> get props => [limit];
}

class ResetNearbyShopsPagination extends HomeEvent {
  const ResetNearbyShopsPagination();
}

class FetchOrderList extends HomeEvent {
  final bool refresh;
  final String? id;
  final int? offset;
  final String? search;

  const FetchOrderList({this.refresh = false, this.id, this.offset, this.search});

  @override
  List<Object?> get props => [refresh, id, offset, search];
}

class FetchMoreOrders extends HomeEvent {
  final int? limit;

  const FetchMoreOrders({this.limit});

  @override
  List<Object?> get props => [limit];
}

class ResetOrdersPagination extends HomeEvent {
  const ResetOrdersPagination();
}

class FetchFavouriteShops extends HomeEvent {
  final bool showLoader;
  final bool refresh;
  final int? limit;
  final String? searchKey;

  const FetchFavouriteShops({this.showLoader = true, this.refresh = false, this.limit, this.searchKey});

  @override
  List<Object?> get props => [showLoader, refresh, limit, searchKey];
}

class FetchMoreFavouriteShops extends HomeEvent {
  final int? limit;

  const FetchMoreFavouriteShops({this.limit});

  @override
  List<Object?> get props => [limit];
}

class ResetFavouritesPagination extends HomeEvent {
  const ResetFavouritesPagination();
}
