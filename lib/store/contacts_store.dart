import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../models/contact_group.dart';

class ContactsStore extends ChangeNotifier {
  ContactsStore() {
    _loadSampleData();
  }

  final List<Contact> _contacts = [];
  final List<ContactGroup> _groups = [];
  final List<String> _categories = [
    'Família',
    'Amigos',
    'Trabalho',
    'Clientes',
    'Outros',
  ];

  bool autoBackupEnabled = false;
  String autoBackupFrequency = 'Semanal';
  String autoBackupTime = '02:00';
  String defaultSortOrder = 'A-Z';
  bool notifyUpcomingBirthdays = true;

  List<Contact> get all {
    final copy = List<Contact>.from(_contacts);
    if (defaultSortOrder == 'Recentes') {
      copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      copy.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return copy;
  }

  List<ContactGroup> get groups => List.unmodifiable(_groups);

  List<String> get categories => List.unmodifiable(_categories);

  void addCategory(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty && !_categories.contains(trimmed)) {
      _categories.add(trimmed);
      notifyListeners();
    }
  }

  void deleteCategory(String name) {
    if (name != 'Outros') {
      _categories.remove(name);
      for (final contact in _contacts) {
        contact.categories.remove(name);
        if (contact.categories.isEmpty) {
          contact.categories.add('Outros');
        }
      }
      notifyListeners();
    }
  }

