import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String? _categoriaSelecionada; 
  bool _salvando = false;
  bool _carregandoDados = true;
  List<CategoriaModel> _categoriasReais = [];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.produto?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.produto?.description ?? '');
    _priceController = TextEditingController(
        text: widget.produto != null
            ? widget.produto!.price.toString()
            : '');
    _quantityController = TextEditingController(
        text: widget.produto != null
            ? widget.produto!.quantity.toString()
            : '');
    _supplierController =
        TextEditingController(text: widget.produto?.supplier ?? '');
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
    super.dispose();
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final service = ProdutoService();
      
      // Cria o objeto Produto com os dados da tela
      final produtoParaSalvar = Produto(
        id: widget.produto?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text.replaceAll(',', '.')),
        supplier: _supplierController.text.trim(),
        categoryId: _categoriaSelecionada!,
      );

      await service.salvar(produtoParaSalvar);

      if (!mounted) return;
      setState(() => _salvando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.produto == null 
              ? 'Produto cadastrado com sucesso!' 
              : 'Produto atualizado com sucesso!'),
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
          content: Text('Erro ao salvar: $e'),
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
        title: Text(isEditing ? 'Editar Produto' : 'Novo Produto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildLabel('Nome'),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(hint: 'Nome do produto'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),

            _buildLabel('Descrição'),
            TextFormField(
              controller: _descriptionController,
              decoration:
                  _inputDecoration(hint: 'Descrição detalhada do produto...'),
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
                      _buildLabel('Preço (R\$)'),
                      TextFormField(
                        controller: _priceController,
                        decoration: _inputDecoration(hint: '0.00'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]')),
                        ],
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Quantidade'),
                      TextFormField(
                        controller: _quantityController,
                        decoration: _inputDecoration(hint: 'Ex: 10'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Categoria (dropdown do Firebase)
            _buildLabel('Categoria'),
            _carregandoDados
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: _categoriaSelecionada,
                    decoration:
                        _inputDecoration(hint: 'Selecione a categoria'),
                    items: _categoriasReais.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => _categoriaSelecionada = v),
                    validator: (v) =>
                        v == null ? 'Selecione uma categoria' : null,
                  ),
            const SizedBox(height: 16),

            // Fornecedor (texto livre)
            _buildLabel('Fornecedor'),
            TextFormField(
              controller: _supplierController,
              decoration: _inputDecoration(hint: 'Nome do fornecedor'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? 'Atualizar Produto' : 'Salvar Produto',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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