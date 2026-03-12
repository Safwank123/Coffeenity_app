class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final String shopId;
  final String orderStatus;
  final String paymentStatus;
  final DateTime orderDate;
  final double grandTotal;
  final double customizationTotal;
  final double variantTotal;
  final double? couponDiscount;
  final double subTotal;
  final double walletAmount;
  final double walletPointsEarned;
  final String paymentType;
  final String? couponId;
  final String? notes;
  final String orderIndex;
  final String? stripeSessionId;
  final String domainId;
  final bool isDeleted;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> orderItems;
  final OrderShop shop;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.shopId,
    required this.orderStatus,
    required this.paymentStatus,
    required this.orderDate,
    required this.grandTotal,
    required this.customizationTotal,
    required this.variantTotal,
    this.couponDiscount,
    required this.subTotal,
    required this.walletAmount,
    required this.walletPointsEarned,
    required this.paymentType,
    this.couponId,
    this.notes,
    required this.orderIndex,
    this.stripeSessionId,
    required this.domainId,
    required this.isDeleted,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
    required this.shop,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id']?.toString() ?? '',
    orderNumber: json['orderNumber']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    shopId: json['shopId']?.toString() ?? '',
    orderStatus: json['orderStatus']?.toString() ?? 'PENDING',
    paymentStatus: json['paymentStatus']?.toString() ?? 'PENDING',
    orderDate: DateTime.tryParse(json['orderDate']?.toString() ?? '') ?? DateTime.now(),
    grandTotal: double.tryParse(json['grandTotal']?.toString() ?? '0') ?? 0.0,
    customizationTotal: double.tryParse(json['customizationTotal']?.toString() ?? '0') ?? 0.0,
    variantTotal: double.tryParse(json['variantTotal']?.toString() ?? '0') ?? 0.0,
    couponDiscount: json['couponDiscount'] != null ? double.tryParse(json['couponDiscount']?.toString() ?? '0') : null,
    subTotal: double.tryParse(json['subTotal']?.toString() ?? '0') ?? 0.0,
    walletAmount: double.tryParse(json['walletAmount']?.toString() ?? '0') ?? 0.0,
    walletPointsEarned: double.tryParse(json['walletPointsEarned']?.toString() ?? '0') ?? 0.0,
    paymentType: json['paymentType']?.toString() ?? 'CASH',
    couponId: json['couponId']?.toString(),
    notes: json['notes']?.toString(),
    orderIndex: json['orderIndex']?.toString() ?? '',
    stripeSessionId: json['stripeSessionId']?.toString(),
    domainId: json['domainId']?.toString() ?? '',
    isDeleted: json['isDeleted'] as bool? ?? false,
    status: json['status']?.toString() ?? 'ACTIVE',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    orderItems:
        (json['orderItems'] as List<dynamic>?)
            ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>? ?? {}))
            .toList() ??
        [],
    shop: OrderShop.fromJson(json['shop'] as Map<String, dynamic>? ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderNumber': orderNumber,
    'userId': userId,
    'shopId': shopId,
    'orderStatus': orderStatus,
    'paymentStatus': paymentStatus,
    'orderDate': orderDate.toIso8601String(),
    'grandTotal': grandTotal.toString(),
    'customizationTotal': customizationTotal.toString(),
    'variantTotal': variantTotal.toString(),
    'couponDiscount': couponDiscount?.toString(),
    'subTotal': subTotal.toString(),
    'walletAmount': walletAmount.toString(),
    'walletPointsEarned': walletPointsEarned.toString(),
    'paymentType': paymentType,
    'couponId': couponId,
    'notes': notes,
    'orderIndex': orderIndex,
    'stripeSessionId': stripeSessionId,
    'domainId': domainId,
    'isDeleted': isDeleted,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'orderItems': orderItems.map((item) => item.toJson()).toList(),
    'shop': shop.toJson(),
  };

  // Helper methods
  String get formattedGrandTotal => '\$${grandTotal.toStringAsFixed(2)}';
  String get formattedCustomizationTotal => '\$${customizationTotal.toStringAsFixed(2)}';
  String get formattedVariantTotal => '\$${variantTotal.toStringAsFixed(2)}';
  String get formattedSubTotal => '\$${subTotal.toStringAsFixed(2)}';
  String get formattedWalletAmount => '\$${walletAmount.toStringAsFixed(2)}';
  String? get formattedCouponDiscount => couponDiscount != null ? '\$${couponDiscount!.toStringAsFixed(2)}' : null;

  String get statusBadge {
    switch (orderStatus) {
      case 'PENDING':
        return '🟡 Pending';
      case 'CONFIRMED':
        return '🔵 Confirmed';
      case 'PREPARING':
        return '👨‍🍳 Preparing';
      case 'READY':
        return '✅ Ready';
      case 'COMPLETED':
        return '🏁 Completed';
      case 'CANCELLED':
        return '❌ Cancelled';
      default:
        return orderStatus;
    }
  }

  String get paymentStatusBadge {
    switch (paymentStatus) {
      case 'PENDING':
        return '🟡 Pending';
      case 'PAID':
        return '💳 Paid';
      case 'FAILED':
        return '❌ Failed';
      case 'REFUNDED':
        return '↩️ Refunded';
      default:
        return paymentStatus;
    }
  }

  String get paymentTypeBadge {
    switch (paymentType) {
      case 'CARD':
        return '💳 Card';
      case 'CASH':
        return '💰 Cash';
      case 'WALLET':
        return '👛 Wallet';
      case 'UPI':
        return '📱 UPI';
      default:
        return paymentType;
    }
  }

  bool get isActive => status == 'ACTIVE' && !isDeleted;
  bool get isPending => orderStatus == 'PENDING';
  bool get isCompleted => orderStatus == 'COMPLETED';
  bool get isCancelled => orderStatus == 'CANCELLED';
  bool get isPaymentPending => paymentStatus == 'PENDING';
  bool get isPaymentPaid => paymentStatus == 'PAID';

  int get totalItems => orderItems.fold(0, (sum, item) => sum + item.quantity);
  int get totalCustomizations => orderItems.fold(0, (sum, item) => sum + item.variantGroups.length);

  double get calculatedTotal => subTotal + variantTotal + customizationTotal;
  bool get totalMatches => (calculatedTotal - grandTotal).abs() < 0.01;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(orderDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  Map<String, dynamic> toDisplayMap() => {
    'id': id,
    'orderNumber': orderNumber,
    'orderIndex': orderIndex,
    'shopName': shop.name,
    'formattedGrandTotal': formattedGrandTotal,
    'formattedSubTotal': formattedSubTotal,
    'formattedCustomizationTotal': formattedCustomizationTotal,
    'formattedVariantTotal': formattedVariantTotal,
    'orderStatus': orderStatus,
    'orderStatusBadge': statusBadge,
    'paymentStatus': paymentStatus,
    'paymentStatusBadge': paymentStatusBadge,
    'paymentType': paymentType,
    'paymentTypeBadge': paymentTypeBadge,
    'totalItems': totalItems,
    'totalCustomizations': totalCustomizations,
    'timeAgo': timeAgo,
    'orderDate': orderDate.toLocal().toString().split(' ')[0],
    'stripeSessionId': stripeSessionId,
    'hasCoupon': couponId != null,
    'couponDiscount': formattedCouponDiscount,
    'isActive': isActive,
    'totalMatches': totalMatches,
  };

  @override
  String toString() => 'Order(#$orderNumber, total: $formattedGrandTotal, status: $orderStatus)';
}

