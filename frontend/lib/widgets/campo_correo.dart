import 'package:flutter/material.dart';

/// Campo de texto para correo electrónico con validación básica
class CampoCorreo extends StatelessWidget {
  final TextEditingController controller;

  const CampoCorreo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'alba@scango.com',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Introduce o teu email';
        if (!value.contains('@')) return 'Email non válido';
        return null;
      },
    );
  }
}
