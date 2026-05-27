import 'package:flutter/material.dart';
import 'package:gerencie_coisas/features/categorias/view_model/categoria_view_model.dart';

class DeleteCategoriaView extends StatefulWidget {
  final CategoriaViewModel viewModel;
  final String categoriaId;

  const DeleteCategoriaView({
    super.key,
    required this.viewModel,
    required this.categoriaId,
  });

  @override
  State<DeleteCategoriaView> createState() =>
      _DeleteCategoriaViewState();
}

class _DeleteCategoriaViewState
    extends State<DeleteCategoriaView> {
  bool loading = false;

  Future<void> delete() async {
    setState(() {
      loading = true;
    });

    await widget.viewModel.deleteCategoria(
      widget.categoriaId,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excluir Categoria'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            const Text(
              'Deseja realmente excluir esta categoria?',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: loading ? null : delete,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Excluir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}