class OrderShop {
  final String id;
  final String name;
  final String code;
  final String domainId;

  OrderShop({required this.id, required this.name, required this.code, required this.domainId});

  factory OrderShop.fromJson(Map<String, dynamic> json) => OrderShop(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    domainId: json['domainId']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'code': code, 'domainId': domainId};

  @override
  String toString() => 'Shop(name: "$name", code: $code)';
}

class OrderItem {
  final String id;
  final String orderId;
  final String shopId;
  final String shopMenuId;
  final String name;
  final double basePrice;
  final int quantity;
  final double variantPrice;
  final double customizationTotal;
  final double totalPrice;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ShopMenu shopMenu;
  final List<OrderItemVariant> variants;
  final List<OrderItemVariantGroup> variantGroups;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.shopId,
    required this.shopMenuId,
    required this.name,
    required this.basePrice,
    required this.quantity,
    required this.variantPrice,
    required this.customizationTotal,
    required this.totalPrice,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.shopMenu,
    required this.variants,
    required this.variantGroups,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id']?.toString() ?? '',
    orderId: json['orderId']?.toString() ?? '',
    shopId: json['shopId']?.toString() ?? '',
    shopMenuId: json['shopMenuId']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    basePrice: double.tryParse(json['basePrice']?.toString() ?? '0') ?? 0.0,
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    variantPrice: double.tryParse(json['variantPrice']?.toString() ?? '0') ?? 0.0,
    customizationTotal: double.tryParse(json['customizationTotal']?.toString() ?? '0') ?? 0.0,
    totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
    isDeleted: json['isDeleted'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    shopMenu: ShopMenu.fromJson(json['shopMenu'] as Map<String, dynamic>? ?? {}),
    variants:
        (json['orderItemVariants'] as List<dynamic>?)
            ?.map((variant) => OrderItemVariant.fromJson(variant as Map<String, dynamic>? ?? {}))
            .toList() ??
        [],
    variantGroups:
        (json['orderItemVariantGroups'] as List<dynamic>?)
            ?.map((group) => OrderItemVariantGroup.fromJson(group as Map<String, dynamic>? ?? {}))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'shopId': shopId,
    'shopMenuId': shopMenuId,
    'name': name,
    'basePrice': basePrice.toString(),
    'quantity': quantity,
    'variantPrice': variantPrice.toString(),
    'customizationTotal': customizationTotal.toString(),
    'totalPrice': totalPrice.toString(),
    'isDeleted': isDeleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'shopMenu': shopMenu.toJson(),
    'orderItemVariants': variants.map((v) => v.toJson()).toList(),
    'orderItemVariantGroups': variantGroups.map((g) => g.toJson()).toList(),
  };

