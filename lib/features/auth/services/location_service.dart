import 'package:geolocator/geolocator.dart';
import '../models/user_location_model.dart';

class LocationService {
  Future<UserLocationModel> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Serviço de localização desativado. Ative o GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização permanentemente negada. Habilite nas configurações.',
      );
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    return UserLocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      city: '',
      country: '',
    );
  }

  bool isSameCity(String cityA, String cityB) {
    return _normalize(cityA) == _normalize(cityB);
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[àáâã]'), 'a')
        .replaceAll(RegExp(r'[èéê]'), 'e')
        .replaceAll(RegExp(r'[ìíî]'), 'i')
        .replaceAll(RegExp(r'[òóôõ]'), 'o')
        .replaceAll(RegExp(r'[ùúû]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }
}
