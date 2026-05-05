import 'package:flutter/material.dart';

/// Card para seleccionar un método de pago na pantalla de pago
class TarxetaMetodoPago extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final bool seleccionado;
  final VoidCallback onTap;

  const TarxetaMetodoPago({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado ? Colors.blue : Colors.grey.shade300,
            width: seleccionado ? 2 : 1,
          ),
          color: seleccionado ? Colors.blue.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icono, color: seleccionado ? Colors.blue : Colors.grey),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Icon(
              seleccionado ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: seleccionado ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
