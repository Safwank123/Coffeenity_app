class ShopMenuModel {
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
  final List<ShopMenuMedia> medias;
  final List<MenuReview> reviews;
  final Category category;
  final SubCategory subCategory;
  final List<ShopMenuVariant> variants;

  ShopMenuModel({
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
    required this.medias,
    required this.reviews,
    required this.category,
    required this.subCategory,
    required this.variants,
  });

  factory ShopMenuModel.fromJson(Map<String, dynamic> json) => ShopMenuModel(
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
    medias:
        (json['shopMenuMedias'] as List<dynamic>?)
            ?.map((media) => ShopMenuMedia.fromJson(media as Map<String, dynamic>? ?? {}))
            .toList() ??
        [],
    reviews:
        (json['menuReviews'] as List<dynamic>?)
            ?.map((review) => MenuReview.fromJson(review as Map<String, dynamic>? ?? {}))
            .toList() ??
        [],
    category: Category.fromJson(json['category'] as Map<String, dynamic>? ?? {}),
    subCategory: SubCategory.fromJson(json['subCategory'] as Map<String, dynamic>? ?? {}),
    variants:
        ((json['shopMenuVariants'] as List<dynamic>? ?? json['orderItemVariants'] as List<dynamic>?))
            ?.map((variant) => ShopMenuVariant.fromJson(variant as Map<String, dynamic>? ?? {}))
            .toList() ??
        [],
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
    'shopMenuMedias': medias.map((media) => media.toJson()).toList(),
    'menuReviews': reviews.map((review) => review.toJson()).toList(),
    'category': category.toJson(),
    'subCategory': subCategory.toJson(),
    'shopMenuVariants': variants.map((variant) => variant.toJson()).toList(),
  };

  // Helper methods
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get averageRating => rating != null ? rating!.toStringAsFixed(1) : 'N/A';

  bool get isActive => status == 'ACTIVE' && !isDeleted;
  bool get hasMedia => medias.isNotEmpty;
  bool get hasReviews => reviews.isNotEmpty;
  bool get hasVariants => variants.isNotEmpty;

  List<String> get tagList => tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  List<String> get tasteList => taste.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

  String get starRating {
    if (rating == null) return 'No ratings';
    final r = rating!;
    final fullStars = r.floor();
    final hasHalfStar = r - fullStars >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    return '${'★' * fullStars}${hasHalfStar ? '½' : ''}${'☆' * emptyStars}';
  }

  ShopMenuMedia? get primaryMedia => medias.isNotEmpty ? medias.first : null;

  List<CustomizationGroup> getAllCustomizationGroups() {
    final groups = <CustomizationGroup>[];
    for (final variant in variants) {
      groups.addAll(variant.customizationGroups);
    }
    return groups;
  }

  Map<String, dynamic> toDisplayMap() => {
    'id': id,
    'name': name,
    'code': code,
    'price': formattedPrice,
    'description': description,
    'shortDescription': description.length > 100 ? '${description.substring(0, 100)}...' : description,
    'category': category.name,
    'subCategory': subCategory.name,
    'tags': tagList,
    'taste': tasteList,
    'rating': rating,
    'formattedRating': averageRating,
    'starRating': starRating,
    'reviewCount': reviewCount,
    'hasMedia': hasMedia,
    'primaryImage': primaryMedia?.url,
    'hasVariants': hasVariants,
    'variantsCount': variants.length,
    'customizationGroupsCount': getAllCustomizationGroups().length,
    'isActive': isActive,
    'status': status,
  };

  @override
  String toString() => 'ShopMenu(name: "$name", price: $formattedPrice)';
}

class ShopMenuVariant {
  final String id;
  final String name;
  final String? description;
  final String type;
  final bool isRequired;
  final String shopId;
  final String shopMenuId;
  final List<CustomizationGroup> customizationGroups;

  ShopMenuVariant({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.isRequired,
    required this.shopId,
    required this.shopMenuId,
    required this.customizationGroups,
  });

