import 'package:flutter/material.dart';

import '../store/contacts_store.dart';
import '../widgets/contact_avatar.dart';
import 'contact_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.store});

  final ContactsStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contatos Favoritos')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final favorites = store.favorites;
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 72,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum contato favorito ainda.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toque no ícone de estrela de um contato para favoritá-lo.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, i) {
              final c = favorites[i];
              return ListTile(
                leading: ContactAvatar(contact: c, radius: 22),
                title: Text(
                  c.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(c.phone.isNotEmpty ? c.phone : c.email),
                trailing: IconButton(
                  icon: const Icon(Icons.star, color: Colors.amber),
                  tooltip: 'Remover dos favoritos',
                  onPressed: () => store.toggleFavorite(c.id),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ContactDetailScreen(contactId: c.id, store: store),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
