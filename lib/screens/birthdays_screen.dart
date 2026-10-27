import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../store/contacts_store.dart';
import '../widgets/contact_avatar.dart';
import 'contact_detail_screen.dart';

class BirthdaysScreen extends StatelessWidget {
  const BirthdaysScreen({super.key, required this.store});

  final ContactsStore store;

  void _generateUpcomingReminders(BuildContext context) {
    final upcoming = store.upcomingBirthdays;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.alarm_on, color: Color(0xFFE53935)),
            SizedBox(width: 8),
            Text('Lembretes Gerados'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: upcoming.isEmpty
              ? const Text(
                  'Não há aniversários cadastrados para os próximos 30 dias.',
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Foram identificados ${upcoming.length} aniversariante(s) nos próximos 30 dias:',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: upcoming.length,
                        itemBuilder: (ctx, i) {
                          final c = upcoming[i];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: ContactAvatar(contact: c, radius: 16),
                            title: Text(c.name),
                            subtitle: Text(
                              'Dia ${c.birthday!.day.toString().padLeft(2, '0')}/${c.birthday!.month.toString().padLeft(2, '0')}',
                            ),
                            trailing: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Lembretes de aniversário ativados com sucesso!',
                  ),
                ),
              );
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _setSingleReminder(BuildContext context, Contact contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Lembrete programado para o aniversário de ${contact.name}!',
        ),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aniversários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add_outlined),
            tooltip: 'Gerar Lembretes',
            onPressed: () => _generateUpcomingReminders(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final birthdays = store.birthdays;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFE53935).withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.cake, color: Color(0xFFE53935), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aniversariantes de ${months[now.month - 1]}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFE53935),
                            ),
                          ),
                          Text(
                            '${birthdays.length} aniversariante(s) neste mês',
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () => _generateUpcomingReminders(context),
                      icon: const Icon(Icons.notifications_active, size: 16),
                      label: const Text('Lembretes'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: birthdays.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cake_outlined,
                              size: 72,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Nenhum aniversariante este mês.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: birthdays.length,
                        itemBuilder: (context, i) {
                          final c = birthdays[i];
                          final bdayThisYear = DateTime(
                            now.year,
                            c.birthday!.month,
                            c.birthday!.day,
                          );
                          final diff = bdayThisYear
                              .difference(
                                DateTime(now.year, now.month, now.day),
                              )
                              .inDays;

                          final isToday = diff == 0;
                          final isPassed = diff < 0;

                          return ListTile(
                            leading: ContactAvatar(contact: c, radius: 22),
                            title: Text(
                              c.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Dia ${c.birthday!.day.toString().padLeft(2, '0')} de ${months[c.birthday!.month - 1]}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isToday)
                                  const Chip(
                                    label: Text('Hoje! 🎉'),
                                    backgroundColor: Colors.amber,
                                  )
                                else if (isPassed)
                                  Text(
                                    'Passou há ${-diff}d',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  )
                                else
                                  Text(
                                    'Em $diff dia(s)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFE53935),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.notification_add_outlined,
                                  ),
                                  tooltip: 'Criar Lembrete',
                                  onPressed: () =>
                                      _setSingleReminder(context, c),
                                ),
                              ],
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
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
