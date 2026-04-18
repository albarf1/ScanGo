import 'package:flutter/material.dart';

/// Cabeceira común con logo QR, título e subtítulo
class LogoCabeceira extends StatelessWidget {
  final String subtitulo;

  const LogoCabeceira({super.key, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo QR
        Icon(Icons.qr_code_2, size: 80, color: Colors.blue[600]),
        const SizedBox(height: 20),
        // Título
        const Text(
          'ScanGo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 10),
        // Subtítulo 
        Text(
          subtitulo,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
