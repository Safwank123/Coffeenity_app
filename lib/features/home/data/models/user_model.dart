class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;
  final String userGroupId;
  final String domainId;
  final String status;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String zipcode;
  final List<UserPreferences> preferences;
  final Wallet wallet;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    required this.userGroupId,
    required this.domainId,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.zipcode,
    required this.preferences,
    required this.wallet,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    firstName: json['firstName']?.toString() ?? '',
    lastName: json['lastName']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    password: json['password']?.toString() ?? '',
    userGroupId: json['userGroupId']?.toString() ?? '',
    domainId: json['domainId']?.toString() ?? '',
    zipcode: json['zipcode']?.toString() ?? '',
    status: json['status']?.toString() ?? 'ACTIVE',
    isDeleted: json['isDeleted'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    preferences:
        (json['preferences'] as List<dynamic>?)
            ?.map((pref) => UserPreferences.fromJson(pref as Map<String, dynamic>? ?? {}))
            .toList() ??
        [],
    wallet: Wallet.fromJson(json['wallet'] as Map<String, dynamic>? ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'email': email,
    'password': password,
    'userGroupId': userGroupId,
    'domainId': domainId,
    'zipcode': zipcode,
    'status': status,
    'isDeleted': isDeleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'preferences': preferences.map((pref) => pref.toJson()).toList(),
    'wallet': wallet.toJson(),
  };

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? password,
    String? userGroupId,
    String? domainId,
    String? status,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<UserPreferences>? preferences,
    String? zipcode,
    Wallet? wallet,
  }) => UserModel(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    password: password ?? this.password,
    userGroupId: userGroupId ?? this.userGroupId,
    domainId: domainId ?? this.domainId,
    status: status ?? this.status,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    preferences: preferences ?? this.preferences,
    zipcode: zipcode ?? this.zipcode,
    wallet: wallet ?? this.wallet,
  );

  // Helper methods
  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    if (firstName.isEmpty && lastName.isEmpty) return '';
    if (lastName.isEmpty) return firstName.substring(0, 1).toUpperCase();
    return '${firstName.substring(0, 1)}${lastName.substring(0, 1)}'.toUpperCase();
  }

  bool get isActive => status == 'ACTIVE' && !isDeleted;

  UserPreferences? get primaryPreferences => preferences.isNotEmpty ? preferences.first : null;

  bool get hasPreferences => preferences.isNotEmpty;

  String get maskedPassword => '••••••••';

  String get maskedEmail {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 2) return email;
    final maskedUsername = '${username.substring(0, 2)}***';
    return '$maskedUsername@$domain';
  }

  String get maskedPhone {
    if (phone.length <= 4) return phone;
    return '${'•' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
  }

  Map<String, dynamic> toDisplayMap() => {
    'id': id,
    'fullName': fullName,
    'initials': initials,
    'phone': phone,
    'maskedPhone': maskedPhone,
    'email': email,
    'maskedEmail': maskedEmail,
    'status': status,
    'isActive': isActive,
    'hasPreferences': hasPreferences,
    'walletBalance': wallet.formattedBalance,
    'hasWalletBalance': wallet.hasBalance,
    'favouriteCoffees': primaryPreferences?.favouriteCoffee ?? ['No favourites'],
    'notificationSettings': '${primaryPreferences?.notificationType ?? "None"} ${primaryPreferences?.frequency ?? ""}',
    'createdAt': createdAt.toLocal().toString().split(' ')[0],
  };

  @override
  String toString() => 'User(id: $id, name: $fullName, email: $maskedEmail, active: $isActive)';
}

class UserPreferences {
  final String id;
  final String userId;
  final List<String> favouriteCoffee;
  final String notificationType;
  final String frequency;
  final bool isLocationEnabled;
  final double? latitude;
  final double? longitude;
  final bool isDeleted;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.id,
    required this.userId,
    required this.favouriteCoffee,
    required this.notificationType,
    required this.frequency,
    required this.isLocationEnabled,
    this.latitude,
    this.longitude,
    required this.isDeleted,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => UserPreferences(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    favouriteCoffee: (json['favouriteCoffee'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [],
    notificationType: json['notificationType']?.toString() ?? 'Daily',
    frequency: json['frequency']?.toString() ?? '1x',
    isLocationEnabled: json['isLocationEnabled'] as bool? ?? false,
    latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) ?? 0.0 : null,
    longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) ?? 0.0 : null,
    isDeleted: json['isDeleted'] as bool? ?? false,
    status: json['status']?.toString() ?? 'ACTIVE',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'favouriteCoffee': favouriteCoffee,
    'notificationType': notificationType,
    'frequency': frequency,
    'isLocationEnabled': isLocationEnabled,
    'latitude': latitude,
    'longitude': longitude,
    'isDeleted': isDeleted,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  UserPreferences copyWith({
    String? id,
    String? userId,
    List<String>? favouriteCoffee,
    String? notificationType,
    String? frequency,
    bool? isLocationEnabled,
    double? latitude,
    double? longitude,
    bool? isDeleted,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserPreferences(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    favouriteCoffee: favouriteCoffee ?? this.favouriteCoffee,
    notificationType: notificationType ?? this.notificationType,
    frequency: frequency ?? this.frequency,
    isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    isDeleted: isDeleted ?? this.isDeleted,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  // Helper methods
  String get locationStatus => isLocationEnabled
      ? 'Location enabled (${latitude?.toStringAsFixed(4)}, ${longitude?.toStringAsFixed(4)})'
      : 'Location disabled';

  bool get hasFavourites => favouriteCoffee.isNotEmpty;

  @override
  String toString() => 'UserPreferences(id: $id, favourites: ${favouriteCoffee.length}, location: $isLocationEnabled)';
}

class Wallet {
  final String id;
  final String userId;
  final double balance;
  final String domainId;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.domainId,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
    domainId: json['domainId']?.toString() ?? '',
    isDeleted: json['isDeleted'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'balance': balance.toStringAsFixed(2),
    'domainId': domainId,
    'isDeleted': isDeleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  Wallet copyWith({
    String? id,
    String? userId,
    double? balance,
    String? domainId,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Wallet(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    balance: balance ?? this.balance,
    domainId: domainId ?? this.domainId,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  // Helper methods
  String get formattedBalance => '\$${balance.toStringAsFixed(2)}';

  bool get hasBalance => balance > 0;

  bool get isActive => !isDeleted;

  @override
  String toString() => 'Wallet(id: $id, balance: $formattedBalance)';
}
