import 'package:coffeenity/core/utils/api_response_handler.dart';
import 'package:coffeenity/features/home/data/models/order_model.dart';
import 'package:coffeenity/features/home/data/models/shop_model.dart';
import 'package:flutter/services.dart';

import '../../../../config/api/api_services.dart';
import '../../../../config/constants/url_constants.dart';
import '../../../../core/utils/app_log.dart';
import '../../../../core/utils/app_prompts.dart';
import '../../presentation/screens/voice_order_model.dart';
import '../models/favorite_shop_model.dart';
import '../models/order_request_model.dart';
import '../models/shop_menu_model.dart';
import '../models/user_model.dart';

class HomeRepository {
  final _apiServices = ApiServices();

  // --- Orders ---

  Future<ApiListResponse<OrderModel>> getOrders({String? id, int? offset, int? limit, String? search}) async {
    try {
      final json = await _apiServices.postRequest(
        UrlConstants.orderList,
        body: {"search": search, "id": id, "offset": offset, "limit": limit}
          ..removeWhere((key, value) => value == null)
          ..removeWhere((key, value) => value is String && value.isEmpty),
      );
      if (json != null) return ApiListResponse.parse(json, fromJsonT: (json) => OrderModel.fromJson(json));
    } catch (e) {
      AppLog.errorLog("getOrders", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiListResponse<OrderModel>();
  }

  Future<ApiResponse> createOrder({required OrderRequestModel orderRequestModel}) async {
    try {
      final json = await _apiServices.postRequest(UrlConstants.createOrder, body: orderRequestModel.toJson());

      if (json != null) {
        return ApiResponse(success: true, data: json['paymentLink']);
      }
    } catch (e) {
      AppLog.errorLog("createOrder", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse();
  }

  Future<ApiResponse> checkoutOrder({required String orderId}) async {
    try {
      final json = await _apiServices.postRequest(UrlConstants.checkoutOrder, body: {"orderId": orderId});
      if (json != null) return ApiResponse.parse(json);
    } catch (e) {
      AppLog.errorLog('checkoutOrder', e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse();
  }

  // --- Shops & Discovery ---

  Future<ApiListResponse<ShopModel>> getNearbyShops({
    double? lat,
    double? lng,
    int? offset,
    int? limit,
    String? search,
  }) async {
    try {
      final json = await _apiServices.postRequest(
        UrlConstants.nearbyShops,
        body: {"latitude": lat, "longitude": lng, "offset": offset, "limit": limit, "search": search}
          ..removeWhere((k, v) => v == null),
      );
      if (json != null) return ApiListResponse.parse(json, fromJsonT: (json) => ShopModel.fromJson(json));
    } catch (e) {
      AppLog.errorLog('getNearbyShops', e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiListResponse();
  }

  Future<ApiResponse> getShopDetails({required String shopId}) async {
    try {
      final json = await _apiServices.postRequest(UrlConstants.shopDetails, body: {"shopId": shopId});
      if (json != null) return ApiResponse.parse(json);
    } catch (e) {
      AppLog.errorLog("getShopDetails", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse();
  }

  // --- Shop Menu ---

  Future<ApiListResponse<ShopMenuModel>> getShopMenu({required String shopId, String? searchKey}) async {
    try {
      final json = await _apiServices.postRequest(
        UrlConstants.shopMenuList,
        body: {"shopId": shopId, "searchKey": searchKey}..removeWhere((k, v) => v == null),
      );
      if (json != null) return ApiListResponse.parse(json, fromJsonT: (json) => ShopMenuModel.fromJson(json));
    } catch (e) {
      AppLog.errorLog("getShopMenu", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiListResponse();
  }

  // --- Favorites ---

  Future<ApiResponse> toggleFavouriteShop({required String shopId, required bool isAdd}) async {
    try {
      final endpoint = isAdd ? UrlConstants.addFavouriteShop : UrlConstants.removeFavouriteShop;
      final json = await _apiServices.postRequest(endpoint, body: {"shopId": shopId});
      if (json != null) return ApiResponse.parse(json);
    } catch (e) {
      AppLog.errorLog("toggleFavouriteShop", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse();
  }

  Future<ApiListResponse<FavoriteShopModel>> getFavouriteShops({int? offset, int? limit, String? searchKey}) async {
    try {
      final json = await _apiServices.postRequest(
        UrlConstants.listFavouriteShops,
        body: {"offset": offset, "limit": limit, "search": searchKey}..removeWhere((k, v) => v == null),
      );
      if (json != null) return ApiListResponse.parse(json, fromJsonT: (json) => FavoriteShopModel.fromJson(json));
    } catch (e) {
      AppLog.errorLog("getFavouriteShops", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiListResponse();
  }

  // --- Reviews ---

  Future<ApiResponse> addShopReview({
    required String shopId,
    required double rating,
    String? comment,
    String? mediaId,
  }) async {
    try {
      final json = await _apiServices.postRequest(
        UrlConstants.addShopReview,
        body: {"shopId": shopId, "rating": rating, "comment": comment, "mediaId": mediaId}
          ..removeWhere((k, v) => v == null),
      );
      if (json != null) return ApiResponse.parse(json);
    } catch (e) {
      AppLog.errorLog("addShopReview", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse();
  }

  Future<ApiResponse<VoiceOrderModel>> uploadVoiceOrder({required String filePath, required String shopId}) async {
    try {
      final json = await _apiServices.uploadVoiceOrder(filePath: filePath, shopId: shopId);
      if (json != null) {
        return ApiResponse<VoiceOrderModel>(data: VoiceOrderModel.fromJson(json['data']), success: true);
      }
    } catch (e) {
      AppLog.errorLog("uploadVoiceOrder", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse<VoiceOrderModel>(success: false);
  }

  Future<ApiResponse> uploadVoiceReOrder({required String filePath}) async {
    try {
      final json = await _apiServices.uploadVoiceReOrder(filePath: filePath);
      if (json != null) {
        return ApiResponse(data: json, success: true);
      }
    } catch (e) {
      AppLog.errorLog("uploadVoiceOrder", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse<VoiceOrderModel>(success: false);
  }

  Future<ApiResponse<UserModel>> getUserDetails() async {
    try {
      final json = await _apiServices.getRequest(UrlConstants.profile);
      if (json != null) return ApiResponse.parse(json, fromJsonT: (json) => UserModel.fromJson(json));
    } catch (e) {
      AppLog.errorLog("getUserDetails", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse();
  }

  Future<ApiResponse> deleteOrder({required String orderId}) async {
    try {
      final json = await _apiServices.postRequest(UrlConstants.deleteOrder, body: {'orderId': orderId});
      if (json != null) return ApiResponse.parse(json);
    } catch (e) {
      AppLog.errorLog("deleteOrder", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse();
  }

  Future<ApiResponse> reOrder({required String orderId}) async {
    try {
      final json = await _apiServices.postRequest(UrlConstants.reorder, body: {'orderId': orderId});
      if (json != null) {
        return ApiResponse.parse(json);
      }
    } catch (e) {
      AppLog.errorLog("reOrder", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse();
  }

  Future<Uint8List?> viewReceipt({required String id}) async {
    try {
      final json = await _apiServices.getPdfAsBytes(UrlConstants.orderInvoice + id);
      if (json != null) return json;
    } catch (e) {
      AppPrompts.showError(message: e.toString());
      AppLog.errorLog('viewReceipt', e);
    }
    return null;
  }
}