  ContactGroup? getGroupById(String id) {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Contact> getGroupMembers(String groupId) {
    final group = getGroupById(groupId);
    if (group == null) {
      return [];
    }
    return _contacts.where((c) => group.contactIds.contains(c.id)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<Contact> get favorites =>
      _contacts.where((c) => c.isFavorite).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  List<Contact> get birthdays {
    final now = DateTime.now();
    return _contacts
        .where((c) => c.birthday != null && c.birthday!.month == now.month)
        .toList()
      ..sort((a, b) => a.birthday!.day.compareTo(b.birthday!.day));
  }

  List<Contact> get upcomingBirthdays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _contacts.where((c) {
      if (c.birthday == null) return false;
      var nextBday = DateTime(today.year, c.birthday!.month, c.birthday!.day);
      if (nextBday.isBefore(today)) {
        nextBday = DateTime(today.year + 1, c.birthday!.month, c.birthday!.day);
      }
      final diff = nextBday.difference(today).inDays;
      return diff >= 0 && diff <= 30;
    }).toList()..sort((a, b) {
      var b1 = DateTime(today.year, a.birthday!.month, a.birthday!.day);
      if (b1.isBefore(today)) {
        b1 = DateTime(today.year + 1, a.birthday!.month, a.birthday!.day);
      }
      var b2 = DateTime(today.year, b.birthday!.month, b.birthday!.day);
      if (b2.isBefore(today)) {
        b2 = DateTime(today.year + 1, b.birthday!.month, b.birthday!.day);
      }
      return b1.compareTo(b2);
    });
  }

  List<Contact> byCategory(String category) =>
      _contacts.where((c) => c.categories.contains(category)).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  List<Contact> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return _contacts.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            c.phone.replaceAll(RegExp(r'[^0-9]'), '').contains(q) ||
            c.phone.toLowerCase().contains(q);
      }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<Contact> advancedSearch({
    String? query,
    String? category,
    String? city,
    String? company,
    DateTime? createdAfter,
  }) {
    return _contacts.where((c) {
        if (query != null && query.trim().isNotEmpty) {
          final q = query.trim().toLowerCase();
          if (!c.name.toLowerCase().contains(q) &&
              !c.email.toLowerCase().contains(q) &&
              !c.phone.contains(q)) {
            return false;
          }
        }
        if (category != null &&
            category.isNotEmpty &&
            !c.categories.contains(category)) {
          return false;
        }
        if (city != null &&
            city.trim().isNotEmpty &&
            !c.city.toLowerCase().contains(city.trim().toLowerCase())) {
          return false;
        }
        if (company != null &&
            company.trim().isNotEmpty &&
            !c.company.toLowerCase().contains(company.trim().toLowerCase())) {
          return false;
        }
        if (createdAfter != null) {
          final zeroTimeContact = DateTime(
            c.createdAt.year,
            c.createdAt.month,
            c.createdAt.day,
          );
          final zeroTimeFilter = DateTime(
            createdAfter.year,
            createdAfter.month,
            createdAfter.day,
          );
          if (zeroTimeContact.isBefore(zeroTimeFilter)) {
            return false;
          }
        }
        return true;
      }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  void add(Contact contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  void update(Contact updated) {
    final index = _contacts.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _contacts[index] = updated;
      notifyListeners();
    }
  }

  void delete(String id) {
    _contacts.removeWhere((c) => c.id == id);
    for (final group in _groups) {
      group.contactIds.remove(id);
    }
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _contacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      _contacts[index].isFavorite = !_contacts[index].isFavorite;
      notifyListeners();
    }
  }

  void addGroup(ContactGroup group) {
    _groups.add(group);
    notifyListeners();
  }

  void updateGroup(ContactGroup group) {
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
      notifyListeners();
    }
  }

  void deleteGroup(String id) {
    _groups.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  void addContactToGroup(String groupId, String contactId) {
    final group = getGroupById(groupId);
    if (group != null && !group.contactIds.contains(contactId)) {
      group.contactIds.add(contactId);
      notifyListeners();
    }
  }

  void removeContactFromGroup(String groupId, String contactId) {
    final group = getGroupById(groupId);
    if (group != null) {
      group.contactIds.remove(contactId);
      notifyListeners();
    }
  }

  void updateSettings({
    bool? autoBackupEnabled,
    String? autoBackupFrequency,
    String? autoBackupTime,
    String? defaultSortOrder,
    bool? notifyUpcomingBirthdays,
  }) {
    if (autoBackupEnabled != null) {
      this.autoBackupEnabled = autoBackupEnabled;
    }
    if (autoBackupFrequency != null) {
      this.autoBackupFrequency = autoBackupFrequency;
    }
    if (autoBackupTime != null) {
      this.autoBackupTime = autoBackupTime;
    }
    if (defaultSortOrder != null) {
      this.defaultSortOrder = defaultSortOrder;
    }
    if (notifyUpcomingBirthdays != null) {
      this.notifyUpcomingBirthdays = notifyUpcomingBirthdays;
    }
    notifyListeners();
  }

  String exportToCsv() {
    final buffer = StringBuffer();
    buffer.writeln(
      'Nome,Telefone,Email,Categorias,Cidade,Empresa,Aniversario,Observacoes',
    );
    for (final c in _contacts) {
      final birthdayStr = c.birthday != null
          ? '${c.birthday!.year}-${c.birthday!.month.toString().padLeft(2, '0')}-${c.birthday!.day.toString().padLeft(2, '0')}'
          : '';
      final categoriesStr = c.categories.join(';');
      final cleanNotes = c.notes.replaceAll('\n', ' ').replaceAll(',', ';');
      buffer.writeln(
        '"${c.name}","${c.phone}","${c.email}","$categoriesStr","${c.city}","${c.company}","$birthdayStr","$cleanNotes"',
      );
    }
    return buffer.toString();
  }

  String exportToJson() {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'contacts': _contacts.map((c) => c.toMap()).toList(),
      'groups': _groups
          .map(
            (g) => {
              'id': g.id,
              'name': g.name,
              'description': g.description,
              'contactIds': g.contactIds,
              'createdAt': g.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'categories': _categories,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  int importFromCsv(String csvContent) {
    final lines = csvContent.split('\n');
    int imported = 0;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      if (i == 0 &&
          (line.toLowerCase().contains('nome') ||
              line.toLowerCase().contains('telefone'))) {
        continue;
      }
      final parts = _parseCsvLine(line);
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        final name = parts[0];
        final phone = parts.length > 1 ? parts[1] : '';
        final email = parts.length > 2 ? parts[2] : '';
        final categoriesStr = parts.length > 3 ? parts[3] : '';
        final city = parts.length > 4 ? parts[4] : '';
        final company = parts.length > 5 ? parts[5] : '';
        final birthdayStr = parts.length > 6 ? parts[6] : '';
        final notes = parts.length > 7 ? parts[7] : '';

        DateTime? bday;
        if (birthdayStr.isNotEmpty) {
          bday = DateTime.tryParse(birthdayStr);
        }

        final cats = categoriesStr.isNotEmpty
            ? categoriesStr
                  .split(';')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList()
            : <String>['Outros'];

        for (final cat in cats) {
          if (!_categories.contains(cat)) {
            _categories.add(cat);
          }
        }

        _contacts.add(
          Contact(
            name: name,
            phone: phone,
            email: email,
            categories: cats,
            city: city,
            company: company,
            birthday: bday,
            notes: notes,
          ),
        );
        imported++;
      }
    }
    if (imported > 0) {
      notifyListeners();
    }
    return imported;
  }

  int importFromJson(String jsonContent) {
    try {
      final decoded = json.decode(jsonContent);
      if (decoded is Map<String, dynamic> && decoded['contacts'] is List) {
        int count = 0;
        final list = decoded['contacts'] as List;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final contact = Contact.fromMap(item);
            _contacts.add(contact);
            for (final cat in contact.categories) {
              if (!_categories.contains(cat)) {
                _categories.add(cat);
              }
            }
            count++;
          }
        }
        if (decoded['categories'] is List) {
          for (final cat in decoded['categories'] as List) {
            if (!_categories.contains(cat.toString())) {
              _categories.add(cat.toString());
            }
          }
        }
        if (count > 0) {
          notifyListeners();
        }
        return count;
      }
    } catch (_) {}
    return 0;
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if ((char == ',' || char == ';') && !inQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString().trim());
    return result;
  }

  void resetSampleData() {
    _contacts.clear();
    _groups.clear();
    _loadSampleData();
    notifyListeners();
  }

  void clearAllData() {
    _contacts.clear();
    _groups.clear();
    notifyListeners();
  }

  void _loadSampleData() {
    final c1 = Contact(
      id: '1',
      name: 'Ana Silva',
      email: 'ana@email.com',
      phone: '(11) 99999-0001',
      categories: ['Família'],
      city: 'São Paulo',
      birthday: DateTime(1990, 10, 15),
      isFavorite: true,
      notes: 'Irmã mais nova',
      avatarColorValue: 0xFFE53935,
      avatarIconName: 'person',
    );
    final c2 = Contact(
      id: '2',
      name: 'Bruno Santos',
      email: 'bruno@email.com',
      phone: '(21) 98888-0002',
      categories: ['Amigos'],
      city: 'Rio de Janeiro',
      company: 'TechCorp',
      birthday: DateTime(1988, 3, 22),
      notes: 'Amigo de faculdade',
      avatarColorValue: 0xFF1E88E5,
      avatarIconName: 'face',
    );
    final c3 = Contact(
      id: '3',
      name: 'Carlos Mendes',
      email: 'carlos@empresa.com',
      phone: '(31) 97777-0003',
      categories: ['Trabalho'],
      city: 'Belo Horizonte',
      company: 'Inova Ltda',
      isFavorite: true,
      notes: 'Gerente de projetos',
      avatarColorValue: 0xFF43A047,
      avatarIconName: 'work',
    );
    final c4 = Contact(
      id: '4',
      name: 'Diana Costa',
      email: 'diana@cliente.com',
      phone: '(41) 96666-0004',
      categories: ['Clientes', 'Trabalho'],
      city: 'Curitiba',
      company: 'Mega S.A.',
      birthday: DateTime(1995, 10, 5),
      notes: 'Contrato anual',
      avatarColorValue: 0xFF8E24AA,
      avatarIconName: 'school',
    );
    final c5 = Contact(
      id: '5',
      name: 'Eduardo Lima',
      email: 'eduardo@email.com',
      phone: '(51) 95555-0005',
      categories: ['Amigos'],
      city: 'Porto Alegre',
      birthday: DateTime(1992, 7, 18),
      isFavorite: true,
      notes: 'Colega de basquete',
      avatarColorValue: 0xFFFB8C00,
      avatarIconName: 'star',
    );
    _contacts.addAll([c1, c2, c3, c4, c5]);

    _groups.addAll([
      ContactGroup(
        id: 'g1',
        name: 'Futebol de Quarta',
        description: 'Galera do futebol semanal',
        contactIds: ['2', '5'],
      ),
      ContactGroup(
        id: 'g2',
        name: 'Projeto Alpha',
        description: 'Equipe de desenvolvimento do app',
        contactIds: ['3', '4'],
      ),
    ]);
  }
}
