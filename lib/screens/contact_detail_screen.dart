import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../store/contacts_store.dart';
import '../widgets/contact_avatar.dart';
import 'add_edit_contact_screen.dart';

class ContactDetailScreen extends StatelessWidget {
  const ContactDetailScreen({
    super.key,
    required this.contactId,
    required this.store,
  });

  final String contactId;
  final ContactsStore store;

  void _confirmDelete(BuildContext context, Contact contact) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir contato?'),
        content: Text(
          'Deseja excluir "${contact.name}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              store.delete(contact.id);
              Navigator.of(context)
                ..pop()
                ..pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Contato excluído')));
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final contact = store.all.cast<Contact?>().firstWhere(
          (c) => c!.id == contactId,
          orElse: () => null,
        );

        if (contact == null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => Navigator.of(context).pop(),
          );
          return const SizedBox.shrink();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do Contato'),
            actions: [
              IconButton(
                icon: Icon(
                  contact.isFavorite ? Icons.star : Icons.star_border,
                  color: contact.isFavorite ? Colors.amber : Colors.white,
                ),
                tooltip: contact.isFavorite
                    ? 'Remover dos favoritos'
                    : 'Favoritar',
                onPressed: () => store.toggleFavorite(contact.id),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        AddEditContactScreen(store: store, contact: contact),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Excluir',
                onPressed: () => _confirmDelete(context, contact),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                ContactAvatar(contact: contact, radius: 56, fontSize: 50),
                const SizedBox(height: 16),
                Text(
                  contact.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: contact.categories.map((cat) {
                    return Chip(
                      label: Text(cat),
                      backgroundColor: const Color(
                        0xFFE53935,
                      ).withValues(alpha: 0.1),
                      labelStyle: const TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Divider(),
                if (contact.phone.isNotEmpty)
                  _DetailTile(
                    icon: Icons.phone_outlined,
                    label: 'Telefone',
                    value: contact.phone,
                  ),
                if (contact.email.isNotEmpty)
                  _DetailTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: contact.email,
                  ),
                if (contact.city.isNotEmpty)
                  _DetailTile(
                    icon: Icons.location_city_outlined,
                    label: 'Cidade',
                    value: contact.city,
                  ),
                if (contact.company.isNotEmpty)
                  _DetailTile(
                    icon: Icons.business_outlined,
                    label: 'Empresa',
                    value: contact.company,
                  ),
                if (contact.birthday != null)
                  _DetailTile(
                    icon: Icons.cake_outlined,
                    label: 'Aniversário',
                    value:
                        '${contact.birthday!.day.toString().padLeft(2, '0')}/${contact.birthday!.month.toString().padLeft(2, '0')}/${contact.birthday!.year}',
                  ),
                if (contact.notes.isNotEmpty)
                  _DetailTile(
                    icon: Icons.notes_outlined,
                    label: 'Observações',
                    value: contact.notes,
                  ),
                const SizedBox(height: 16),
                _DetailTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Data de Cadastro',
                  value:
                      '${contact.createdAt.day.toString().padLeft(2, '0')}/${contact.createdAt.month.toString().padLeft(2, '0')}/${contact.createdAt.year}',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Contato'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AddEditContactScreen(
                          store: store,
                          contact: contact,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'Excluir Contato',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () => _confirmDelete(context, contact),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE53935)),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
