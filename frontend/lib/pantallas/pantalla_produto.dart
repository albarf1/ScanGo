import 'package:flutter/material.dart';
import '../servizos/api_servizo.dart';
import 'pantalla_carrito.dart';

/// Pantalla que mostra os detalles dun produto
/// Cargase o produto desde o QR escaneado
class PantallaProduto extends StatefulWidget {
  /// Código QR do produto obtido ao escanear
  final String codigoQr;

  const PantallaProduto({super.key, required this.codigoQr});

  @override
  State<PantallaProduto> createState() => _PantallaProdutoState();
}

/// Estado da pantalla do produto
/// Responsable de:
/// - Cargar os datos do produto desde o backend
/// - Mostrar a información (nome, prezo, stock, etc)
/// - Engadir o produto ao carrito do usuario
class _PantallaProdutoState extends State<PantallaProduto> {
  /// ID do usuario (fixo para a proba)
  final int usuarioId = 1;
  
  /// Almacena os datos do produto descargados do backend
  Map<String, dynamic>? produto;
  
  /// Indica se os datos se están cargando
  bool cargando = true;
  
  /// Almacena mensaxe de erro se ocorre algun problema
  String? erro;

  /// Se executa ó crear o widget
  /// Inicia a carga dos datos do produto
  @override
  void initState() {
    super.initState();
    cargarProduto();
  }

  /// Obtén os datos do produto desde o backend
  /// Chama a ApiServizo.escanearProduto() pasando o código QR
  /// Actualiza o estado cando os datos se cargan ou ocorre un erro
  Future<void> cargarProduto() async {
    try {
      // Chama ao backend para obter o produto polo seu QR
      final datos = await ApiServizo.escanearProduto(widget.codigoQr);
      setState(() {
        produto = datos;
        cargando = false;
      });
    } catch (e) {
      // Se non se atopa o producto, mostra erro
      setState(() {
        erro = 'Produto non atopado';
        cargando = false;
      });
    }
  }

  /// Engade o produto actual ao carrito do usuario
  /// Depois navega á pantalla do carrito
  /// Si ocorre un erro, mostra unha notificación
  Future<void> engadirAoCarrito() async {
    try {
      // Chama ao backend para engadir o produto ao carrito
      // Envía o ID do usuario e o código QR do producto
      await ApiServizo.engadirAoCarrito(usuarioId, widget.codigoQr);
      
      // Se o widget se desacoplou, non continúa
      if (!mounted) return;
      
      // Navega á pantalla do carrito para mostrar o novo producto
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaCarrito(usuarioId: usuarioId),
        ),
      );
    } catch (e) {
      // Mostra un SnackBar con mensaxe de erro
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
            // Se se está cargando, mostra un indicator de progreso
            ? const CircularProgressIndicator()
            // Se ocorreu un erro, mostra a mensaxe
            : erro != null
                ? Text(erro!, style: const TextStyle(color: Colors.red))
                // Se se cargaron os datos, mostralos
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Nome do producto
                        Text(
                          produto!['nome'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Prezo en euros (azul para resaltar)
                        Text(
                          '${produto!['prezo']} €',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Descripción do producto
                        Text(
                          produto!['descripcion'] ?? '',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Cantidad de stock disponible
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
