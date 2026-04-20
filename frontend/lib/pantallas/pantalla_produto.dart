import 'package:flutter/material.dart';
import '../servizos/api_servizo.dart';
import 'pantalla_carrito.dart';

/// Pantalla que mostra os detalles dun produto, co producto previamente escaneado
class PantallaProduto extends StatefulWidget {
  /// Código QR do produto escaneado
  final String codigoQr;

  /// ID do usuario autenticado
  final int usuarioId;

  const PantallaProduto({super.key, required this.codigoQr, required this.usuarioId});

  @override
  State<PantallaProduto> createState() => _PantallaProdutoState();
}

/// Estado da pantalla do produto, carga os datos do produto desde o backend e permite engadilo ao carrito
class _PantallaProdutoState extends State<PantallaProduto> {
  /// Almacena os datos do produto descargados do backend
  Map<String, dynamic>? produto;

  /// Indica se os datos se están cargando
  bool cargando = true;

  /// Almacena mensaxe de erro se ocorre algún problema
  String? erro;

  /// Carga os datos do produto ao crear o widget
  @override
  void initState() {
    super.initState();
    cargarProduto();
  }

  /// Obtén os datos do produto desde o backend polo código QR
  Future<void> cargarProduto() async {
    try {
      // Chama ao backend para obter o produto polo seu QR
      final datos = await ApiServizo.escanearProduto(widget.codigoQr);
      setState(() {
        produto = datos;
        cargando = false;
      });
    } catch (e) {
      // Se non se atopa o producto, mostramos un erro
      setState(() {
        erro = 'Produto non atopado';
        cargando = false;
      });
    }
  }

  /// Engade o produto actual ao carrito do usuario e navega á pantalla do carrito
  Future<void> engadirAoCarrito() async {
    try {
      // Chama ao backend para engadir o produto ao carrito
      await ApiServizo.engadirAoCarrito(widget.usuarioId, widget.codigoQr);

      if (!mounted) return;

      // Navega á pantalla do carrito para mostrar o novo produto
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaCarrito(usuarioId: widget.usuarioId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao engadir ao carrito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información do produto'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: cargando
            ? const CircularProgressIndicator()
            : erro != null
                ? Text(erro!, style: const TextStyle(color: Colors.red))
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Nome do produto
                        Text(
                          produto!['nome'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Prezo en euros
                        Text(
                          '${produto!['prezo']} €',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Descrición do produto
                        Text(
                          produto!['descripcion'] ?? '',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Stock dispoñible
                        Text(
                          'Stock: ${produto!['stock']} unidades',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                        // Botón para engadir ao carrito
                        ElevatedButton.icon(
                          onPressed: engadirAoCarrito,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Engadir ao carrito'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
