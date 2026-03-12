
class OrderRequestModel {
  final String shopId;
  final String paymentType;
  final List<OrderItemRequestModel> orderItems;

  const OrderRequestModel({required this.shopId, required this.paymentType, required this.orderItems});


  Map<String, dynamic> toJson() =>
      {
          "shopId": shopId,
          "paymentType": paymentType,
          "orderItems": List<dynamic>.from(orderItems.map((x) => x.toJson())),
        }
        ..removeWhere((key, value) => value == null)
        ..removeWhere((key, value) => value is String && value.isEmpty);
}

class OrderItemRequestModel {
  final String shopMenuId;
  final String name;
  final int quantity;
  final VariantRequest variant;
  final List<CustomizationRequest> customizations;

  OrderItemRequestModel({
    required this.shopMenuId,
    required this.name,
    required this.quantity,
    required this.variant,
    required this.customizations,
  });

  Map<String, dynamic> toJson() =>
      {
          "shopMenuId": shopMenuId,
          "name": name,
          "quantity": quantity,
          "variant": variant.toJson(),
          "customizations": List<dynamic>.from(customizations.map((x) => x.toJson())),
        }
        ..removeWhere((key, value) => value == null)
        ..removeWhere((key, value) => value is Map && value.isEmpty)
        ..removeWhere((key, value) => value is List && value.isEmpty)
        ..removeWhere((key, value) => value is String && value.isEmpty);
}

class VariantRequest {
  final String shopMenuVariantId;
  final String name;

  VariantRequest({required this.shopMenuVariantId, required this.name});

  factory VariantRequest.fromJson(Map<String, dynamic> json) =>
      VariantRequest(shopMenuVariantId: json["shopMenuVariantId"], name: json["name"]);

  Map<String, dynamic> toJson() => {"shopMenuVariantId": shopMenuVariantId, "name": name}
    ..removeWhere((key, value) => value == null)
    ..removeWhere((key, value) => value is String && value.isEmpty);
}

class CustomizationRequest {
  final String shopMenuCustomizationGroupId;
  final String shopMenuCustomizationGroupOptionId;
  final String groupName;
  final String optionName;
  final double optionPrice;
  final int quantity;

  CustomizationRequest({
    required this.shopMenuCustomizationGroupId,
    required this.shopMenuCustomizationGroupOptionId,
    required this.groupName,
    required this.optionName,
    required this.optionPrice,
    required this.quantity,
  });

 

  Map<String, dynamic> toJson() =>
      {
          "shopMenuCustomizationGroupId": shopMenuCustomizationGroupId,
          "shopMenuCustomizationGroupOptionId": shopMenuCustomizationGroupOptionId,
          "groupName": groupName,
          "optionName": optionName,
          "quantity": quantity,
        }
        ..removeWhere((key, value) => value == null)
        ..removeWhere((key, value) => value is String && value.isEmpty);
}
