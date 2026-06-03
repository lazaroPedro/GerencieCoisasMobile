import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class BiometriaService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> podeAutenticar() async {
    try {
      final isDisponivel = await _auth.canCheckBiometrics;
      final isSuportado = await _auth.isDeviceSupported();
      return isDisponivel && isSuportado;
    } on PlatformException catch (e) {
      debugPrint("Erro ao checar suporte biométrico: $e");
      return false;
    }
  }

  Future<bool> autenticar() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Use sua digital para entrar no Gerencie Coisas',
        persistAcrossBackgrounding: true,
        biometricOnly: true,
      );
    } on PlatformException catch (e) {
      debugPrint("Erro ao autenticar: $e");
      return false;
    }
  }
}