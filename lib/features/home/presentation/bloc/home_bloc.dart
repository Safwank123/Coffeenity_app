import 'dart:io';

import 'package:coffeenity/core/utils/api_response_handler.dart';
import 'package:coffeenity/core/utils/app_prompts.dart';
import 'package:coffeenity/core/utils/location_services.dart';
import 'package:coffeenity/features/home/data/models/shop_menu_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:path_provider/path_provider.dart' as path_provider;
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../../../core/utils/app_log.dart';
import '../../data/models/favorite_shop_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_request_model.dart';
import '../../data/models/shop_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repository/home_repository.dart';
import '../screens/voice_order_model.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;
  
  // Pagination tracking variables
  int _ordersPage = 0;
  int _nearbyShopsPage = 0;
  int _favoritesPage = 0;
  bool _hasMoreOrders = true;
  bool _hasMoreNearbyShops = true;
  bool _hasMoreFavorites = true;
  bool _isOrdersLoadingMore = false;
  bool _isNearbyShopsLoadingMore = false;
  bool _isFavoritesLoadingMore = false;
  double? _currentLat;
  double? _currentLng;
  
  HomeBloc(this._homeRepository) : super(const HomeState()) {
    on<ReOrder>(_onReOrder);
    on<DeleteOrder>(_onDeleteOrder);
    on<ViewReceipt>(_onViewReceipt);
    on<CreateOrder>(_onCreateOrder);
    on<CheckoutOrder>(_onCheckoutOrder);
    on<FetchShopMenu>(_onFetchShopMenu);
    on<FetchOrderList>(_onFetchOrderList);
    on<FetchMoreOrders>(_onFetchMoreOrders);
    on<ToggleFavourite>(_onToggleFavourite);
    on<FetchNearbyShops>(_onFetchNearbyShops);
    on<SubmitShopReview>(_onSubmitShopReview);
    on<FetchUserDetails>(_onFetchUserDetails);
    on<UploadVoiceOrder>(_onUploadVoiceOrder);
    on<FetchFavouriteShops>(_onFetchFavouriteShops);
    on<FetchMoreNearbyShops>(_onFetchMoreNearbyShops);
    on<ResetOrdersPagination>(_onResetOrdersPagination);
    on<FetchMoreFavouriteShops>(_onFetchMoreFavouriteShops);
    on<ResetFavouritesPagination>(_onResetFavouritesPagination);
    on<ResetNearbyShopsPagination>(_onResetNearbyShopsPagination);
  }

 
  Future<void> _onFetchNearbyShops(FetchNearbyShops event, Emitter<HomeState> emit) async {
    // Reset pagination when fetching fresh shops or location changed
    if (event.refresh) {
      _nearbyShopsPage = 0;
      _hasMoreNearbyShops = true;
      _isNearbyShopsLoadingMore = false;
      _currentLat = event.lat;
      _currentLng = event.lng;
    }

    if (event.showLoader || event.refresh) {
      emit(state.copyWith(emitState: HomeEmitState.loading, isNearbyShopsLoadingMore: false));
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    Position? position;
    if (event.lat == null || event.lng == null) {
      try {
        position = await LocationService().fetchLocation();
        _currentLat = position?.latitude;
        _currentLng = position?.longitude;
      } catch (e) {
        AppLog.errorLog('Failed to fetch location', e);
        AppPrompts.showError(message: e.toString());
      }
    }

    final response = await _homeRepository.getNearbyShops(
      lat: event.lat ?? position?.latitude,
      lng: event.lng ?? position?.longitude,
      limit: event.limit ?? 10,
      offset: _nearbyShopsPage,
      search: event.searchKey,
    );

    // Check if there are more shops to load
    _hasMoreNearbyShops = response.pagination.totalCount >= (event.limit ?? 10);

    emit(
      state.copyWith(
        nearbyShops: response,
        isNearbyShopsLoadingMore: false,
        emitState: HomeEmitState.success,
        hasMoreNearbyShops: _hasMoreNearbyShops,
      ),
    );
  }

  Future<void> _onFetchMoreNearbyShops(FetchMoreNearbyShops event, Emitter<HomeState> emit) async {
    // If already loading more or no more shops, return
    if (_isNearbyShopsLoadingMore || !_hasMoreNearbyShops) return;

    _isNearbyShopsLoadingMore = true;
    _nearbyShopsPage = state.nearbyShops.data.length;

    emit(state.copyWith(emitState: HomeEmitState.loadingMore, isNearbyShopsLoadingMore: true));

    Position? position;
    if (_currentLat == null || _currentLng == null) {
      try {
        position = await LocationService().fetchLocation();
        _currentLat = position?.latitude;
        _currentLng = position?.longitude;
      } catch (e) {
        AppLog.errorLog('Failed to fetch location', e);
        _isNearbyShopsLoadingMore = false;
        emit(state.copyWith(emitState: HomeEmitState.success));
        return;
      }
    }

    final newShops = await _homeRepository.getNearbyShops(
      lat: _currentLat ?? position?.latitude,
      lng: _currentLng ?? position?.longitude,
      limit: event.limit ?? 10,
      offset: _nearbyShopsPage,
    );

    // Check if there are more shops to load
    _hasMoreNearbyShops = newShops.pagination.totalCount >= (event.limit ?? 10);

    // Combine existing shops with new shops
    final existingShops = state.nearbyShops.data;
    final allShops = [...existingShops, ...newShops.data];

    _isNearbyShopsLoadingMore = false;

    emit(
      state.copyWith(
        emitState: HomeEmitState.success,
        nearbyShops: ApiListResponse<ShopModel>(success: newShops.success, data: allShops),
        hasMoreNearbyShops: _hasMoreNearbyShops,
        isNearbyShopsLoadingMore: false,
      ),
    );
  }

  Future<void> _onResetNearbyShopsPagination(ResetNearbyShopsPagination event, Emitter<HomeState> emit) async {
    _nearbyShopsPage = 0;
    _hasMoreNearbyShops = true;
    _isNearbyShopsLoadingMore = false;
    _currentLat = null;
    _currentLng = null;

    emit(state.copyWith(hasMoreNearbyShops: true, isNearbyShopsLoadingMore: false));
  }

  Future<void> _onFetchShopMenu(FetchShopMenu event, Emitter<HomeState> emit) async {
    emit(state.copyWith(emitState: HomeEmitState.loading));
    await Future.delayed(const Duration(milliseconds: 500));
    final response = await _homeRepository.getShopMenu(shopId: event.shopId, searchKey: event.searchKey);
    emit(state.copyWith(emitState: HomeEmitState.success, shopMenu: response));
  }

  Future<void> _onFetchOrderList(FetchOrderList event, Emitter<HomeState> emit) async {
    // Reset pagination when fetching fresh orders or search changed
    if (event.refresh) {
      _ordersPage = 0;
      _hasMoreOrders = true;
      _isOrdersLoadingMore = false;
    }

    emit(state.copyWith(emitState: HomeEmitState.loading, isOrdersLoadingMore: false));
    await Future.delayed(const Duration(milliseconds: 500));
    
    final response = await _homeRepository.getOrders(
      id: event.id,
      offset: _ordersPage,
      limit: 10,
      search: event.search,
    );

    // Check if there are more orders to load
    _hasMoreOrders = response.pagination.totalCount >= 10;

    emit(
      state.copyWith(
        emitState: HomeEmitState.success,
        orderList: response,
        hasMoreOrders: _hasMoreOrders,
        isOrdersLoadingMore: false,
      ),
    );
  }

  Future<void> _onFetchMoreOrders(FetchMoreOrders event, Emitter<HomeState> emit) async {
    // If already loading more or no more orders, return
    if (_isOrdersLoadingMore || !_hasMoreOrders) return;

    _isOrdersLoadingMore = true;
    _ordersPage = state.orderList.data.length;

    emit(state.copyWith(emitState: HomeEmitState.loadingMore, isOrdersLoadingMore: true));

    final newOrders = await _homeRepository.getOrders(limit: 10, offset: _ordersPage);

    // Check if there are more orders to load
    _hasMoreOrders = newOrders.pagination.totalCount >= 10;

    // Combine existing orders with new orders
    final existingOrders = state.orderList.data;
    final allOrders = [...existingOrders, ...newOrders.data];

    _isOrdersLoadingMore = false;

    emit(
      state.copyWith(
        emitState: HomeEmitState.success,
        orderList: ApiListResponse<OrderModel>(success: newOrders.success, data: allOrders),
        hasMoreOrders: _hasMoreOrders,
        isOrdersLoadingMore: false,
      ),
    );
  }

  Future<void> _onResetOrdersPagination(ResetOrdersPagination event, Emitter<HomeState> emit) async {
    _ordersPage = 0;
    _hasMoreOrders = true;
    _isOrdersLoadingMore = false;

    emit(state.copyWith(hasMoreOrders: true, isOrdersLoadingMore: false));
  }

  Future<void> _onCreateOrder(CreateOrder event, Emitter<HomeState> emit) async {
    emit(state.copyWith(emitState: HomeEmitState.loading));
    final response = await _homeRepository.createOrder(orderRequestModel: event.orderRequest);
    if (response.success) {
      String? paymentLink;
      try {
        paymentLink = response.data;
      } catch (_) {}
      emit(state.copyWith(emitState: HomeEmitState.orderCreated, paymentLink: paymentLink));
      add(FetchOrderList(refresh: true));
    }
    emit(state.copyWith(emitState: HomeEmitState.success));
  }

  Future<void> _onCheckoutOrder(CheckoutOrder event, Emitter<HomeState> emit) async {
    emit(state.copyWith(emitState: HomeEmitState.loading));
    final response = await _homeRepository.checkoutOrder(orderId: event.orderId);
    if (response.success) emit(state.copyWith(emitState: HomeEmitState.checkoutOrderSuccess));
    emit(state.copyWith(emitState: HomeEmitState.success));
  }

  Future<void> _onToggleFavourite(ToggleFavourite event, Emitter<HomeState> emit) async {
    final shops = state.nearbyShops.data.map((e) => e.copyWith(isLiked: !e.isLiked)).toList();

    emit(
      state.copyWith(
        nearbyShops: ApiListResponse(
          success: state.nearbyShops.success,
          pagination: state.nearbyShops.pagination,
          data: shops,
        ),
      ),
    );

    

    final response = await _homeRepository.toggleFavouriteShop(shopId: event.shopId, isAdd: event.isAdd);
    if (response.success) {
      //add(FetchNearbyShops(showLoader: false));
      add(FetchFavouriteShops(showLoader: false));
    }
  }

  Future<void> _onFetchFavouriteShops(FetchFavouriteShops event, Emitter<HomeState> emit) async {
    // Reset pagination when fetching fresh favorites
    if (event.refresh) {
      _favoritesPage = 0;
      _hasMoreFavorites = true;
      _isFavoritesLoadingMore = false;
    }

    if (event.showLoader || event.refresh) {
      emit(state.copyWith(emitState: HomeEmitState.loading, isFavoritesLoadingMore: false));
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    final response = await _homeRepository.getFavouriteShops(
      limit: event.limit ?? 10,
      offset: _favoritesPage,
      searchKey: event.searchKey,
    );

    // Check if there are more favorites to load
    _hasMoreFavorites = response.data.length >= (event.limit ?? 10);

    emit(
      state.copyWith(
        emitState: HomeEmitState.success,
        favouriteShops: response,
        hasMoreFavorites: _hasMoreFavorites,
        isFavoritesLoadingMore: false,
      ),
    );
  }

  Future<void> _onFetchMoreFavouriteShops(FetchMoreFavouriteShops event, Emitter<HomeState> emit) async {
    // If already loading more or no more favorites, return
    if (_isFavoritesLoadingMore || !_hasMoreFavorites) return;

    _isFavoritesLoadingMore = true;
    _favoritesPage = state.favouriteShops.data.length;

    emit(state.copyWith(emitState: HomeEmitState.loadingMore, isFavoritesLoadingMore: true));

    final newFavorites = await _homeRepository.getFavouriteShops(limit: event.limit ?? 10, offset: _favoritesPage);

    // Check if there are more favorites to load
    _hasMoreFavorites = newFavorites.data.length >= (event.limit ?? 10);

    // Combine existing favorites with new favorites
    final existingFavorites = state.favouriteShops.data;
    final allFavorites = [...existingFavorites, ...newFavorites.data];

    _isFavoritesLoadingMore = false;

    emit(
      state.copyWith(
        emitState: HomeEmitState.success,
        favouriteShops: ApiListResponse<FavoriteShopModel>(success: newFavorites.success, data: allFavorites),
        hasMoreFavorites: _hasMoreFavorites,
        isFavoritesLoadingMore: false,
      ),
    );
  }

  Future<void> _onResetFavouritesPagination(ResetFavouritesPagination event, Emitter<HomeState> emit) async {
    _favoritesPage = 0;
    _hasMoreFavorites = true;
    _isFavoritesLoadingMore = false;

    emit(state.copyWith(hasMoreFavorites: true, isFavoritesLoadingMore: false));
  }

  Future<void> _onSubmitShopReview(SubmitShopReview event, Emitter<HomeState> emit) async {
    emit(state.copyWith(emitState: HomeEmitState.loading));
    final response = await _homeRepository.addShopReview(
      shopId: event.shopId,
      rating: event.rating,
      comment: event.comment,
      mediaId: event.mediaId,
    );
    if (response.success) {
      emit(state.copyWith(emitState: HomeEmitState.reviewSubmitted));
      add(FetchNearbyShops());
      add(FetchFavouriteShops());
    }
    emit(state.copyWith(emitState: HomeEmitState.success));
  }

  Future<void> _onFetchUserDetails(FetchUserDetails event, Emitter<HomeState> emit) async {
    emit(state.copyWith(emitState: HomeEmitState.loading));
    final response = await _homeRepository.getUserDetails();
    emit(state.copyWith(emitState: HomeEmitState.success, userDetails: response));
  }

  Future<void> _onUploadVoiceOrder(UploadVoiceOrder event, Emitter<HomeState> emit) async {
    emit(state.copyWith(emitState: HomeEmitState.loading));
    final response = await _homeRepository.uploadVoiceOrder(filePath: event.filePath, shopId: event.shopId);
    if (response.success) emit(state.copyWith(emitState: HomeEmitState.orderFetched, voiceOrder: response));
    emit(state.copyWith(emitState: HomeEmitState.success));
  }

  Future<void> _onDeleteOrder(DeleteOrder event, Emitter<HomeState> emit) async {
    emit(state.copyWith(emitState: HomeEmitState.loading));
    final response = await _homeRepository.deleteOrder(orderId: event.orderId);
    if (response.success) {
      emit(state.copyWith(emitState: HomeEmitState.orderDeleted));
      add(FetchOrderList(refresh: true));
    }
    emit(state.copyWith(emitState: HomeEmitState.success));
  }

  Future<void> _onReOrder(ReOrder event, Emitter<HomeState> emit) async {
    emit(state.copyWith(emitState: HomeEmitState.loading));
    final response = await _homeRepository.reOrder(orderId: event.orderId);
    if (response.success) {
      String? paymentLink;
      try {
        paymentLink = response.data['paymentLink'];
      } catch (_) {}
      emit(state.copyWith(emitState: HomeEmitState.reOrderSuccess, paymentLink: paymentLink));
      add(FetchOrderList(refresh: true));
    }
    emit(state.copyWith(emitState: HomeEmitState.success));
  }

  Future<void> _onViewReceipt(ViewReceipt event, Emitter<HomeState> emit) async {
    emit(state.copyWith(emitState: HomeEmitState.loading));
    final response = await _homeRepository.viewReceipt(id: event.id);
    if (response != null) {
      await _saveAndLaunchFile(response, 'Invoice.pdf');
    }
    emit(state.copyWith(emitState: HomeEmitState.success));
  }

  ///To save the pdf file in the device
  Future<void> _saveAndLaunchFile(List<int> bytes, String fileName) async {
    //Get the storage folder location using path_provider package.
    String? path;
    if (Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isWindows) {
      final Directory directory = await path_provider.getApplicationSupportDirectory();
      path = directory.path;
    } else {
      path = await PathProviderPlatform.instance.getApplicationSupportPath();
    }
    final File file = File(Platform.isWindows ? '$path\\$fileName' : '$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    if (Platform.isAndroid || Platform.isIOS) {
      //Launch the file (used open_file package)
      await open_file.OpenFile.open('$path/$fileName');
    } else if (Platform.isWindows) {
      await Process.run('start', <String>['$path\\$fileName'], runInShell: true);
    } else if (Platform.isMacOS) {
      await Process.run('open', <String>['$path/$fileName'], runInShell: true);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', <String>['$path/$fileName'], runInShell: true);
    }
  }
}
