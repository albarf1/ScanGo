import 'package:flutter/material.dart';
import '../servizos/api_servizo.dart';

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

class _PantallaProdutoState extends State<PantallaProduto> {
  Map<String, dynamic>? produto;
  bool cargando = true;
  String? erro;

  /// Cantidade seleccionada polo usuario antes de engadir ao carrito
  int _cantidade = 1;

  @override
  void initState() {
    super.initState();
    cargarProduto();
  }

  /// Obtén os datos do produto desde o backend polo código QR
  Future<void> cargarProduto() async {
    try {
      final datos = await ApiServizo.escanearProduto(widget.codigoQr);
      setState(() { produto = datos; cargando = false; });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto non atopado'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      // Agardamos a que o snackbar sexa visible e volvemos ao escáner
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  /// Engade o produto co número de unidades seleccionadas e volta ao escáner
  Future<void> engadirAoCarrito() async {
    try {
      await ApiServizo.engadirAoCarrito(
        widget.usuarioId,
        widget.codigoQr,
        cantidad: _cantidade,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_cantidade ${_cantidade == 1 ? 'unidade' : 'unidades'} engadidas ao carrito'),
          backgroundColor: Colors.green,
        ),
      );
      // Volvemos ao escáner para seguir comprando
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
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
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        // Prezo en euros
                        Text(
                          '${produto!['prezo']} €',
                          style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
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

                        // Selector de cantidade
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Botón para diminuír cantidade
                            IconButton(
                              onPressed: _cantidade > 1
                                  ? () => setState(() => _cantidade--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              iconSize: 32,
                              color: Colors.blue,
                            ),
                            // Cantidade actual
                            SizedBox(
                              width: 48,
                              child: Text(
                                '$_cantidade',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Botón para aumentar cantidade
                            IconButton(
                              onPressed: () => setState(() => _cantidade++),
                              icon: const Icon(Icons.add_circle_outline),
                              iconSize: 32,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Botón para engadir ao carrito
                        ElevatedButton.icon(
                          onPressed: engadirAoCarrito,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Engadir ao carrito'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
