import 'package:flutter/material.dart';

import '../models/contact_group.dart';
import '../store/contacts_store.dart';
import '../widgets/contact_avatar.dart';
import 'contact_detail_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key, required this.store});

  final ContactsStore store;

  void _showCreateGroupDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Novo Grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome do grupo *',
                prefixIcon: Icon(Icons.group_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                store.addGroup(
                  ContactGroup(name: name, description: descCtrl.text.trim()),
                );
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Grupo "$name" criado!')),
                );
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberSheet(BuildContext context, ContactGroup group) {
    final allContacts = store.all;
    final available = allContacts
        .where((c) => !group.contactIds.contains(c.id))
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Adicionar ao grupo "${group.name}"',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (available.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Todos os contatos já estão neste grupo.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: available.length,
                    itemBuilder: (ctx, idx) {
                      final contact = available[idx];
                      return ListTile(
                        leading: ContactAvatar(contact: contact, radius: 18),
                        title: Text(contact.name),
                        subtitle: Text(
                          contact.phone.isNotEmpty
                              ? contact.phone
                              : contact.email,
                        ),
                        trailing: const Icon(Icons.person_add_alt_1_outlined),
                        onTap: () {
                          store.addContactToGroup(group.id, contact.id);
                          Navigator.of(sheetCtx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${contact.name} adicionado ao grupo!',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, ContactGroup group) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Excluir Grupo'),
        content: Text(
          'Deseja excluir o grupo "${group.name}"? Os contatos não serão apagados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            onPressed: () {
              store.deleteGroup(group.id);
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Grupo "${group.name}" excluído.')),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Criar Grupo',
            onPressed: () => _showCreateGroupDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context),
        tooltip: 'Novo Grupo',
        child: const Icon(Icons.group_add),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final groups = store.groups;

          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 72,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum grupo cadastrado',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie grupos para organizar seus contatos.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (ctx, i) {
              final group = groups[i];
              final members = store.getGroupMembers(group.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(
                      0xFFE53935,
                    ).withValues(alpha: 0.15),
                    child: const Icon(Icons.groups, color: Color(0xFFE53935)),
                  ),
                  title: Text(
                    group.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    group.description.isNotEmpty
                        ? '${group.description} • ${members.length} membro(s)'
                        : '${members.length} membro(s)',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'add') {
                        _showAddMemberSheet(context, group);
                      } else if (val == 'delete') {
                        _confirmDeleteGroup(context, group);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'add',
                        child: Row(
                          children: [
                            Icon(Icons.person_add_alt_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Adicionar membro'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Excluir grupo',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  children: [
                    if (members.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Nenhum membro neste grupo.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _showAddMemberSheet(context, group),
                              icon: const Icon(Icons.person_add_alt_1),
                              label: const Text('Adicionar Membro'),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      ...members.map(
                        (member) => ListTile(
                          leading: ContactAvatar(contact: member, radius: 18),
                          title: Text(member.name),
                          subtitle: Text(
                            member.phone.isNotEmpty
                                ? member.phone
                                : member.email,
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                            ),
                            tooltip: 'Remover do grupo',
                            onPressed: () {
                              store.removeContactFromGroup(group.id, member.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${member.name} removido do grupo.',
                                  ),
                                ),
                              );
                            },
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ContactDetailScreen(
                                contactId: member.id,
                                store: store,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () =>
                                _showAddMemberSheet(context, group),
                            icon: const Icon(Icons.person_add_alt_1, size: 18),
                            label: const Text('Adicionar membro'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
