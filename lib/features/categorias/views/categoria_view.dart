import 'package:flutter/material.dart';

class Categoria {
  final int id;
  final String name;
  final int produtos;
  final List<Categoria> children;

  Categoria({
    required this.id,
    required this.name,
    required this.produtos,
    this.children = const [],
  });
}

class CategoriaView extends StatelessWidget {
  CategoriaView({super.key});

  final List<Categoria> categorias = [
    Categoria(
      id: 1,
      name: 'Eletrônicos',
      produtos: 12,

      children: [
        Categoria(id: 2, name: 'Celulares', produtos: 5),

        Categoria(id: 3, name: 'Notebooks', produtos: 7),
      ],
    ),

    Categoria(id: 4, name: 'Roupas', produtos: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categorias.length,

        itemBuilder: (context, index) {
          final categoria = categorias[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),

              border: Border.all(color: Colors.grey.shade200),
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
                    PopupMenuButton(
                      itemBuilder:
                          (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Editar')),

                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Excluir'),
                            ),
                          ],
                    ),

                    Icon(Icons.keyboard_arrow_down_rounded),
                  ],
                ),

                leading: Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Icon(Icons.folder_outlined, color: Colors.blue),
                ),

                title: Text(
                  categoria.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                subtitle: Text(
                  categoria.produtos > 0
                      ? '${categoria.produtos} produtos'
                      : 'Sem produtos',
                ),

                children: [
                  ...categoria.children.map(
                    (sub) => Container(
                      margin: const EdgeInsets.only(top: 10),

                      padding: const EdgeInsets.all(14),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),

                        border: Border.all(color: Colors.grey.shade200),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            Icons.subdirectory_arrow_right_rounded,
                            color: Colors.grey.shade600,
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

                                Text(
                                  '${sub.produtos} produtos',

                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          PopupMenuButton(
                            itemBuilder:
                                (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Editar'),
                                  ),

                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Excluir'),
                                  ),
                                ],
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
