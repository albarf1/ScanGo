import 'package:flutter/material.dart';

/// Campo de texto para o nome completo do usuario con validación básica
class CampoNome extends StatelessWidget {
  final TextEditingController controller;

  const CampoNome({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelText: 'Nome completo',
        hintText: 'Alba Rodríguez',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Introduce o teu nome';
        if (value.length < 2) return 'O nome debe ter polo menos 2 caracteres';
        return null;
      },
    );
  }
}
