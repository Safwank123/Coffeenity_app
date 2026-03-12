abstract class UrlConstants {
  /// Authentication endpoints
  static const String login = '/api/user/auth/login';
  static const String register = '/api/user/auth/register';
  static const String userPreference = '/api/user/userPreference';

  /// Profile & Preferences
  static const String profile = '/api/user/profile';
  static const String voiceUserPreference = '/api/user/voice/userPreference';
  static const String voiceRegister = '/api/user/auth/voice/register';
  static const String userUpdate = '/api/user/edit';

  /// Shops & Discovery
  static const String nearbyShops = '/api/user/shop/nearby';
  static const String shopList = '/api/user/shop/list';
  static const String shopDetails = '/api/user/shop/get';

  /// Shop Menu
  static const String shopMenuList = '/api/user/shopMenu/list';
  static const String shopMenuDetails = '/api/user/shopMenu/get';

  /// Orders
  static const String createOrder = '/api/user/order/add';
  static const String orderDetails = '/api/user/order/get';
  static const String orderList = '/api/user/order/list';
  static const String reorder = '/api/user/order/reorder';
  static const String checkoutOrder = '/api/user/order/checkout';
  static const String voiceOrder = '/api/user/order/voice-order';
  static const String orderInvoice = '/api/user/order/invoice/';
  static const String deleteOrder = '/api/user/order/cancel';
  static const String voiceReorder = '/api/user/order/voice-reorder';

  /// Favorites
  static const String addFavouriteShop = '/api/user/favouriteShop/add';
  static const String listFavouriteShops = '/api/user/favouriteShop/list';
  static const String removeFavouriteShop = '/api/user/favouriteShop/remove';

  /// Reviews
  static const String addShopReview = '/api/user/review/shop/add';
  static const String listShopReviews = '/api/user/review/shop/list';
  static const String addMenuReview = '/api/user/review/shopMenu/add';
  static const String listMenuReviews = '/api/user/review/shopMenu/list';

  /// Coupons & Categories
  static const String couponList = '/api/user/coupon/list';
  static const String categoryList = '/api/user/category/list'; 
}
