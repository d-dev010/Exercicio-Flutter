class Contact {
  Contact({
    String? id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.notes = '',
    this.isFavorite = false,
    List<String>? categories,
    String? category,
    this.birthday,
    this.city = '',
    this.company = '',
    this.avatarColorValue,
    this.avatarIconName,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       categories =
           categories ??
           (category != null && category.isNotEmpty ? [category] : ['Outros']),
       createdAt = createdAt ?? DateTime.now();

  final String id;
  String name;
  String email;
  String phone;
  String notes;
  bool isFavorite;
  List<String> categories;
  DateTime? birthday;
  String city;
  String company;
  int? avatarColorValue;
  String? avatarIconName;
  final DateTime createdAt;

  String get category => categories.isNotEmpty ? categories.first : 'Outros';

  Contact copyWith({
    String? name,
    String? email,
    String? phone,
    String? notes,
    bool? isFavorite,
    List<String>? categories,
    String? category,
    DateTime? birthday,
    String? city,
    String? company,
    int? avatarColorValue,
    String? avatarIconName,
  }) {
    return Contact(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      categories:
          categories ??
          (category != null ? [category] : List<String>.from(this.categories)),
      birthday: birthday ?? this.birthday,
      city: city ?? this.city,
      company: company ?? this.company,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      avatarIconName: avatarIconName ?? this.avatarIconName,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'notes': notes,
      'isFavorite': isFavorite,
      'categories': categories,
      'birthday': birthday?.toIso8601String(),
      'city': city,
      'company': company,
      'avatarColorValue': avatarColorValue,
      'avatarIconName': avatarIconName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    List<String> cats = [];
    if (map['categories'] is List) {
      cats = (map['categories'] as List).map((e) => e.toString()).toList();
    } else if (map['category'] != null) {
      cats = [map['category'].toString()];
    }
    if (cats.isEmpty) {
      cats = ['Outros'];
    }

    return Contact(
      id: map['id']?.toString(),
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      isFavorite: map['isFavorite'] == true,
      categories: cats,
      birthday: map['birthday'] != null
          ? DateTime.tryParse(map['birthday'].toString())
          : null,
      city: map['city']?.toString() ?? '',
      company: map['company']?.toString() ?? '',
      avatarColorValue: map['avatarColorValue'] is int
          ? map['avatarColorValue'] as int
          : null,
      avatarIconName: map['avatarIconName']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }
}
