class ContactGroup {
  ContactGroup({
    String? id,
    required this.name,
    this.description = '',
    List<String>? contactIds,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       contactIds = contactIds ?? [],
       createdAt = createdAt ?? DateTime.now();

  final String id;
  String name;
  String description;
  List<String> contactIds;
  final DateTime createdAt;

  ContactGroup copyWith({
    String? name,
    String? description,
    List<String>? contactIds,
  }) {
    return ContactGroup(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      contactIds: contactIds ?? List<String>.from(this.contactIds),
      createdAt: createdAt,
    );
  }
}
