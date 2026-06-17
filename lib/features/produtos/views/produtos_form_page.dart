import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/services/barcode_scanner_service.dart';
import '../../../core/theme/app_colors.dart';
import '../model/produto.dart';
import '../services/produto_service.dart';
import '../../categorias/model/categoria_model.dart';
import '../../categorias/repositories/categoria_repository.dart';

class ProdutosFormPage extends StatefulWidget {
  final Produto? produto;

  const ProdutosFormPage({super.key, this.produto});

  @override
  State<ProdutosFormPage> createState() => _ProdutosFormPageState();
}

class _ProdutosFormPageState extends State<ProdutosFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _supplierController;
  late TextEditingController _barcodeController;

  String? _categoriaSelecionada;
  bool _salvando = false;
  bool _carregandoDados = true;
  List<CategoriaModel> _categoriasReais = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.produto?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.produto?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.produto != null ? widget.produto!.price.toString() : '',
    );
    _quantityController = TextEditingController(
      text: widget.produto != null ? widget.produto!.quantity.toString() : '',
    );
    _supplierController = TextEditingController(
      text: widget.produto?.supplier ?? '',
    );
    _barcodeController = TextEditingController(
      text: widget.produto?.barcode ?? '',
    );
    _categoriaSelecionada = widget.produto?.categoryId;
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      final categoriaRepo = CategoriaRepository();
      final categoriasDoBanco = await categoriaRepo.getAll();

      if (!mounted) return;
      setState(() {
        _categoriasReais = categoriasDoBanco;
        _carregandoDados = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregandoDados = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _supplierController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _lerCodigoDeBarras() async {
    final barcode = await BarcodeScannerService().scanBarcode(context);
    if (barcode == null || !mounted) return;

    setState(() => _barcodeController.text = barcode);
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final service = ProdutoService();

      final produtoParaSalvar = Produto(
        id: widget.produto?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text.replaceAll(',', '.')),
        supplier: _supplierController.text.trim(),
        categoryId: _categoriaSelecionada!,
        barcode:
            _barcodeController.text.trim().isEmpty
                ? null
                : _barcodeController.text.trim(),
      );

      await service.salvar(produtoParaSalvar);

      if (!mounted) return;
      setState(() => _salvando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.produto == null
                ? 'msg_produto_cadastrado'.tr()
                : 'msg_produto_atualizado'.tr(),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('erro_salvar'.tr(args: [e.toString()])),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.produto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'titulo_editar_produto'.tr() : 'botao_novo_produto'.tr()),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildLabel('label_nome'.tr()),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(
                label: 'label_nome'.tr(),
                hint: 'hint_nome_produto'.tr(),
              ),
              validator:
                  (v) =>
                      v == null || v.trim().isEmpty
                          ? 'erro_campo_obrigatorio'.tr()
                          : null,
            ),
            const SizedBox(height: 16),

            _buildLabel('label_descricao'.tr()),
            TextFormField(
              controller: _descriptionController,
              decoration: _inputDecoration(
                label: 'label_descricao'.tr(),
                hint: 'hint_descricao_produto'.tr(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('label_preco_rs'.tr()),
                      TextFormField(
                        controller: _priceController,
                        decoration: _inputDecoration(
                          label: 'hint_preco_reais'.tr(),
                          hint: 'hint_zero_zero'.tr(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'erro_obrigatorio'.tr() : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('label_quantidade'.tr()),
                      TextFormField(
                        controller: _quantityController,
                        decoration: _inputDecoration(
                          label: 'label_quantidade'.tr(),
                          hint: 'hint_ex_10'.tr(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'erro_obrigatorio'.tr() : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildLabel('label_codigo_barras'.tr()),
            TextFormField(
              controller: _barcodeController,
              decoration: _inputDecoration(
                label: 'label_codigo_barras'.tr(),
                hint: 'hint_digite_leia_codigo'.tr(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  tooltip: 'tooltip_ler_codigo'.tr(),
                  onPressed: _lerCodigoDeBarras,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            _buildLabel('label_categoria'.tr()),
            _carregandoDados
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                  initialValue: _categoriaSelecionada,
                  decoration: _inputDecoration(
                    label: 'label_categoria'.tr(),
                    hint: 'hint_selecione_categoria'.tr(),
                  ),
                  items:
                      _categoriasReais.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat.id,
                          child: Text(cat.name),
                        );
                      }).toList(),
                  onChanged: (v) => setState(() => _categoriaSelecionada = v),
                  validator:
                      (v) => v == null ? 'erro_selecione_categoria'.tr() : null,
                ),
            const SizedBox(height: 16),

            _buildLabel('label_fornecedor'.tr()),
            TextFormField(
              controller: _supplierController,
              decoration: _inputDecoration(
                label: 'label_fornecedor'.tr(),
                hint: 'hint_nome_fornecedor'.tr(),
              ),
              validator:
                  (v) =>
                      v == null || v.trim().isEmpty
                          ? 'erro_campo_obrigatorio'.tr()
                          : null,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                child:
                    _salvando
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          isEditing ? 'botao_atualizar_produto'.tr() : 'botao_salvar_produto'.tr(), 
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    );
  }
}