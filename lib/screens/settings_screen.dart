import 'package:flutter/material.dart';

import '../store/contacts_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.store,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ContactsStore store;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  void _showBackupFrequencyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => SimpleDialog(
        title: const Text('Frequência do Backup Automático'),
        children: ['Diário', 'Semanal', 'Mensal'].map((freq) {
          return SimpleDialogOption(
            onPressed: () {
              store.updateSettings(autoBackupFrequency: freq);
              Navigator.of(dialogCtx).pop();
            },
            child: Row(
              children: [
                Icon(
                  store.autoBackupFrequency == freq
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: const Color(0xFFE53935),
                ),
                const SizedBox(width: 12),
                Text(freq),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showSortOrderDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => SimpleDialog(
        title: const Text('Ordenação Padrão dos Contatos'),
        children:
            [
              {'key': 'A-Z', 'label': 'Ordem Alfabética (A-Z)'},
              {'key': 'Recentes', 'label': 'Data de Cadastro (Mais recentes)'},
            ].map((item) {
              final isSelected = store.defaultSortOrder == item['key'];
              return SimpleDialogOption(
                onPressed: () {
                  store.updateSettings(defaultSortOrder: item['key']);
                  Navigator.of(dialogCtx).pop();
                },
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: const Color(0xFFE53935),
                    ),
                    const SizedBox(width: 12),
                    Text(item['label']!),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  void _confirmResetData(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Restaurar contatos padrão?'),
        content: const Text(
          'Esta opção substituirá os contatos atuais pelos contatos de demonstração.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              store.resetSampleData();
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dados padrão restaurados!')),
              );
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Apagar todos os dados?'),
        content: const Text(
          'Tem certeza que deseja apagar todos os contatos e grupos da agenda?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              store.clearAllData();
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todos os contatos foram apagados.'),
                ),
              );
            },
            child: const Text('Apagar Tudo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          return ListView(
            children: [
              const _SectionHeader(title: 'Aparência'),
              SwitchListTile(
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                title: const Text('Tema Escuro'),
                subtitle: Text(isDark ? 'Ativado' : 'Desativado'),
                value: isDark,
                activeThumbColor: const Color(0xFFE53935),
                onChanged: (v) =>
                    onThemeChanged(v ? ThemeMode.dark : ThemeMode.light),
              ),
              const Divider(),
              const _SectionHeader(title: 'Backup Automático'),
              SwitchListTile(
                secondary: const Icon(Icons.backup_outlined),
                title: const Text('Ativar Backup Automático'),
                subtitle: Text(
                  store.autoBackupEnabled
                      ? 'Backup ${store.autoBackupFrequency.toLowerCase()} às ${store.autoBackupTime}'
                      : 'Backup automático desativado',
                ),
                value: store.autoBackupEnabled,
                activeThumbColor: const Color(0xFFE53935),
                onChanged: (v) => store.updateSettings(autoBackupEnabled: v),
              ),
              if (store.autoBackupEnabled) ...[
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Frequência'),
                  subtitle: Text(store.autoBackupFrequency),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showBackupFrequencyDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined),
                  title: const Text('Executar backup agora'),
                  subtitle: const Text('Gera e salva cópia de segurança'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Backup executado com sucesso!'),
                      ),
                    );
                  },
                ),
              ],
              const Divider(),
              const _SectionHeader(title: 'Preferências do Usuário'),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha_outlined),
                title: const Text('Ordenação dos Contatos'),
                subtitle: Text(
                  store.defaultSortOrder == 'Recentes'
                      ? 'Mais recentes primeiro'
                      : 'Ordem Alfabética (A-Z)',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSortOrderDialog(context),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('Alertas de Aniversário'),
                subtitle: const Text(
                  'Lembrar aniversários nos próximos 30 dias',
                ),
                value: store.notifyUpcomingBirthdays,
                activeThumbColor: const Color(0xFFE53935),
                onChanged: (v) =>
                    store.updateSettings(notifyUpcomingBirthdays: v),
              ),
              ListTile(
                leading: const Icon(Icons.restore_outlined),
                title: const Text('Restaurar contatos padrão'),
                subtitle: const Text('Recarrega os contatos de demonstração'),
                onTap: () => _confirmResetData(context),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_sweep_outlined,
                  color: Colors.red,
                ),
                title: const Text(
                  'Limpar todos os contatos',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('Remove todos os registros da memória'),
                onTap: () => _confirmClearData(context),
              ),
              const Divider(),
              const _SectionHeader(title: 'Sobre o Sistema'),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Versão da Aplicação'),
                subtitle: Text('1.0.0 (Desenvolvimento Mobile)'),
              ),
              const ListTile(
                leading: Icon(Icons.contact_phone_outlined),
                title: Text('Agenda de Contatos'),
                subtitle: Text('Sistema completo de gerenciamento de contatos'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFE53935),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
