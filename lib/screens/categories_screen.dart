import 'package:flutter/material.dart';

import '../store/contacts_store.dart';
import '../widgets/contact_avatar.dart';
import 'contact_detail_screen.dart';

const Map<String, IconData> _categoryIcons = {
  'Família': Icons.home_outlined,
  'Amigos': Icons.people_outline,
  'Trabalho': Icons.work_outline,
  'Clientes': Icons.handshake_outlined,
  'Outros': Icons.label_outline,
};

const Map<String, Color> _categoryColors = {
  'Família': Color(0xFF4CAF50),
  'Amigos': Color(0xFF2196F3),
  'Trabalho': Color(0xFFFF9800),
  'Clientes': Color(0xFF9C27B0),
  'Outros': Color(0xFF607D8B),
};

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key, required this.store});

  final ContactsStore store;

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Nova Categoria'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome da Categoria',
            hintText: 'Ex: Faculdade, Médicos, etc.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                store.addCategory(name);
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Categoria "$name" criada!')),
                );
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, String categoryName) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Excluir "$categoryName"?'),
        content: const Text(
          'Os contatos vinculados a esta categoria continuarão na sua agenda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              store.deleteCategory(categoryName);
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Categoria "$categoryName" removida.')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nova Categoria',
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final categories = store.categories;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final contacts = store.byCategory(cat);
              final icon = _categoryIcons[cat] ?? Icons.label_outline;
              final color = _categoryColors[cat] ?? const Color(0xFF00897B);
              final isDefault = [
                'Família',
                'Amigos',
                'Trabalho',
                'Clientes',
                'Outros',
              ].contains(cat);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(
                    cat,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${contacts.length} contato(s)'),
                  trailing: isDefault
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          tooltip: 'Excluir categoria',
                          onPressed: () => _confirmDeleteCategory(context, cat),
                        ),
                  children: contacts.isEmpty
                      ? const [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Nenhum contato nesta categoria.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ]
                      : contacts.map((c) {
                          return ListTile(
                            leading: ContactAvatar(contact: c, radius: 18),
                            title: Text(c.name),
                            subtitle: Text(
                              c.phone.isNotEmpty ? c.phone : c.email,
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ContactDetailScreen(
                                  contactId: c.id,
                                  store: store,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        tooltip: 'Criar Categoria',
        child: const Icon(Icons.add),
      ),
    );
  }
}
