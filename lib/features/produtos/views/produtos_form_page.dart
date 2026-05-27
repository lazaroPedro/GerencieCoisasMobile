import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../model/produto.dart';
import '../services/produto_service.dart'; // Importando o nosso service

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

  String? _fornecedorSelecionado;
  String? _categoriaSelecionada; // Alterado para String para seguir o padrão do Firebase
  bool _salvando = false;

  // Ajustado os IDs para String
  final List<Map<String, dynamic>> _categorias = [
    {'id': '1', 'nome': 'Eletrônicos'},
    {'id': '2', 'nome': 'Periféricos'},
    {'id': '3', 'nome': 'Armazenamento'},
  ];

  final List<String> _fornecedores = [
    'Tech Distribuidora Ltda',
    'InfoShop Comércio',
    'Gamer Store',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.produto?.name ?? '');
    _descriptionController = TextEditingController(text: widget.produto?.description ?? '');
    _priceController = TextEditingController(
      text: widget.produto != null ? widget.produto!.price.toStringAsFixed(2) : '',
    );
    _quantityController = TextEditingController(
      text: widget.produto?.quantity.toString() ?? '',
    );
    _fornecedorSelecionado = widget.produto?.supplier;
    _categoriaSelecionada = widget.produto?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final service = ProdutoService();
      
      // Cria o objeto Produto com os dados da tela
      final produtoParaSalvar = Produto(
        id: widget.produto?.id ?? '', // Se for edição, mantém o ID. Se for novo, manda vazio.
        name: _nameController.text,
        description: _descriptionController.text,
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text.replaceAll(',', '.')),
        supplier: _fornecedorSelecionado!,
        categoryId: _categoriaSelecionada!,
      );

      // Chama o serviço do Firebase (igual o colega fez nas movimentações)
      await service.salvar(produtoParaSalvar);

      if (!mounted) return;
      setState(() => _salvando = false);

      // SnackBar de Sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.produto == null 
              ? 'Produto cadastrado com sucesso!' 
              : 'Produto atualizado com sucesso!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Volta para a lista
      Navigator.pop(context);

    } catch (e) {
      // SnackBar de Erro caso a internet caia ou o Firebase reclame
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
              validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            _buildLabel('Descrição'),
            TextFormField(
              controller: _descriptionController,
              decoration: _inputDecoration(hint: 'Descrição detalhada do produto...'),
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
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
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
                        validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('Categoria'),
            // Ajustado para String
            DropdownButtonFormField<String>(
              value: _categoriaSelecionada,
              decoration: _inputDecoration(hint: 'Selecione a categoria'),
              items: _categorias.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat['id'],
                  child: Text(cat['nome']),
                );
              }).toList(),
              onChanged: (v) => setState(() => _categoriaSelecionada = v),
              validator: (v) => v == null ? 'Selecione uma categoria' : null,
            ),
            const SizedBox(height: 16),
            _buildLabel('Fornecedor'),
            DropdownButtonFormField<String>(
              value: _fornecedorSelecionado,
              decoration: _inputDecoration(hint: 'Selecione o fornecedor'),
              items: _fornecedores.map((f) {
                return DropdownMenuItem(value: f, child: Text(f));
              }).toList(),
              onChanged: (v) => setState(() => _fornecedorSelecionado = v),
              validator: (v) => v == null ? 'Selecione um fornecedor' : null,
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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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