import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../models/user_location_model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _authService = AuthService();
  final _locationService = LocationService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure = true;
  bool _carregando = false;
  String? _erro;
  UserLocationModel? _localizacao;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
      if (mounted) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          'msg_localizacao_sucesso'.tr(), 
          Directionality.of(context),
        );
      }
    } catch (e) {
      setState(() => _erro = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _registrar() async {
    if (_localizacao == null) {
      setState(() => _erro = 'erro_obter_localizacao'.tr()); 
      SemanticsService.sendAnnouncement(
        View.of(context),
        _erro!,
        Directionality.of(context),
      );
      return;
    }
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _erro = 'erro_preencher_campos'.tr()); 
      SemanticsService.sendAnnouncement(
        View.of(context),
        _erro!,
        Directionality.of(context),
      );
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _erro = 'erro_senhas_nao_coincidem'.tr()); 
      SemanticsService.sendAnnouncement(
        View.of(context),
        _erro!,
        Directionality.of(context),
      );
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await _authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _localizacao!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('msg_conta_criada'.tr()), 
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context); // volta para login
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
      appBar: AppBar(
        title: Text(
          'titulo_criar_conta'.tr(), 
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'subtitulo_criar_conta'.tr(), 
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),

              // Localização
              _localizacao != null
                  ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const ExcludeSemantics(
                          child: Icon(Icons.location_on, color: Colors.green),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'cidade_registro'.tr(args: [_localizacao!.city]), // 
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : OutlinedButton.icon(
                    icon:
                        _carregando
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.my_location),
                    label: Text('botao_obter_localizacao'.tr()), 
                    onPressed: _carregando ? null : _obterLocalizacao,
                  ),

              const SizedBox(height: 20),

              _labelSecao('label_email'.tr()), 
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  context,
                  label: 'label_email'.tr(), 
                  hint: 'hint_email'.tr(), 
                  icone: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 16),

              _labelSecao('label_senha'.tr()), 
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                autofillHints: const [AutofillHints.newPassword],
                obscureText: _obscure,
                decoration: _inputDecoration(
                  context,
                  label: 'label_senha'.tr(), 
                  hint: 'hint_senha'.tr(), 
                  icone: Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'tooltip_mostrar_senha'.tr() : 'tooltip_ocultar_senha'.tr(), 
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _labelSecao('label_confirmar_senha'.tr()), 
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmController,
                autofillHints: const [AutofillHints.newPassword],
                obscureText: _obscure,
                decoration: _inputDecoration(
                  context,
                  label: 'label_confirmar_senha'.tr(), 
                  hint: 'hint_senha'.tr(), 
                  icone: Icons.lock_outline,
                ),
              ),
              const SizedBox(height: 24),

              if (_erro != null)
                Semantics(
                  liveRegion: true,
                  label: 'erro_prefixo'.tr(args: [_erro!]), 
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _erro!,
                      style: TextStyle(color: colorScheme.onErrorContainer),
                    ),
                  ),
                ),
              if (_erro != null) const SizedBox(height: 16),

              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _carregando ? null : _registrar,
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
                          : const Icon(Icons.person_add),
                  label: Text(
                    _carregando ? 'botao_criando_conta'.tr() : 'botao_criar_conta'.tr(), 
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelSecao(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icone,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icone, size: 20),
      filled: true,
      fillColor: cs.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
    );
  }
}