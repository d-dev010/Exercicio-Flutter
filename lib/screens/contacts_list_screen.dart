import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../store/contacts_store.dart';
import '../widgets/contact_avatar.dart';
import 'add_edit_contact_screen.dart';
import 'contact_detail_screen.dart';

class ContactsListScreen extends StatelessWidget {
  const ContactsListScreen({super.key, required this.store});

  final ContactsStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Contatos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar contatos',
            onPressed: () => showSearch(
              context: context,
              delegate: _ContactSearchDelegate(store),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final contacts = store.all;
          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 72,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum contato cadastrado.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no botão + para adicionar um novo contato.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return _ContactListContent(contacts: contacts, store: store);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AddEditContactScreen(store: store),
          ),
        ),
        tooltip: 'Adicionar Contato',
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _ContactListContent extends StatelessWidget {
  const _ContactListContent({required this.contacts, required this.store});

  final List<Contact> contacts;
  final ContactsStore store;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Contact>>{};
    for (final c in contacts) {
      final letter = c.name.trim().isNotEmpty
          ? c.name.trim()[0].toUpperCase()
          : '#';
      grouped.putIfAbsent(letter, () => []).add(c);
    }
    final letters = grouped.keys.toList()..sort();

    final items = <Object>[];
    for (final l in letters) {
      items.add(l);
      items.addAll(grouped[l]!);
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        if (item is String) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              item,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
          );
        }

        final contact = item as Contact;
        return ListTile(
          leading: ContactAvatar(contact: contact, radius: 22),
          title: Text(
            contact.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            contact.phone.isNotEmpty
                ? contact.phone
                : (contact.email.isNotEmpty ? contact.email : 'Sem telefone'),
          ),
          trailing: IconButton(
            icon: Icon(
              contact.isFavorite ? Icons.star : Icons.star_border,
              color: contact.isFavorite ? Colors.amber : null,
            ),
            tooltip: contact.isFavorite ? 'Remover favorito' : 'Favoritar',
            onPressed: () => store.toggleFavorite(contact.id),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  ContactDetailScreen(contactId: contact.id, store: store),
            ),
          ),
        );
      },
    );
  }
}

class _ContactSearchDelegate extends SearchDelegate<void> {
  _ContactSearchDelegate(this.store);

  final ContactsStore store;

  @override
  String get searchFieldLabel => 'Buscar por nome, email ou telefone';

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final results = store.search(query);
    if (results.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum contato encontrado.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final c = results[i];
        return ListTile(
          leading: ContactAvatar(contact: c, radius: 20),
          title: Text(c.name),
          subtitle: Text(c.phone.isNotEmpty ? c.phone : c.email),
          onTap: () {
            close(context, null);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ContactDetailScreen(contactId: c.id, store: store),
              ),
            );
          },
        );
      },
    );
  }
}
