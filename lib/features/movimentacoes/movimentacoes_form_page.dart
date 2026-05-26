import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'movimentacao_model.dart';
import 'services/movimentacao_service.dart';

class MovimentacoesFormPage extends StatefulWidget {
  const MovimentacoesFormPage({super.key});

  @override
  State<MovimentacoesFormPage> createState() => _MovimentacoesFormPageState();
}

class _MovimentacoesFormPageState extends State<MovimentacoesFormPage> {
  final _formKey = GlobalKey<FormState>();

  TipoMovimentacao _tipo = TipoMovimentacao.entrada;
  String? _produtoSelecionado;
  String? _fornecedorSelecionado;
  final _quantidadeController = TextEditingController();
  final _valorController = TextEditingController();
  final _observacaoController = TextEditingController();

  // Dados falsos
  final List<String> _produtos = [
    'Notebook Dell Inspiron 15',
    'Mouse sem fio Logitech M705',
    'Teclado Mecânico Redragon K552',
    'Monitor LG 24" Full HD',
    'SSD Kingston 480GB',
  ];

  final List<String> _fornecedores = [
    'Tech Distribuidora Ltda',
    'InfoShop Comércio',
    'Gamer Store',
    'Conect Acessórios',
    'MegaInfo LTDA',
  ];

  bool _salvando = false;

  @override
  void dispose() {
    _quantidadeController.dispose();
    _valorController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }
void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try { // <--- ADICIONADO: Início do bloco de tentativa
      final service = MovimentacaoService();
      await service.salvar(Movimentacao(
        id: '',
        produto: _produtoSelecionado!,
        fornecedor: _fornecedorSelecionado!,
        categoria: 'sem categoria',
        tipo: _tipo,
        quantidade: int.parse(_quantidadeController.text),
        valorUnitario:
            double.parse(_valorController.text.replaceAll(',', '.')),
        data: DateTime.now(),
        observacao: _observacaoController.text.isEmpty
            ? null
            : _observacaoController.text,
      ));

      if (!mounted) return;
      setState(() => _salvando = false); // <--- MODIFICADO: Movido para dentro do try

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Movimentação registrada com sucesso!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) { // <--- ADICIONADO: Bloco para capturar e tratar o erro
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFC62828), // SnackBar vermelha de erro
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEntrada = _tipo == TipoMovimentacao.entrada;
    final tipoColor = isEntrada ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text(
          'Nova Movimentação',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seletor de tipo
            _SectionLabel(label: 'Tipo de movimentação'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TipoButton(
                    label: 'Entrada',
                    icon: Icons.arrow_downward_rounded,
                    color: const Color(0xFF2E7D32),
                    background: const Color(0xFFE8F5E9),
                    selected: isEntrada,
                    onTap: () =>
                        setState(() => _tipo = TipoMovimentacao.entrada),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TipoButton(
                    label: 'Saída',
                    icon: Icons.arrow_upward_rounded,
                    color: const Color(0xFFC62828),
                    background: const Color(0xFFFFEBEE),
                    selected: !isEntrada,
                    onTap: () =>
                        setState(() => _tipo = TipoMovimentacao.saida),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Produto
            _SectionLabel(label: 'Produto'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _produtoSelecionado,
              decoration: _inputDecoration(
                context,
                hint: 'Selecione o produto',
                prefixIcon: Icons.inventory_2_outlined,
              ),
              items: _produtos
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _produtoSelecionado = v),
              validator: (v) =>
                  v == null ? 'Selecione um produto' : null,
            ),
            const SizedBox(height: 16),

            // Fornecedor
            _SectionLabel(label: 'Fornecedor'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _fornecedorSelecionado,
              decoration: _inputDecoration(
                context,
                hint: 'Selecione o fornecedor',
                prefixIcon: Icons.store_outlined,
              ),
              items: _fornecedores
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) => setState(() => _fornecedorSelecionado = v),
              validator: (v) =>
                  v == null ? 'Selecione um fornecedor' : null,
            ),
            const SizedBox(height: 16),

            // Quantidade e Valor lado a lado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'Quantidade'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _quantidadeController,
                        decoration: _inputDecoration(
                          context,
                          hint: 'Ex: 10',
                          prefixIcon: Icons.numbers_rounded,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obrigatório';
                          if (int.tryParse(v) == null || int.parse(v) <= 0) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'Valor unit. (R\$)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _valorController,
                        decoration: _inputDecoration(
                          context,
                          hint: 'Ex: 99,90',
                          prefixIcon: Icons.attach_money_rounded,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]')),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obrigatório';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Observação
            _SectionLabel(label: 'Observação (opcional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _observacaoController,
              decoration: _inputDecoration(
                context,
                hint: 'Adicione uma observação...',
                prefixIcon: Icons.notes_rounded,
              ),
              maxLines: 3,
              minLines: 3,
            ),
            const SizedBox(height: 32),

            // Botão salvar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isEntrada
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                      ),
                label: Text(
                  _salvando
                      ? 'Salvando...'
                      : 'Registrar ${isEntrada ? 'Entrada' : 'Saída'}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: tipoColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData prefixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefixIcon, size: 20),
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: colorScheme.outline.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC62828)),
      ),
    );
  }
}

// ───────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
    );
  }
}

class _TipoButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;
  final bool selected;
  final VoidCallback onTap;

  const _TipoButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color : colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : colorScheme.outline.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? Colors.white : color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}