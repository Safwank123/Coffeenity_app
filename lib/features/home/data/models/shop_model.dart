class ShopModel {
  final String id;
  final String name;
  final String code;
  final String email;
  final String password;
  final String phone;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final String countryId;
  final String stateId;
  final String? districtId;
  final String cityId;
  final String areaId;
  final String zipCode;
  final bool isDeliveryAvailable;
  final String? keywords;
  final String? website;
  final int reviewCount;
  final String? accessibility;
  final String? serviceOptions;
  final String? amenities;
  final String? popularFor;
  final double averagePrice;
  final String domainId;
  final String approvalStatus;
  final String addedBy;
  final bool isDeleted;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLiked;
  final List<ShopMedia> images;

  const ShopModel({
    required this.id,
    required this.name,
    required this.code,
    required this.email,
    required this.password,
    required this.phone,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.countryId,
    required this.stateId,
    this.districtId,
    required this.cityId,
    required this.areaId,
    required this.zipCode,
    required this.isDeliveryAvailable,
    this.keywords,
    this.website,
    required this.reviewCount,
    this.accessibility,
    this.serviceOptions,
    this.amenities,
    this.popularFor,
    required this.averagePrice,
    required this.domainId,
    required this.approvalStatus,
    required this.addedBy,
    required this.isDeleted,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isLiked,
    required this.images,
  });

  ShopModel copyWith({
    String? id,
    String? name,
    String? code,
    String? email,
    String? password,
    String? phone,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    String? countryId,
    String? stateId,
    String? districtId,
    String? cityId,
    String? areaId,
    String? zipCode,
    bool? isDeliveryAvailable,
    String? keywords,
    String? website,
    int? reviewCount,
    String? accessibility,
    String? serviceOptions,
    String? amenities,
    String? popularFor,
    double? averagePrice,
    String? domainId,
    String? approvalStatus,
    String? addedBy,
    bool? isDeleted,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLiked,
    List<ShopMedia>? images,
  }) {
    return ShopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      countryId: countryId ?? this.countryId,
      stateId: stateId ?? this.stateId,
      districtId: districtId ?? this.districtId,
      cityId: cityId ?? this.cityId,
      areaId: areaId ?? this.areaId,
      zipCode: zipCode ?? this.zipCode,
      isDeliveryAvailable: isDeliveryAvailable ?? this.isDeliveryAvailable,
      keywords: keywords ?? this.keywords,
      website: website ?? this.website,
      reviewCount: reviewCount ?? this.reviewCount,
      accessibility: accessibility ?? this.accessibility,
      serviceOptions: serviceOptions ?? this.serviceOptions,
      amenities: amenities ?? this.amenities,
      popularFor: popularFor ?? this.popularFor,
      averagePrice: averagePrice ?? this.averagePrice,
      domainId: domainId ?? this.domainId,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      addedBy: addedBy ?? this.addedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
      images: images ?? this.images,
    );
  }

  factory ShopModel.fromJson(Map<String, dynamic> json) => ShopModel(
    id: json['id'] as String? ?? "",
    name: json['name'] as String? ?? "",
    code: json['code'] as String? ?? "",
    email: json['email'] as String? ?? "",
    password: json['password'] as String? ?? "",
    phone: json['phone'] as String? ?? "",
    description: json['description'] as String? ?? "",
    address: json['address'] as String? ?? "",
    latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
    longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
    rating: double.tryParse(json['rating'].toString()) ?? 0.0,
    countryId: json['countryId'] as String? ?? "",
    stateId: json['stateId'] as String? ?? "",
    districtId: json['districtId'] as String? ?? "",
    cityId: json['cityId'] as String? ?? "",
    areaId: json['areaId'] as String? ?? "",
    zipCode: json['zipCode'] as String? ?? "",
    isDeliveryAvailable: json['isDeliveryAvailable'] as bool? ?? false,
    keywords: json['keywords'] as String?,
    website: json['website'] as String?,
    reviewCount: int.tryParse(json['reviewCount'].toString()) ?? 0,
    accessibility: json['accessibility'] as String?,
    serviceOptions: json['serviceOptions'] as String?,
    amenities: json['amenities'] as String?,
    popularFor: json['popularFor'] as String?,
    averagePrice: double.tryParse(json['averagePrice'].toString()) ?? 0.0,
    domainId: json['domainId'] as String? ?? "",
    approvalStatus: json['approvalStatus'] as String? ?? "",
    addedBy: json['addedBy'] as String? ?? "",
    isDeleted: json['isDeleted'] as bool? ?? false,
    status: json['status'] as String? ?? "",
    createdAt: DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now(),
    isLiked: json['isLike'] as bool? ?? false,
    images: (json['images'] as List<dynamic>?)?.map((e) => ShopMedia.fromJson(e)).toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'email': email,
    'password': password,
    'phone': phone,
    'description': description,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'rating': rating,
    'countryId': countryId,
    'stateId': stateId,
    'districtId': districtId,
    'cityId': cityId,
    'areaId': areaId,
    'zipCode': zipCode,
    'isDeliveryAvailable': isDeliveryAvailable,
    'keywords': keywords,
    'website': website,
    'reviewCount': reviewCount,
    'accessibility': accessibility,
    'serviceOptions': serviceOptions,
    'amenities': amenities,
    'popularFor': popularFor,
    'averagePrice': averagePrice,
    'domainId': domainId,
    'approvalStatus': approvalStatus,
    'addedBy': addedBy,
    'isDeleted': isDeleted,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isLiked': isLiked,
    'images': images.map((image) => image.toJson()).toList(),
  };

  bool get isActive => status == 'ACTIVE' && !isDeleted;
  bool get isApproved => approvalStatus == 'APPROVED';
  String get location => '($latitude, $longitude)';
  String get formattedRating => rating.toStringAsFixed(1);
  String get formattedAveragePrice => '\$${averagePrice.toStringAsFixed(2)}';

  @override
  String toString() => 'Shop(id: $id, name: $name, code: $code)';
}

class ShopMedia {
  final String id;
  final String shopId;
  final String mediaId;
  final Media media;

  const ShopMedia({required this.id, required this.shopId, required this.mediaId, required this.media});

  ShopMedia copyWith({String? id, String? shopId, String? mediaId, Media? media}) {
    return ShopMedia(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      mediaId: mediaId ?? this.mediaId,
      media: media ?? this.media,
    );
  }

  factory ShopMedia.fromJson(Map<String, dynamic> json) => ShopMedia(
    id: json['id'] as String? ?? "",
    shopId: json['shopId'] as String? ?? "",
    mediaId: json['mediaId'] as String? ?? "",
    media: Media.fromJson(json['media'] as Map<String, dynamic>? ?? {}),
  );

  Map<String, dynamic> toJson() => {'id': id, 'shopId': shopId, 'mediaId': mediaId, 'media': media.toJson()};
}

class Media {
  final String id;
  final String url;
  final String type;
  final DateTime createdAt;

  const Media({required this.id, required this.url, required this.type, required this.createdAt});

  Media copyWith({String? id, String? url, String? type, DateTime? createdAt}) {
    return Media(
      id: id ?? this.id,
      url: url ?? this.url,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    id: json['id'] as String? ?? "",
    url: json['url'] as String? ?? "",
    type: json['type'] as String? ?? "",
    createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
  );

  Map<String, dynamic> toJson() => {'id': id, 'url': url, 'type': type, 'createdAt': createdAt.toIso8601String()};
}
