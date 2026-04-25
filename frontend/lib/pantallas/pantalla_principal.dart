import 'package:flutter/material.dart';
import 'pantalla_escaner.dart';
import 'pantalla_carrito.dart';
import 'pantalla_login.dart';
import 'pantalla_admin.dart';

/// Widget principal que xestiona a navegación entre pantallas
class PantallaPrincipal extends StatefulWidget {
  final int usuarioId;
  final String nomeUsuario;
  final bool eAdmin;

  const PantallaPrincipal({
    super.key,
    required this.usuarioId,
    required this.nomeUsuario,
    this.eAdmin = false,
  });

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  /// Índice que controla que pantalla está visible
  int _indiceActual = 0;

  /// Lista que almacena todas as pantallas
  late List<Widget> _pantallas;

  /// Inicializa a lista de pantallas segundo o rol do usuario
  @override
  void initState() {
    super.initState();
    _pantallas = [
      _construirPantallaInicio(),
      PantallaEscaner(usuarioId: widget.usuarioId),
      PantallaCarrito(
        usuarioId: widget.usuarioId,
        nomeUsuario: widget.nomeUsuario,
        eAdmin: widget.eAdmin,
        onSeguirComprando: () => setState(() => _indiceActual = 1),
      ),
      if (widget.eAdmin) const PantallaAdmin(),
      _construirPantallaPeril(),
    ];
  }

  /// Constrúe a pantalla de inicio cunha bolsa como icono e mensaxe de benvida
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

  /// Constrúe a pantalla de perfil co nome real do usuario e botón de pechar sesión
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
            // Nome do usuario autenticado
            Text(
              widget.nomeUsuario,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            // Botón para pechar sesión
            SizedBox(
              width: 220,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Pechar sesión',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _confirmarPecharSesion,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra un diálogo de confirmación antes de pechar sesión
  void _confirmarPecharSesion() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pechar sesión'),
        content: const Text('¿Seguro que queres pechar sesión?'),
        actions: [
          // Botón cancelar
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          // Botón confirmar, redirixe ao login eliminando o historial
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const PantallaLogin()),
                (route) => false,
              );
            },
            child: const Text(
              'Pechar sesión',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Xera os ítems da barra de navegación segundo o rol do usuario
  List<BottomNavigationBarItem> _itemsNavegacion() {
    return [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
      const BottomNavigationBarItem(icon: Icon(Icons.grid_3x3), label: 'Escanear'),
      const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
      if (widget.eAdmin)
        const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
    ];
  }

  /// Constrúe a interfaz principal coa pantalla actual e a barra de navegación inferior
  @override
  Widget build(BuildContext context) {
    final items = _itemsNavegacion();
    return Scaffold(
      // Mostra a pantalla correspondente ao índice actual
      body: _pantallas[_indiceActual],

      // Barra de navegación inferior con botóns dinámicos segundo o rol
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (indice) => setState(() => _indiceActual = indice),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        // Necesario para que se vexan as etiquetas cando hai máis de 3 ítems
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}
