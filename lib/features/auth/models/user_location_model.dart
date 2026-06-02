class UserLocationModel {
  final double latitude;
  final double longitude;
  final String city;
  final String country;

  UserLocationModel({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
  });

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
    'city': city,
    'country': country,
  };

  factory UserLocationModel.fromMap(Map<String, dynamic> map) =>
      UserLocationModel(
        latitude: map['latitude'],
        longitude: map['longitude'],
        city: map['city'],
        country: map['country'],
      );
}
