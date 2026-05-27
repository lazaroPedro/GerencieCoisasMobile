import 'package:flutter/material.dart';
import 'package:gerencie_coisas/features/categorias/view_model/categoria_view_model.dart';
import 'package:gerencie_coisas/features/categorias/views/create_categoria_view.dart';
import 'package:gerencie_coisas/features/categorias/views/delete_categoria_view.dart';



class CategoriaView extends StatefulWidget {
  const CategoriaView({super.key});

  @override
  State<CategoriaView> createState() => _CategoriaViewState();
}

class _CategoriaViewState extends State<CategoriaView> {

  final CategoriaViewModel viewModel = CategoriaViewModel();


  @override
  void initState() {
    super.initState();
    viewModel.loadCategorias();
    viewModel.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateCategoriaView(viewModel: viewModel),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.categorias.length,

        itemBuilder: (context, index) {
          final categoria = viewModel.categorias[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),

            decoration: BoxDecoration(
              color: ColorScheme.of(context).surface,
              borderRadius: BorderRadius.circular(18),

              
            ),

            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),

              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),

                childrenPadding: const EdgeInsets.only(
                  left: 18,
                  right: 18,
                  bottom: 18,
                ),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeleteCategoriaView(viewModel: viewModel, categoriaId: categoria.item.id),
                          ),
                        );
                        },
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: Colors.redAccent,
                    ),

                    Icon(Icons.keyboard_arrow_down_rounded),
                  ],
                ),

                leading: Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child:  Icon(Icons.folder_outlined, color: ColorScheme.of(context).primary),
                ),

                title: Text(    
                  categoria.item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),


                children: [
                  ...categoria.children.map(
                    (sub) => Container(
                      margin: const EdgeInsets.only(top: 10),

                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                      
                        borderRadius: BorderRadius.circular(14),

                        border: Border.all(color: Colors.grey.shade200),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            Icons.subdirectory_arrow_right_rounded,

                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  sub.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 4),

                              
                              ],
                            ),
                          ),

                          IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeleteCategoriaView(viewModel: viewModel, categoriaId: categoria.item.id),
                          ),
                        );
                        },
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        color: Colors.redAccent,
                      ),
                        ],
                      ),
                    ),
                  ),

                  if (categoria.children.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),

                      child: Text(
                        'Nenhuma subcategoria',

                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
