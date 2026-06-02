import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
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

  Future<void> _login() async {
    if (_localizacao == null) {
      setState(() => _erro = 'Obtenha sua localização antes de continuar.');
      return;
    }
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _erro = 'Preencha e-mail e senha.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _localizacao!,
      );
      // Login OK — o StreamBuilder no main.dart redireciona automaticamente
    } on FirebaseAuthException catch (e) {
      setState(() => _erro = _authService.translateError(e.code));
    } catch (e) {
      setState(() => _erro = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
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

              // Botão entrar
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
          Expanded(
            child: Text(
              'Localização obtida.',
              style: const TextStyle(
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