  // Helper methods
  String get formattedBasePrice => '\$${basePrice.toStringAsFixed(2)}';
  String get formattedVariantPrice => '\$${variantPrice.toStringAsFixed(2)}';
  String get formattedCustomizationTotal => '\$${customizationTotal.toStringAsFixed(2)}';
  String get formattedTotalPrice => '\$${totalPrice.toStringAsFixed(2)}';

  double get calculatedBaseTotal => basePrice * quantity;
  String get formattedCalculatedBaseTotal => '\$${calculatedBaseTotal.toStringAsFixed(2)}';

  double get calculatedVariantTotal => variantPrice * quantity;
  String get formattedCalculatedVariantTotal => '\$${calculatedVariantTotal.toStringAsFixed(2)}';

  double get calculatedCustomizationTotal => variantGroups.fold(0.0, (sum, group) => sum + group.lineTotal);
  String get formattedCalculatedCustomizationTotal => '\$${calculatedCustomizationTotal.toStringAsFixed(2)}';

  double get calculatedTotalPrice => calculatedBaseTotal + calculatedVariantTotal + calculatedCustomizationTotal;
  String get formattedCalculatedTotalPrice => '\$${calculatedTotalPrice.toStringAsFixed(2)}';

  bool get hasVariants => variants.isNotEmpty;
  bool get hasVariantGroups => variantGroups.isNotEmpty;

  bool get priceCalculationsMatch => (calculatedTotalPrice - totalPrice).abs() < 0.01;

  Map<String, dynamic> toDisplayMap() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'basePrice': formattedBasePrice,
    'baseTotal': formattedCalculatedBaseTotal,
    'variantPrice': formattedVariantPrice,
    'variantTotal': formattedCalculatedVariantTotal,
    'customizationTotal': formattedCalculatedCustomizationTotal,
    'itemTotal': formattedCalculatedTotalPrice,
    'hasVariants': hasVariants,
    'variants': variants.map((v) => v.name).toList(),
    'hasCustomizations': hasVariantGroups,
    'customizations': variantGroups.map((g) => '${g.quantity}x ${g.optionName} @ ${g.formattedOptionPrice}').toList(),
    'category': shopMenu.category.name,
    'subCategory': shopMenu.subCategory.name,
    'priceMatch': priceCalculationsMatch,
  };

  @override
  String toString() => 'OrderItem(name: "$name", qty: $quantity, total: $formattedTotalPrice)';
}

class OrderItemVariantGroup {
  final String id;
  final String orderItemId;
  final String shopMenuCustomizationGroupId;
  final String groupName;
  final double groupPrice;
  final String optionName;
  final double optionPrice;
  final int quantity;
  final bool isDeleted;
  final String domainId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CustomizationGroup? shopMenuCustomizationGroup;
  final String? shopMenuCustomizationGroupOptionId;

