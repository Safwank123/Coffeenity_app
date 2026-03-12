class UserPreferenceRequest {
  final List<String> favouriteCoffee;
  final String notificationType;
  final String frequency;
  final bool isLocationEnabled;
  final double? latitude;
  final double? longitude;

  const UserPreferenceRequest({
    required this.favouriteCoffee,
    required this.notificationType,
    required this.frequency,
    required this.isLocationEnabled,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'favouriteCoffee': favouriteCoffee,
    'notificationType': notificationType,
    'frequency': frequency,
    'isLocationEnabled': isLocationEnabled,
    'latitude': latitude,
    'longitude': longitude,
  }..removeWhere((key, value) => value == null);
}