  factory ShopMenuVariant.fromJson(Map<String, dynamic> json) => ShopMenuVariant(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString(),
    type: json['type']?.toString() ?? '',
    isRequired: json['isRequired'] as bool? ?? false,
    shopId: json['shopId']?.toString() ?? '',
    shopMenuId: json['shopMenuId']?.toString() ?? '',
    customizationGroups:
        (json['shopMenuCustomizationGroups'] as List<dynamic>?)
            ?.map((group) => CustomizationGroup.fromJson(group as Map<String, dynamic>? ?? {}))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    'type': type,
    'isRequired': isRequired,
    'shopId': shopId,
    'shopMenuId': shopMenuId,
    'shopMenuCustomizationGroups': customizationGroups.map((group) => group.toJson()).toList(),
  };

  bool get hasCustomizationGroups => customizationGroups.isNotEmpty;
  List<String> get customizationGroupNames => customizationGroups.map((group) => group.name).toList();

  @override
  String toString() => 'ShopMenuVariant(name: "$name", type: $type)';
}

class CustomizationGroup {
  final String id;
  final String shopId;
  final String shopMenuId;
  final String? shopMenuVariantId;
  final String name;
  final String? description;
  final bool isRequired;
  final bool isMultiSelect;
  final int minSelection;
  final int maxSelection;
  final int displayOrder;
  final String domainId;
  final bool isDeleted;
  final bool isSystem;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ShopMenuCustomizationGroupOption>? options;

  CustomizationGroup({
    required this.id,
    required this.shopId,
    required this.shopMenuId,
    this.shopMenuVariantId,
    required this.name,
    this.description,
    required this.isRequired,
    required this.isMultiSelect,
    required this.minSelection,
    required this.maxSelection,
    required this.displayOrder,
    required this.domainId,
    required this.isDeleted,
    required this.isSystem,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.options,
  });

  factory CustomizationGroup.fromJson(Map<String, dynamic> json) => CustomizationGroup(
    id: json['id']?.toString() ?? '',
    shopId: json['shopId']?.toString() ?? '',
    shopMenuId: json['shopMenuId']?.toString() ?? '',
    shopMenuVariantId: json['shopMenuVariantId']?.toString(),
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString(),
    isRequired: json['isRequired'] as bool? ?? false,
    isMultiSelect: json['isMultiSelect'] as bool? ?? false,
    minSelection: (json['minSelection'] as num?)?.toInt() ?? 0,
    maxSelection: (json['maxSelection'] as num?)?.toInt() ?? 1,
    displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    domainId: json['domainId']?.toString() ?? '',
    isDeleted: json['isDeleted'] as bool? ?? false,
    isSystem: json['isSystem'] as bool? ?? false,
    status: json['status']?.toString() ?? 'ACTIVE',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    options: (json['shopMenuCustomizationGroupOptions'] as List<dynamic>?)
        ?.map((opt) => ShopMenuCustomizationGroupOption.fromJson(opt as Map<String, dynamic>? ?? {}))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shopId': shopId,
    'shopMenuId': shopMenuId,
    if (shopMenuVariantId != null) 'shopMenuVariantId': shopMenuVariantId,
    'name': name,
    if (description != null) 'description': description,
    'isRequired': isRequired,
    'isMultiSelect': isMultiSelect,
    'minSelection': minSelection,
    'maxSelection': maxSelection,
    'displayOrder': displayOrder,
    'domainId': domainId,
    'isDeleted': isDeleted,
    'isSystem': isSystem,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (options != null) 'shopMenuCustomizationGroupOptions': options!.map((opt) => opt.toJson()).toList(),
  };

  bool get isActive => status == 'ACTIVE' && !isDeleted;
  bool get hasOptions => options != null && options!.isNotEmpty;
  String get selectionType => isMultiSelect ? 'Multi-select' : 'Single select';
  String get requirementLabel => isRequired ? 'Required' : 'Optional';
  String get selectionRange => 'Select $minSelection-$maxSelection option${maxSelection > 1 ? 's' : ''}';

  @override
  String toString() => 'CustomizationGroup(name: "$name", required: $isRequired)';
}