  OrderItemVariantGroup({
    required this.id,
    required this.orderItemId,
    required this.shopMenuCustomizationGroupId,
    required this.groupName,
    required this.groupPrice,
    required this.optionName,
    required this.optionPrice,
    required this.quantity,
    required this.isDeleted,
    required this.domainId,
    required this.createdAt,
    required this.updatedAt,
    this.shopMenuCustomizationGroup,
    this.shopMenuCustomizationGroupOptionId,
  });

  factory OrderItemVariantGroup.fromJson(Map<String, dynamic> json) => OrderItemVariantGroup(
    id: json['id']?.toString() ?? '',
    orderItemId: json['orderItemId']?.toString() ?? '',
    shopMenuCustomizationGroupId: json['shopMenuCustomizationGroupId']?.toString() ?? '',
    groupName: json['groupName']?.toString() ?? '',
    groupPrice: double.tryParse(json['groupPrice']?.toString() ?? '0') ?? 0.0,
    optionName: json['optionName']?.toString() ?? '',
    optionPrice: double.tryParse(json['optionPrice']?.toString() ?? '0') ?? 0.0,
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    isDeleted: json['isDeleted'] as bool? ?? false,
    domainId: json['domainId']?.toString() ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    shopMenuCustomizationGroup: json['shopMenuCustomizationGroup'] != null
        ? CustomizationGroup.fromJson(json['shopMenuCustomizationGroup'] as Map<String, dynamic>)
        : null,
    shopMenuCustomizationGroupOptionId: json['shopMenuCustomizationGroupOptionId']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderItemId': orderItemId,
    'shopMenuCustomizationGroupId': shopMenuCustomizationGroupId,
    'groupName': groupName,
    'groupPrice': groupPrice.toString(),
    'optionName': optionName,
    'optionPrice': optionPrice.toString(),
    'quantity': quantity,
    'isDeleted': isDeleted,
    'domainId': domainId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (shopMenuCustomizationGroup != null) 'shopMenuCustomizationGroup': shopMenuCustomizationGroup!.toJson(),
    if (shopMenuCustomizationGroupOptionId != null)
      'shopMenuCustomizationGroupOptionId': shopMenuCustomizationGroupOptionId,
  };

  String get formattedGroupPrice => '\$${groupPrice.toStringAsFixed(2)}';
  String get formattedOptionPrice => '\$${optionPrice.toStringAsFixed(2)}';
  double get lineTotal => optionPrice * quantity;
  String get formattedLineTotal => '\$${lineTotal.toStringAsFixed(2)}';

  @override
  String toString() => 'OrderItemVariantGroup(group: "$groupName", option: "$optionName")';
}

class OrderItemVariant {
  final String id;
  final String orderItemId;
  final String shopMenuVariantId;
  final String name;
  final double price;

  OrderItemVariant({
    required this.id,
    required this.orderItemId,
    required this.shopMenuVariantId,
    required this.name,
    required this.price,
  });

  factory OrderItemVariant.fromJson(Map<String, dynamic> json) => OrderItemVariant(
    id: json['id']?.toString() ?? '',
    orderItemId: json['orderItemId']?.toString() ?? '',
    shopMenuVariantId: json['shopMenuVariantId']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderItemId': orderItemId,
    'shopMenuVariantId': shopMenuVariantId,
    'name': name,
    'price': price.toString(),
  };

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  bool get hasPrice => price > 0;

  @override
  String toString() => 'OrderItemVariant(name: "$name", price: $formattedPrice)';
}

