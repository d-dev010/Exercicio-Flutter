import 'package:flutter/material.dart';

import 'screens/advanced_search_screen.dart';
import 'screens/birthdays_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/contacts_list_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/groups_screen.dart';
import 'screens/import_export_screen.dart';
import 'screens/settings_screen.dart';
import 'store/contacts_store.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AgendaApp());
}

class AgendaApp extends StatefulWidget {
  const AgendaApp({super.key});

  @override
  State<AgendaApp> createState() => _AgendaAppState();
}

class _AgendaAppState extends State<AgendaApp> {
  final ContactsStore _store = ContactsStore();
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Contatos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: MainScreen(
        store: _store,
        themeMode: _themeMode,
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.store,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ContactsStore store;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      ContactsListScreen(store: widget.store),
      FavoritesScreen(store: widget.store),
      CategoriesScreen(store: widget.store),
      SettingsScreen(
        store: widget.store,
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      drawer: _AppDrawer(store: widget.store),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Contatos',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.label_outline),
            selectedIcon: Icon(Icons.label),
            label: 'Categorias',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.store});

  final ContactsStore store;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFE53935)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.contact_phone, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                const Text(
                  'Agenda de Contatos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ListenableBuilder(
                  listenable: store,
                  builder: (_, _) => Text(
                    '${store.all.length} contato(s) cadastrado(s)',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('Grupos'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GroupsScreen(store: store),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cake_outlined),
            title: const Text('Aniversários'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BirthdaysScreen(store: store),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.manage_search_outlined),
            title: const Text('Pesquisa Avançada'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AdvancedSearchScreen(store: store),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync_alt_outlined),
            title: const Text('Importação e Exportação'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ImportExportScreen(store: store),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
