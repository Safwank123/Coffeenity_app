class VoiceOrderModel {
  final bool success;
  final String transcript;
  final List<MatchedItem> matchedItems;
  final List<String> unmatchedItems;
  final List<MismatchedItem> mismatchedItems;
  final Pricing pricing;
  final String paymentType;

  const VoiceOrderModel({
    required this.success,
    required this.transcript,
    required this.matchedItems,
    required this.unmatchedItems,
    required this.mismatchedItems,
    required this.pricing,
    required this.paymentType,
  });

  factory VoiceOrderModel.fromJson(Map<String, dynamic> json) => VoiceOrderModel(
    success: json['success'] ?? false,
    transcript: json['transcript'] ?? '',
    matchedItems: (json['matchedItems'] as List<dynamic>?)?.map((item) => MatchedItem.fromJson(item)).toList() ?? [],
    unmatchedItems: (json['unmatchedItems'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
    mismatchedItems:
        (json['mismatchedItems'] as List<dynamic>?)?.map((item) => MismatchedItem.fromJson(item)).toList() ?? [],
    pricing: Pricing.fromJson(json['pricing'] ?? {}),
    paymentType: json['paymentType'] ?? '',
  );
  
}

class MatchedItem {
  final String shopMenuId;
  final String name;
  final int quantity;
  final double basePrice;
  final Variant variant;
  final List<Customization> customizations;
  final double customizationTotal;
  final double totalPrice;

  const MatchedItem({
    required this.shopMenuId,
    required this.name,
    required this.quantity,
    required this.basePrice,
    required this.variant,
    required this.customizations,
    required this.customizationTotal,
    required this.totalPrice,
  });

  factory MatchedItem.fromJson(Map<String, dynamic> json) => MatchedItem(
    shopMenuId: json['shopMenuId'] ?? '',
    name: json['name'] ?? '',
    quantity: json['quantity'] ?? 0,
    basePrice: double.parse(json['basePrice'].toString()),
    variant: Variant.fromJson(json['variant'] ?? {}),
    customizations:
        (json['customizations'] as List<dynamic>?)?.map((item) => Customization.fromJson(item)).toList() ?? [],
    customizationTotal: double.tryParse(json['customizationTotal'].toString()) ?? 0,
    totalPrice: double.tryParse(json['totalPrice'].toString()) ?? 0,
  );
  
}


class MismatchedItem {
  final String name;
  final String reason;

  const MismatchedItem({required this.name, required this.reason});

  factory MismatchedItem.fromJson(Map<String, dynamic> json) =>
      MismatchedItem(name: json['name'] ?? '', reason: json['reason'] ?? '');
}

class Pricing {
  final double subTotal;
  final double variantTotal;
  final double customizationTotal;
  final double grandTotal;

  Pricing({
    required this.subTotal,
    required this.variantTotal,
    required this.customizationTotal,
    required this.grandTotal,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) => Pricing(
    subTotal: double.tryParse(json['subTotal'].toString()) ?? 0,
    variantTotal: double.tryParse(json['variantTotal'].toString()) ?? 0,
    customizationTotal: double.tryParse(json['customizationTotal'].toString()) ?? 0,
    grandTotal: double.tryParse(json['grandTotal'].toString()) ?? 0,
  );
  
}

class Variant {
  final String id;
  final String name;
  final double price;

  const Variant({required this.id, required this.name, required this.price});

  factory Variant.fromJson(Map<String, dynamic> json) =>
      Variant(id: json['id'] ?? '', name: json['name'] ?? '', price: double.tryParse(json['price'].toString()) ?? 0);
}

class Customization {
  final String shopMenuCustomizationGroupId;
  final String groupName;
  final String optionId;
  final String optionName;
  final double price;
  final int quantity;

  const Customization({
    required this.shopMenuCustomizationGroupId,
    required this.groupName,
    required this.optionId,
    required this.optionName,
    required this.price,
    required this.quantity,
  });

  factory Customization.fromJson(Map<String, dynamic> json) => Customization(
    shopMenuCustomizationGroupId: json['shopMenuCustomizationGroupId'] ?? "",
    groupName: json['groupName'] ?? "",
    optionId: json['optionId'] ?? "",
    optionName: json['optionName'] ?? "",
    price: double.tryParse(json['price'].toString()) ?? 0,
    quantity: json['quantity'] ?? 0,
  );
  
}
