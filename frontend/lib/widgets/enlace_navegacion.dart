import 'package:flutter/material.dart';

/// Fila con texto e botón de navegación, usada no fondo dos formularios de login e rexistro
class EnlaceNavegacion extends StatelessWidget {
  final String texto;
  final String textoEnlace;
  final VoidCallback onTap;

  const EnlaceNavegacion({
    super.key,
    required this.texto,
    required this.textoEnlace,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(texto),
        TextButton(
          onPressed: onTap,
          child: Text(
            textoEnlace,
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
