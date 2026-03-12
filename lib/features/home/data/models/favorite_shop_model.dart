import 'shop_model.dart';

class FavoriteShopModel {
  final String id;
  final String userId;
  final String shopId;
  final String domainId;
  final bool isLike;
  final bool isDeleted;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ShopModel shop;

  const FavoriteShopModel({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.domainId,
    required this.isLike,
    required this.isDeleted,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.shop,
  });

  FavoriteShopModel copyWith({
    String? id,
    String? userId,
    String? shopId,
    String? domainId,
    bool? isLike,
    bool? isDeleted,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    ShopModel? shop,
  }) {
    return FavoriteShopModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      domainId: domainId ?? this.domainId,
      isLike: isLike ?? this.isLike,
      isDeleted: isDeleted ?? this.isDeleted,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shop: shop ?? this.shop,
    );
  }

  factory FavoriteShopModel.fromJson(Map<String, dynamic> json) => FavoriteShopModel(
    id: json['id'] ?? "",
    userId: json['userId'] ?? "",
    shopId: json['shopId'] ?? "",
    domainId: json['domainId'] ?? "",
    isLike: json['isLike'] ?? false,
    isDeleted: json['isDeleted'] ?? false,
    status: json['status'] ?? "",
    createdAt: DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now(),
    shop: ShopModel.fromJson(json['shop'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'shopId': shopId,
    'domainId': domainId,
    'isLike': isLike,
    'isDeleted': isDeleted,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'shop': shop.toJson(),
  };
}
