import 'package:flutter/material.dart';
import 'package:gerencie_coisas/features/categorias/model/categoria_model.dart';
import 'package:gerencie_coisas/features/categorias/view_model/categoria_view_model.dart';

class CreateCategoriaView extends StatefulWidget {
  final CategoriaViewModel viewModel;

  const CreateCategoriaView({
    super.key,
    required this.viewModel,
  });

  @override
  State<CreateCategoriaView> createState() =>
      _CreateCategoriaViewState();
}

class _CreateCategoriaViewState extends State<CreateCategoriaView> {
  final TextEditingController nameController = TextEditingController();
  List<CategoriaModel> parentCategorias = [];
  String? parentId;
  bool loading = false;

  Future<void> save() async {
    if (nameController.text.trim().isEmpty) return;

    setState(() {
      loading = true;
    });

    final categoria = CategoriaModel(
      id: '',
      name: nameController.text.trim(),
      parentId: parentId!.isNotEmpty ? parentId : null,
    );

    await widget.viewModel.addCategoria(categoria);

    if (mounted) {
      Navigator.pop(context);
    }
  }
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadParentCategorias().then((categorias) {
      setState(() {
        parentCategorias = categorias;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Categoria'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: nameController,

              decoration: const InputDecoration(
                labelText: 'Nome da categoria',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String?>(
                    value: parentId,

                    decoration: const InputDecoration(
                      labelText: 'Categoria Pai',
                      border: OutlineInputBorder(),
                    ),

                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sem categoria pai'),
                      ),

                      ...parentCategorias.map(
                        (categoria) {
                          return DropdownMenuItem(
                            value: categoria.id,
                            child: Text(categoria.name),
                          );
                        },
                      ),
                    ],

                    onChanged: (value) {
                      setState(() {
                        parentId = value;
                      });
                    },
                  ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: loading ? null : save,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}