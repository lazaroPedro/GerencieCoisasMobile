import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_location_model.dart';
import 'location_service.dart';
import 'package:geolocator/geolocator.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> register(
    String email,
    String password,
    UserLocationModel location,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'registeredCity': location.city,
      'registeredCountry': location.country,
      'registeredAt': FieldValue.serverTimestamp(),
      'location': location.toMap(),
    });
  }

  Future<void> login(
    String email,
    String password,
    UserLocationModel location,
  ) async {
    // 1. Busca o documento pelo email SEM autenticar ainda
    final query =
        await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      // Não revela se o email existe ou não — mesma mensagem genérica
      throw Exception('E-mail ou senha incorretos.');
    }

    final data = query.docs.first.data();

    // 2. Verifica a distância ANTES de qualquer autenticação
    final savedLat = (data['location']['latitude'] as num).toDouble();
    final savedLng = (data['location']['longitude'] as num).toDouble();

    final distance = Geolocator.distanceBetween(
      savedLat,
      savedLng,
      location.latitude,
      location.longitude,
    );

    const maxDistanceMeters = 5000.0; // 5 km

    if (distance > maxDistanceMeters) {
      throw Exception(
        'Acesso negado. Você está muito distante do local onde a conta foi criada.',
      );
    }

    // 3. Localização OK — agora autentica
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String translateError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'Senha fraca. Use ao menos 6 caracteres.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      default:
        return 'Erro inesperado: $code';
    }
  }
}
