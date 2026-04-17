import 'package:flutter/material.dart';
import 'pantalla_escaner.dart';
import 'pantalla_carrito.dart';

/// Widget principal que xestiona a navegación entre pantallas
class PantallaPrincipal extends StatefulWidget {
  final int usuarioId;
  final String nomeUsuario;

  const PantallaPrincipal({
    super.key,
    required this.usuarioId,
    required this.nomeUsuario,
  });

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

/// Estado da pantalla principal
/// Xestiona:
/// - Índice actual (que pantalla se mostra)
/// - Lista de pantallas
/// - Navegación entre elas
class _PantallaPrincipalState extends State<PantallaPrincipal> {
  /// Índice que controla que pantalla está visible
  /// 0 = Inicio, 1 = Escanear, 2 = Carrito, 3 = Perfil
  int _indiceActual = 0;

  /// Lista que almacena todas as pantallas
  late List<Widget> _pantallas;

  /// Inicializa a lista de pantallas
  @override
  void initState() {
    super.initState();
    _pantallas = [
      _construirPantallaInicio(),    
      const PantallaEscaner(),        
      PantallaCarrito(usuarioId: widget.usuarioId),
      _construirPantallaPeril(),      
    ];
  }

  /// Constrúe a pantalla de inicio, cunha bolsa como icono e unha mensaxe de benvida
  Widget _construirPantallaInicio() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScanGo'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de bolsa de compra
            Icon(Icons.shopping_bag, size: 80, color: Colors.blue[600]),
            const SizedBox(height: 20),
            // Título de benvida
            const Text(
              'Benvido a ScanGo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Imos empezar a escanear produtos para empezar a comprar',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// construimos a pantalla de perfil,mostra un icono de usuario, o título "Perfil de usuario" e a identificación do usuario
  Widget _construirPantallaPeril() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de usuario
            Icon(Icons.person, size: 80, color: Colors.blue[600]),
            const SizedBox(height: 20),
            // Título
            const Text(
              'Perfil de usuario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Identificación do usuario
            const Text(
              'Usuario Alba',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrúe a interfaz principal con:
  /// - Pantalla actual (cambia segundo _indiceActual)
  /// - Bottom Navigation Bar con 4 opcions
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mostra a pantalla corresponde ao índice actual
      body: _pantallas[_indiceActual],
      
      // Barra de navegación inferior con 4 botones
      bottomNavigationBar: BottomNavigationBar(
        // Marca cual botón está seleccionado
        currentIndex: _indiceActual,
        // Ao premer un botón, cambia o índice
        onTap: (indice) {
          setState(() {
            _indiceActual = indice;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,  // Color do botón seleccionado
        unselectedItemColor: Colors.grey, // Color dos outros botóns
        items: const [
          // Botón 0: Inicio
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          // Botón 1: Escanear
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_3x3),
            label: 'Escanear',
          ),
          // Botón 2: Carrito
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          // Botón 3: Perfil
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
