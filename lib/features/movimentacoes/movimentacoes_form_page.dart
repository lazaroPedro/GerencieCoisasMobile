import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/services/barcode_scanner_service.dart';
import 'movimentacao_model.dart';
import 'services/movimentacao_service.dart';
import '../produtos/model/produto.dart';
import '../produtos/services/produto_service.dart';

class MovimentacoesFormPage extends StatefulWidget {
  const MovimentacoesFormPage({super.key});

  @override
  State<MovimentacoesFormPage> createState() => _MovimentacoesFormPageState();
}

class _MovimentacoesFormPageState extends State<MovimentacoesFormPage> {
  final _formKey = GlobalKey<FormState>();

  TipoMovimentacao _tipo = TipoMovimentacao.entrada;
  String? _produtoSelecionadoId;
  final _barcodeController = TextEditingController();
  final _fornecedorController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _valorController = TextEditingController();
  final _observacaoController = TextEditingController();

  bool _salvando = false;
  bool _carregandoDados = true;
  List<Produto> _produtosReais = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      final produtoService = ProdutoService();
      final produtosDoBanco = await produtoService.listar();

      if (!mounted) return;
      setState(() {
        _produtosReais = produtosDoBanco;
        _carregandoDados = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregandoDados = false);
    }
  }

  Produto? get _produtoSelecionado {
    if (_produtoSelecionadoId == null) return null;

    for (final produto in _produtosReais) {
      if (produto.id == _produtoSelecionadoId) return produto;
    }

    return null;
  }

  Produto? _produtoPorCodigo(String barcode) {
    final codigo = barcode.trim();
    if (codigo.isEmpty) return null;

    for (final produto in _produtosReais) {
      if (produto.barcode == codigo) return produto;
    }

    return null;
  }

  void _preencherProduto(Produto produto) {
    setState(() {
      _produtoSelecionadoId = produto.id;
      _barcodeController.text = produto.barcode ?? '';
      _fornecedorController.text = produto.supplier;
      _valorController.text = produto.price.toStringAsFixed(2);
    });
  }

  void _selecionarProdutoPorCodigo(String barcode) {
    final produto = _produtoPorCodigo(barcode);

    if (produto != null) {
      _preencherProduto(produto);
      return;
    }

    setState(() => _barcodeController.text = barcode.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('msg_nenhum_produto_codigo'.tr()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFC62828),
      ),
    );
  }

  Future<void> _lerCodigoDeBarras() async {
    final barcode = await BarcodeScannerService().scanBarcode(context);
    if (barcode == null || !mounted) return;

    _selecionarProdutoPorCodigo(barcode);
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _fornecedorController.dispose();
    _quantidadeController.dispose();
    _valorController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    final produtoSelecionado = _produtoSelecionado;

    try {
      final service = MovimentacaoService();
      await service.salvar(
        Movimentacao(
          id: '',
          produto: produtoSelecionado!.name,
          fornecedor: _fornecedorController.text.trim(),
          categoria:
              produtoSelecionado.categoryId.isEmpty
                  ? 'sem categoria'
                  : produtoSelecionado.categoryId,
          tipo: _tipo,
          quantidade: int.parse(_quantidadeController.text),
          valorUnitario: double.parse(
            _valorController.text.replaceAll(',', '.'),
          ),
          data: DateTime.now(),
          observacao:
              _observacaoController.text.isEmpty
                  ? null
                  : _observacaoController.text,
        ),
      );

      if (!mounted) return;
      setState(() => _salvando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('msg_movimentacao_sucesso'.tr()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
          action: SnackBarAction(
            label: 'botao_ok'.tr(),
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('erro_salvar'.tr(args: [e.toString()])),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEntrada = _tipo == TipoMovimentacao.entrada;
    final tipoColor =
        isEntrada ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'titulo_nova_movimentacao'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w700),
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
            _SectionLabel(label: 'label_tipo_movimentacao'.tr()),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TipoButton(
                    label: 'label_entrada'.tr(),
                    icon: Icons.arrow_downward_rounded,
                    color: const Color(0xFF2E7D32),
                    background: const Color(0xFFE8F5E9),
                    selected: isEntrada,
                    onTap:
                        () => setState(() => _tipo = TipoMovimentacao.entrada),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TipoButton(
                    label: 'label_saida'.tr(),
                    icon: Icons.arrow_upward_rounded,
                    color: const Color(0xFFC62828),
                    background: const Color(0xFFFFEBEE),
                    selected: !isEntrada,
                    onTap: () => setState(() => _tipo = TipoMovimentacao.saida),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _SectionLabel(label: 'label_codigo_barras'.tr()),
            const SizedBox(height: 8),
            TextFormField(
              controller: _barcodeController,
              decoration: _inputDecoration(
                context,
                label: 'label_codigo_barras'.tr(),
                hint: 'hint_leia_digite_codigo'.tr(),
                prefixIcon: Icons.qr_code_rounded,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  tooltip: 'tooltip_ler_codigo'.tr(),
                  onPressed: _carregandoDados ? null : _lerCodigoDeBarras,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onFieldSubmitted:
                  _carregandoDados
                      ? null
                      : (value) => _selecionarProdutoPorCodigo(value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _carregandoDados ? null : _lerCodigoDeBarras,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text('botao_comecar_leitura'.tr()),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel(label: 'label_produto'.tr()),
            const SizedBox(height: 8),
            _carregandoDados
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                  initialValue: _produtoSelecionadoId,
                  decoration: _inputDecoration(
                    context,
                    label: 'label_produto'.tr(),
                    hint: 'hint_selecione_produto'.tr(),
                    prefixIcon: Icons.inventory_2_outlined,
                  ),
                  items:
                      _produtosReais.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(p.name),
                        );
                      }).toList(),
                  onChanged: (v) {
                    if (v == null) {
                      setState(() => _produtoSelecionadoId = null);
                      return;
                    }

                    final produto = _produtosReais.firstWhere((p) => p.id == v);
                    _preencherProduto(produto);
                  },
                  validator: (v) => v == null ? 'erro_selecione_produto'.tr() : null,
                ),
            const SizedBox(height: 16),

            _SectionLabel(label: 'label_fornecedor'.tr()),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fornecedorController,
              decoration: _inputDecoration(
                context,
                label: 'label_fornecedor'.tr(),
                hint: 'hint_nome_fornecedor'.tr(),
                prefixIcon: Icons.store_outlined,
              ),
              validator:
                  (v) =>
                      v == null || v.trim().isEmpty
                          ? 'erro_campo_obrigatorio'.tr()
                          : null,
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'label_quantidade'.tr()),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _quantidadeController,
                        decoration: _inputDecoration(
                          context,
                          label: 'label_quantidade'.tr(),
                          hint: 'hint_ex_10'.tr(),
                          prefixIcon: Icons.numbers_rounded,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'erro_obrigatorio'.tr();
                          if (int.tryParse(v) == null || int.parse(v) <= 0) {
                            return 'erro_invalido'.tr();
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
                      _SectionLabel(label: 'label_valor_unitario'.tr()),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _valorController,
                        decoration: _inputDecoration(
                          context,
                          label: 'hint_valor_unitario'.tr(),
                          hint: 'hint_ex_99_90'.tr(),
                          prefixIcon: Icons.attach_money_rounded,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'erro_obrigatorio'.tr();
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _SectionLabel(label: 'label_observacao'.tr()),
            const SizedBox(height: 8),
            TextFormField(
              controller: _observacaoController,
              decoration: _inputDecoration(
                context,
                label: 'hint_observacao'.tr(),
                hint: 'hint_adicione_observacao'.tr(),
                prefixIcon: Icons.notes_rounded,
              ),
              maxLines: 3,
              minLines: 3,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon:
                    _salvando
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
                      ? 'botao_salvando'.tr()
                      : isEntrada ? 'botao_registrar_entrada'.tr() : 'botao_registrar_saida'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
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
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC62828)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
    return Semantics(
      button: true,
      selected: selected,
      label: 'semantics_tipo_movimentacao'.tr(args: [label]),
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: selected ? color : colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    selected
                        ? color
                        : colorScheme.outline.withValues(alpha: 0.3),
                width: selected ? 2 : 1,
              ),
              boxShadow:
                  selected
                      ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                      : [],
            ),
            child: Column(
              children: [
                Icon(icon, color: selected ? Colors.white : color, size: 28),
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
        ),
      ),
    );
  }
}