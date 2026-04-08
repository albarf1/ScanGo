import 'package:flutter/material.dart';
import 'pantallas/pantalla_principal.dart';

/// Punto de entrada da aplicación
void main() {
  runApp(const ScanGoApp());
}

/// Widget raiz da aplicación 
class ScanGoApp extends StatelessWidget {
  const ScanGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanGo',
      // Oculta a barra de debug
      debugShowCheckedModeBanner: false,
      // Tema da aplicación
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Pantalla inicial: Navegación con Bottom Navigation Bar
      home: const PantallaPrincipal(),
    );
  }
}