class MenuReview {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  MenuReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory MenuReview.fromJson(Map<String, dynamic> json) => MenuReview(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    userName: json['userName']?.toString() ?? 'Anonymous',
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    comment: json['comment']?.toString() ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };

  String get starRating {
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    return '${'★' * fullStars}${hasHalfStar ? '½' : ''}${'☆' * emptyStars}';
  }

  @override
  String toString() => 'MenuReview(user: $userName, rating: $rating)';
}

class ShopMenuMedia {
  final String id;
  final String url;
  final String? thumbnailUrl;
  final String? altText;
  final int displayOrder;

  ShopMenuMedia({required this.id, required this.url, this.thumbnailUrl, this.altText, required this.displayOrder});

  factory ShopMenuMedia.fromJson(Map<String, dynamic> json) => ShopMenuMedia(
    id: json['id']?.toString() ?? '',
    url: json['url']?.toString() ?? '',
    thumbnailUrl: json['thumbnailUrl']?.toString(),
    altText: json['altText']?.toString(),
    displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    if (altText != null) 'altText': altText,
    'displayOrder': displayOrder,
  };

  @override
  String toString() => 'ShopMenuMedia(url: $url)';
}

class SubCategory {
  final String id;
  final String name;
  final String code;

  SubCategory({required this.id, required this.name, required this.code});

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'code': code};

  @override
  String toString() => 'SubCategory(name: "$name", code: $code)';
}

class Category {
  final String id;
  final String name;
  final String code;

  Category({required this.id, required this.name, required this.code});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'code': code};

  @override
  String toString() => 'Category(name: "$name", code: $code)';
}

class ShopMenuCustomizationGroupOption {
  final String id;
  final String shopMenuCustomizationGroupId;
  final String name;
  final String? description;
  final String price;
  final bool isDefault;
  final bool allowQuantity;
  final int minQuantity;
  final int maxQuantity;
  final int displayOrder;
  final String domainId;
  final bool isDeleted;
  final bool isSystem;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShopMenuCustomizationGroupOption({
    required this.id,
    required this.shopMenuCustomizationGroupId,
    required this.name,
    required this.description,
    required this.price,
    required this.isDefault,
    required this.allowQuantity,
    required this.minQuantity,
    required this.maxQuantity,
    required this.displayOrder,
    required this.domainId,
    required this.isDeleted,
    required this.isSystem,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShopMenuCustomizationGroupOption.fromJson(Map<String, dynamic> json) => ShopMenuCustomizationGroupOption(
    id: json['id']?.toString() ?? '',
    shopMenuCustomizationGroupId: json['shopMenuCustomizationGroupId']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString(),
    price: json['price']?.toString() ?? '',
    isDefault: json['isDefault'] ?? false,
    allowQuantity: json['allowQuantity'] ?? false,
    minQuantity: json['minQuantity'] ?? 0,
    maxQuantity: json['maxQuantity'] ?? 0,
    displayOrder: json['displayOrder'] ?? 0,
    domainId: json['domainId']?.toString() ?? '',
    isDeleted: json['isDeleted'] ?? false,
    isSystem: json['isSystem'] ?? false,
    status: json['status']?.toString() ?? '',
    createdAt: DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shopMenuCustomizationGroupId': shopMenuCustomizationGroupId,
    'name': name,
    'description': description,
    'price': price,
    'isDefault': isDefault,
    'allowQuantity': allowQuantity,
    'minQuantity': minQuantity,
    'maxQuantity': maxQuantity,
    'displayOrder': displayOrder,
    'domainId': domainId,
    'isDeleted': isDeleted,
    'isSystem': isSystem,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  String toString() =>
      'ShopMenuCustomizationGroupOption(id: $id, shopMenuCustomizationGroupId: $shopMenuCustomizationGroupId, name: $name, description: $description, price: $price, isDefault: $isDefault, allowQuantity: $allowQuantity, minQuantity: $minQuantity, maxQuantity: $maxQuantity, displayOrder: $displayOrder, domainId: $domainId, isDeleted: $isDeleted, isSystem: $isSystem, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}
