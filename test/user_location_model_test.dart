import 'package:flutter_test/flutter_test.dart';
import 'package:gerencie_coisas/features/auth/models/user_location_model.dart';

void main() {
  group('UserLocationModel', () {
    test('deve converter localizacao para Map', () {
      final location = UserLocationModel(
        latitude: -12.9714,
        longitude: -38.5014,
        city: 'Salvador',
        country: 'Brasil',
      );

      expect(location.toMap(), {
        'latitude': -12.9714,
        'longitude': -38.5014,
        'city': 'Salvador',
        'country': 'Brasil',
      });
    });

    test('deve criar localizacao a partir de Map', () {
      final location = UserLocationModel.fromMap({
        'latitude': -12.9714,
        'longitude': -38.5014,
        'city': 'Salvador',
        'country': 'Brasil',
      });

      expect(location.latitude, -12.9714);
      expect(location.longitude, -38.5014);
      expect(location.city, 'Salvador');
      expect(location.country, 'Brasil');
    });
  });
}
