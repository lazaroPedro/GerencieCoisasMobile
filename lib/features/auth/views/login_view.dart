import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/biometria_service.dart';
import '../models/user_location_model.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _authService = AuthService();
  final _locationService = LocationService();
  final _biometriaService = BiometriaService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _carregando = false;
  String? _erro;
  UserLocationModel? _localizacao;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _obterLocalizacao() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final loc = await _locationService.getCurrentLocation();
      setState(() => _localizacao = loc);
    } catch (e) {
      setState(() => _erro = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _carregando = false);
    }
  }

  // LOGIN TRADICIONAL (E-MAIL E SENHA)
  Future<void> _login() async {
    if (_localizacao == null) {
      setState(() => _erro = 'Obtenha sua localização antes de continuar.');
      return;
    }
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _erro = 'Preencha e-mail e senha.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final email = _emailController.text.trim();
      final senha = _passwordController.text.trim();

      await _authService.login(email, senha, _localizacao!);
      
      // SALVA AS CREDENCIAIS PARA A BIOMETRIA USAR DEPOIS
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', senha);

      // Login OK — o StreamBuilder redireciona
    } on FirebaseAuthException catch (e) {
      setState(() => _erro = _authService.translateError(e.code));
    } catch (e) {
      setState(() => _erro = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // LOGIN COM BIOMETRIA
  Future<void> _loginComBiometria() async {
    setState(() => _erro = null);

    // 1. Verifica se a digital está configurada no aparelho
    final disponivel = await _biometriaService.podeAutenticar();
    if (!disponivel) {
      setState(() => _erro = 'Biometria não disponível neste aparelho.');
      return;
    }

    // 2. Aciona o sensor na tela
    final sucesso = await _biometriaService.autenticar();

    if (sucesso) {
      setState(() => _carregando = true);
      try {
        // 3. Busca os dados salvos do último login
        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('saved_email');
        final savedPassword = prefs.getString('saved_password');

        if (savedEmail != null && savedPassword != null) {
          // Garante que temos a localização antes de logar
          if (_localizacao == null) {
            await _obterLocalizacao();
          }
          
          // 4. Faz o login no Firebase silenciosamente
          await _authService.login(savedEmail, savedPassword, _localizacao!);
          
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Autenticado com biometria com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Se não tem dados salvos, pede pra logar com senha a primeira vez
          setState(() => _erro = 'Para usar a biometria, faça login com e-mail e senha a primeira vez.');
        }
      } on FirebaseAuthException catch (e) {
        setState(() => _erro = _authService.translateError(e.code));
      } catch (e) {
        setState(() => _erro = e.toString().replaceAll('Exception: ', ''));
      } finally {
        if (mounted) setState(() => _carregando = false);
      }
    } else {
      setState(() => _erro = 'Falha na autenticação biométrica.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Icon(
                Icons.checklist_rounded,
                size: 72,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Gerencie Coisas',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Faça login para continuar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Bloco de localização
              _localizacao != null
                  ? _blocoLocalizacaoOk(_localizacao!.city)
                  : OutlinedButton.icon(
                    icon:
                        _carregando
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.my_location),
                    label: const Text('Obter Localização'),
                    onPressed: _carregando ? null : _obterLocalizacao,
                  ),

              const SizedBox(height: 24),

              // E-mail
              _labelSecao('E-mail'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  context,
                  hint: 'seu@email.com',
                  icone: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 16),

              // Senha
              _labelSecao('Senha'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration(
                  context,
                  hint: '••••••••',
                  icone: Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Erro
              if (_erro != null) _blocoErro(_erro!, colorScheme),
              if (_erro != null) const SizedBox(height: 16),

              // Botão entrar tradicional
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _carregando ? null : _login,
                  icon:
                      _carregando
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.login),
                  label: Text(
                    _carregando ? 'Entrando...' : 'Entrar',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),

              // <-- DIVISOR VISUAL -->
              Row(
                children: [
                  Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OU',
                      style: TextStyle(color: colorScheme.outline, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.3))),
                ],
              ),
              
              const SizedBox(height: 16),

              // <-- NOVO BOTÃO DE BIOMETRIA -->
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _carregando ? null : _loginComBiometria,
                  icon: const Icon(Icons.fingerprint, size: 28),
                  label: const Text(
                    'Entrar com a Digital',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterView()),
                  );
                },
                child: const Text('Não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blocoLocalizacaoOk(String cidade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.green),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Localização obtida.',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _obterLocalizacao,
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  Widget _blocoErro(String mensagem, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(mensagem, style: TextStyle(color: cs.onErrorContainer)),
    );
  }

  Widget _labelSecao(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icone,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icone, size: 20),
      filled: true,
      fillColor: cs.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
    );
  }
}