import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../store/contacts_store.dart';
import '../widgets/contact_avatar.dart';

class AddEditContactScreen extends StatefulWidget {
  const AddEditContactScreen({super.key, required this.store, this.contact});

  final ContactsStore store;
  final Contact? contact;

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _notes;
  late final TextEditingController _city;
  late final TextEditingController _company;
  late List<String> _selectedCategories;
  DateTime? _birthday;
  int? _avatarColorValue;
  String? _avatarIconName;

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _name = TextEditingController(text: c?.name ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _notes = TextEditingController(text: c?.notes ?? '');
    _city = TextEditingController(text: c?.city ?? '');
    _company = TextEditingController(text: c?.company ?? '');
    _selectedCategories = c != null
        ? List<String>.from(c.categories)
        : <String>['Outros'];
    _birthday = c?.birthday;
    _avatarColorValue = c?.avatarColorValue ?? 0xFFE53935;
    _avatarIconName = c?.avatarIconName ?? 'person';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _notes.dispose();
    _city.dispose();
    _company.dispose();
    super.dispose();
  }

  void _openAvatarPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personalizar Foto / Avatar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Escolha o ícone:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      ...ContactAvatar.availableIcons.entries.map((entry) {
                        final isSelected = _avatarIconName == entry.key;
                        return InkWell(
                          onTap: () {
                            setModalState(() => _avatarIconName = entry.key);
                            setState(() => _avatarIconName = entry.key);
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: CircleAvatar(
                            backgroundColor: isSelected
                                ? Color(_avatarColorValue ?? 0xFFE53935)
                                : Colors.grey.shade200,
                            foregroundColor: isSelected
                                ? Colors.white
                                : Colors.black87,
                            child: Icon(entry.value),
                          ),
                        );
                      }),
                      InkWell(
                        onTap: () {
                          setModalState(() => _avatarIconName = null);
                          setState(() => _avatarIconName = null);
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: CircleAvatar(
                          backgroundColor: _avatarIconName == null
                              ? Color(_avatarColorValue ?? 0xFFE53935)
                              : Colors.grey.shade200,
                          foregroundColor: _avatarIconName == null
                              ? Colors.white
                              : Colors.black87,
                          child: const Text('A-Z'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Escolha a cor de fundo:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ContactAvatar.availableColors.map((colorVal) {
                      final isSelected = _avatarColorValue == colorVal;
                      return InkWell(
                        onTap: () {
                          setModalState(() => _avatarColorValue = colorVal);
                          setState(() => _avatarColorValue = colorVal);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(colorVal),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                      ),
                      child: const Text('Concluir'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthday = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cats = _selectedCategories.isEmpty ? ['Outros'] : _selectedCategories;

    if (_isEditing) {
      widget.store.update(
        widget.contact!.copyWith(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          notes: _notes.text.trim(),
          city: _city.text.trim(),
          company: _company.text.trim(),
          categories: cats,
          birthday: _birthday,
          avatarColorValue: _avatarColorValue,
          avatarIconName: _avatarIconName,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contato atualizado com sucesso!')),
      );
    } else {
      widget.store.add(
        Contact(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          notes: _notes.text.trim(),
          city: _city.text.trim(),
          company: _company.text.trim(),
          categories: cats,
          birthday: _birthday,
          avatarColorValue: _avatarColorValue,
          avatarIconName: _avatarIconName,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contato salvo com sucesso!')),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final previewContact = Contact(
      name: _name.text.isNotEmpty ? _name.text : '?',
      avatarColorValue: _avatarColorValue,
      avatarIconName: _avatarIconName,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Contato' : 'Novo Contato'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _cancel,
        ),
        actions: [
          TextButton(
            onPressed: _cancel,
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          IconButton(
            tooltip: 'Salvar',
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ContactAvatar(
                    contact: previewContact,
                    radius: 54,
                    fontSize: 48,
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFE53935),
                      child: IconButton(
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _openAvatarPicker,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _openAvatarPicker,
                icon: const Icon(Icons.photo_outlined, size: 18),
                label: const Text('Atualizar Foto / Avatar'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nome é obrigatório'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categorias (selecione uma ou mais):',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.store.categories.map((cat) {
                  final isSelected = _selectedCategories.contains(cat);
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(
                      0xFFE53935,
                    ).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFFE53935),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(cat);
                        } else {
                          _selectedCategories.remove(cat);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _city,
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _company,
                      decoration: const InputDecoration(
                        labelText: 'Empresa',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.cake_outlined,
                  color: Color(0xFFE53935),
                ),
                title: Text(
                  _birthday == null
                      ? 'Data de nascimento (opcional)'
                      : 'Aniversário: ${_birthday!.day}/${_birthday!.month}/${_birthday!.year}',
                ),
                trailing: _birthday != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _birthday = null),
                      )
                    : const Icon(Icons.calendar_today_outlined, size: 20),
                onTap: _pickBirthday,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(_isEditing ? 'Salvar' : 'Cadastrar'),
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        tooltip: 'Salvar Contato',
        child: const Icon(Icons.save),
      ),
    );
  }
}
