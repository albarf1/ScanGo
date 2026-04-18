import 'package:flutter/material.dart';

/// Caixa de erro en rojo para mostrar mensaxes de validación ou servidor
class ContedorErro extends StatelessWidget {
  final String mensaxe;

  const ContedorErro({super.key, required this.mensaxe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          // Texto expandido para que non desborde
          Expanded(
            child: Text(
              mensaxe,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
