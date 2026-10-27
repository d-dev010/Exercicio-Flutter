import 'package:flutter/material.dart';

import '../models/contact.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    super.key,
    required this.contact,
    this.radius = 24,
    this.fontSize,
  });

  final Contact contact;
  final double radius;
  final double? fontSize;

  static const Map<String, IconData> availableIcons = {
    'person': Icons.person,
    'face': Icons.face,
    'work': Icons.work,
    'school': Icons.school,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'sports': Icons.sports_soccer,
  };

  static const List<int> availableColors = [
    0xFFE53935, // Vermelho
    0xFF1E88E5, // Azul
    0xFF43A047, // Verde
    0xFF8E24AA, // Roxo
    0xFFFB8C00, // Laranja
    0xFF00897B, // Teal
    0xFF3949AB, // Índigo
    0xFF546E7A, // Cinza
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(contact.avatarColorValue ?? 0xFFE53935);
    final iconData = availableIcons[contact.avatarIconName];

    if (iconData != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Icon(iconData, size: radius * 1.1, color: Colors.white),
      );
    }

    final initial = contact.name.trim().isNotEmpty
        ? contact.name.trim()[0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: fontSize ?? (radius * 0.9),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
