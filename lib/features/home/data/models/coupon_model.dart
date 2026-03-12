class Coupon {
  final String id;
  final String code;
  final String name;
  final String? mediaId;
  final String userGroupId;
  final String discountType;
  final double discountValue;
  final DateTime expiryDate;
  final double maxAmount;
  final double minAmount;
  final String domainId;
  final String status;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic media;
  final UserGroup userGroup;

  Coupon({
    required this.id,
    required this.code,
    required this.name,
    this.mediaId,
    required this.userGroupId,
    required this.discountType,
    required this.discountValue,
    required this.expiryDate,
    required this.maxAmount,
    required this.minAmount,
    required this.domainId,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.media,
    required this.userGroup,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
    id: json['id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    mediaId: json['mediaId'] as String?,
    userGroupId: json['userGroupId'] as String,
    discountType: json['discountType'] as String,
    discountValue: double.parse(json['discountValue'] as String),
    expiryDate: DateTime.parse(json['expiryDate'] as String),
    maxAmount: double.parse(json['maxAmount'] as String),
    minAmount: double.parse(json['minAmount'] as String),
    domainId: json['domainId'] as String,
    status: json['status'] as String,
    isDeleted: json['isDeleted'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    media: json['media'],
    userGroup: UserGroup.fromJson(json['userGroup'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'mediaId': mediaId,
    'userGroupId': userGroupId,
    'discountType': discountType,
    'discountValue': discountValue.toString(),
    'expiryDate': expiryDate.toIso8601String(),
    'maxAmount': maxAmount.toString(),
    'minAmount': minAmount.toString(),
    'domainId': domainId,
    'status': status,
    'isDeleted': isDeleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'media': media,
    'userGroup': userGroup.toJson(),
  };

  // Helper methods
  String get formattedDiscountValue {
    if (discountType == 'FIXED') {
      return '\$${discountValue.toStringAsFixed(2)}';
    } else {
      return '${discountValue.toStringAsFixed(0)}%';
    }
  }

  String get formattedMinAmount => '\$${minAmount.toStringAsFixed(2)}';
  String get formattedMaxAmount => '\$${maxAmount.toStringAsFixed(2)}';

  bool get isActive => status == 'ACTIVE' && !isDeleted;

  bool get isExpired => expiryDate.isBefore(DateTime.now());

  bool get isValid => isActive && !isExpired;

  bool get isFixedDiscount => discountType == 'FIXED';

  bool get isPercentageDiscount => discountType == 'PERCENTAGE';

  double calculateDiscount(double orderAmount) {
    if (!isValid) return 0.0;
    if (orderAmount < minAmount) return 0.0;

    double discount = 0.0;

    if (isFixedDiscount) {
      discount = discountValue;
    } else if (isPercentageDiscount) {
      discount = orderAmount * (discountValue / 100);
    }

    // Apply max amount limit
    if (maxAmount > 0 && discount > maxAmount) {
      discount = maxAmount;
    }

    return discount;
  }

  bool isApplicableForAmount(double orderAmount) {
    if (!isValid) return false;
    return orderAmount >= minAmount;
  }

  bool isApplicableForUserGroup(String userGroupId) {
    return this.userGroupId == userGroupId;
  }

  String get validityPeriod {
    final now = DateTime.now();
    if (isExpired) return 'Expired';

    final difference = expiryDate.difference(now);
    if (difference.inDays > 30) {
      return 'Valid for ${(difference.inDays / 30).floor()} months';
    } else if (difference.inDays > 0) {
      return 'Valid for ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'Valid for ${difference.inHours} hours';
    } else {
      return 'Expires soon';
    }
  }

  String get discountDescription {
    if (isFixedDiscount) {
      return '\$${discountValue.toStringAsFixed(2)} off';
    } else {
      return '${discountValue.toStringAsFixed(0)}% off';
    }
  }

  String get eligibilityDescription {
    return 'Min. order: $formattedMinAmount';
  }

  @override
  String toString() => 'Coupon(id: $id, code: $code, name: $name, discount: $formattedDiscountValue)';
}

class UserGroup {
  final String id;
  final String name;
  final String code;

  UserGroup({required this.id, required this.name, required this.code});

  factory UserGroup.fromJson(Map<String, dynamic> json) =>
      UserGroup(id: json['id'] as String, name: json['name'] as String, code: json['code'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'code': code};

  @override
  String toString() => 'UserGroup(id: $id, name: $name, code: $code)';
}