class CustomizationGroup {
  final String id;
  final String? shopMenuVariantId;
  final String name;
  final String? description;
  final bool isRequired;
  final int minSelection;
  final int maxSelection;
  final int displayOrder;
  final String domainId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomizationGroup({
    required this.id,
    this.shopMenuVariantId,
    required this.name,
    this.description,
    required this.isRequired,
    required this.minSelection,
    required this.maxSelection,
    required this.displayOrder,
    required this.domainId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomizationGroup.fromJson(Map<String, dynamic> json) => CustomizationGroup(
    id: json['id']?.toString() ?? '',
    shopMenuVariantId: json['shopMenuVariantId']?.toString(),
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString(),
    isRequired: json['isRequired'] as bool? ?? false,
    minSelection: (json['minSelection'] as num?)?.toInt() ?? 0,
    maxSelection: (json['maxSelection'] as num?)?.toInt() ?? 1,
    displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    domainId: json['domainId']?.toString() ?? '',
    status: json['status']?.toString() ?? 'ACTIVE',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shopMenuVariantId': shopMenuVariantId,
    'name': name,
    'description': description,
    'isRequired': isRequired,
    'minSelection': minSelection,
    'maxSelection': maxSelection,
    'displayOrder': displayOrder,
    'domainId': domainId,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  String toString() => 'CustomizationGroup(name: "$name")';
}

class ShopMenu {
  final String id;
  final String shopId;
  final String name;
  final String code;
  final double price;
  final String description;
  final String categoryId;
  final String subcategoryId;
  final String tags;
  final String taste;
  final double? rating;
  final int reviewCount;
  final String domainId;
  final bool isDeleted;
  final bool isSystem;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Category category;
  final SubCategory subCategory;

  ShopMenu({
    required this.id,
    required this.shopId,
    required this.name,
    required this.code,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.subcategoryId,
    required this.tags,
    required this.taste,
    this.rating,
    required this.reviewCount,
    required this.domainId,
    required this.isDeleted,
    required this.isSystem,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.subCategory,
  });

  factory ShopMenu.fromJson(Map<String, dynamic> json) => ShopMenu(
    id: json['id']?.toString() ?? '',
    shopId: json['shopId']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    description: json['description']?.toString() ?? '',
    categoryId: json['categoryId']?.toString() ?? '',
    subcategoryId: json['subcategoryId']?.toString() ?? '',
    tags: json['tags']?.toString() ?? '',
    taste: json['taste']?.toString() ?? '',
    rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    domainId: json['domainId']?.toString() ?? '',
    isDeleted: json['isDeleted'] as bool? ?? false,
    isSystem: json['isSystem'] as bool? ?? false,
    status: json['status']?.toString() ?? 'ACTIVE',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    category: Category.fromJson(json['category'] as Map<String, dynamic>? ?? {}),
    subCategory: SubCategory.fromJson(json['subCategory'] as Map<String, dynamic>? ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shopId': shopId,
    'name': name,
    'code': code,
    'price': price,
    'description': description,
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'tags': tags,
    'taste': taste,
    'rating': rating,
    'reviewCount': reviewCount,
    'domainId': domainId,
    'isDeleted': isDeleted,
    'isSystem': isSystem,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'category': category.toJson(),
    'subCategory': subCategory.toJson(),
  };

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  List<String> get tagList => tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

  @override
  String toString() => 'ShopMenu(name: "$name", price: $formattedPrice)';
}

class SubCategory {
  final String id;
  final String name;
  final String code;
  final String categoryId;
  final String? mediaId;
  final bool isDeleted;
  final bool isSystem;
  final String status;
  final String domainId;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubCategory({
    required this.id,
    required this.name,
    required this.code,
    required this.categoryId,
    this.mediaId,
    required this.isDeleted,
    required this.isSystem,
    required this.status,
    required this.domainId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    categoryId: json['categoryId']?.toString() ?? '',
    mediaId: json['mediaId']?.toString(),
    isDeleted: json['isDeleted'] as bool? ?? false,
    isSystem: json['isSystem'] as bool? ?? false,
    status: json['status']?.toString() ?? 'ACTIVE',
    domainId: json['domainId']?.toString() ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'categoryId': categoryId,
    'mediaId': mediaId,
    'isDeleted': isDeleted,
    'isSystem': isSystem,
    'status': status,
    'domainId': domainId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  String toString() => 'SubCategory(name: "$name", code: $code)';
}

class Category {
  final String id;
  final String name;
  final String code;
  final bool isDeleted;
  final String status;
  final String? mediaId;
  final String domainId;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.code,
    required this.isDeleted,
    required this.status,
    this.mediaId,
    required this.domainId,
    required this.isSystem,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    isDeleted: json['isDeleted'] as bool? ?? false,
    status: json['status']?.toString() ?? 'ACTIVE',
    mediaId: json['mediaId']?.toString(),
    domainId: json['domainId']?.toString() ?? '',
    isSystem: json['isSystem'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'isDeleted': isDeleted,
    'status': status,
    'mediaId': mediaId,
    'domainId': domainId,
    'isSystem': isSystem,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  String toString() => 'Category(name: "$name", code: $code)';
}
