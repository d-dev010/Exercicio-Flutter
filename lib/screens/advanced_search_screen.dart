import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../store/contacts_store.dart';
import '../widgets/contact_avatar.dart';
import 'contact_detail_screen.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key, required this.store});

  final ContactsStore store;

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final _queryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  String _category = '';
  DateTime? _createdAfter;
  bool _searched = false;

  @override
  void dispose() {
    _queryCtrl.dispose();
    _cityCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _queryCtrl.clear();
      _cityCtrl.clear();
      _companyCtrl.clear();
      _category = '';
      _createdAfter = null;
      _searched = false;
    });
  }

  Future<void> _pickCreatedAfterDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _createdAfter ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _createdAfter = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _searched
        ? widget.store.advancedSearch(
            query: _queryCtrl.text,
            category: _category,
            city: _cityCtrl.text,
            company: _companyCtrl.text,
            createdAfter: _createdAfter,
          )
        : <Contact>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisa Avançada'),
        actions: [
          if (_searched)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Limpar filtros',
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _queryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome, email ou telefone',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category.isEmpty ? null : _category,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por Categoria',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  hint: const Text('Todas as categorias'),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Todas')),
                    ...widget.store.categories.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? ''),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Cidade',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _companyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Empresa',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFFE53935),
                  ),
                  title: Text(
                    _createdAfter == null
                        ? 'Data de cadastro (a partir de)'
                        : 'Cadastrado a partir de: ${_createdAfter!.day.toString().padLeft(2, '0')}/${_createdAfter!.month.toString().padLeft(2, '0')}/${_createdAfter!.year}',
                  ),
                  trailing: _createdAfter != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _createdAfter = null),
                        )
                      : const Icon(Icons.calendar_today_outlined, size: 20),
                  onTap: _pickCreatedAfterDate,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearFilters,
                        child: const Text('Limpar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar'),
                        onPressed: () => setState(() => _searched = true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: !_searched
                ? const Center(
                    child: Text(
                      'Preencha os filtros acima e clique em "Buscar"',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : results.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum contato encontrado com estes critérios.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final c = results[i];
                      return ListTile(
                        leading: ContactAvatar(contact: c, radius: 20),
                        title: Text(c.name),
                        subtitle: Text(
                          [
                            if (c.city.isNotEmpty) c.city,
                            if (c.company.isNotEmpty) c.company,
                            if (c.categories.isNotEmpty)
                              c.categories.join(', '),
                          ].join(' • '),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ContactDetailScreen(
                              contactId: c.id,
                              store: widget.store,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
