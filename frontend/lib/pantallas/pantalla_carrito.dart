import 'package:flutter/material.dart';
import '../servizos/api_servizo.dart';

/// Pantalla que mostra o carrito de compra do usuario
/// Amosa os productos engadidos e permite finalizar a compra
class PantallaCarrito extends StatefulWidget {
  /// ID do usuario propietario do carrito
  final int usuarioId;

  const PantallaCarrito({super.key, required this.usuarioId});

  @override
  State<PantallaCarrito> createState() => _PantallaCarritoState();
}

/// Estado da pantalla do carrito
/// Responsable de:
/// - Cargar os datos do carrito desde o backend
/// - Mostrar a lista de productos
/// - Calcular e mostrar o total
/// - Permitir finalizar a compra
class _PantallaCarritoState extends State<PantallaCarrito> {
  /// Almacena os dados do carrito con productos e total
  Map<String, dynamic>? carrito;
  
  /// Indica si os datos se están cargando
  bool cargando = true;

  /// Inicia a carga dos datos do carrito
  @override
  void initState() {
    super.initState();
    cargarCarrito();
  }

  /// Obtén os datos do carrito desde o backend
  /// Chama a ApiServizo.verCarrito() pasando o ID do usuario
  /// Actualiza o estado cando os datos se cargan
  Future<void> cargarCarrito() async {
    try {
      // Chama ao backend para obter o carrito do usuario
      final datos = await ApiServizo.verCarrito(widget.usuarioId);
      setState(() {
        carrito = datos;
        cargando = false;
      });
    } catch (e) {
      // Si ocorre erro, marca como cargado pero sen datos
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('O meu carrito'),
        backgroundColor: Colors.blue,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : carrito == null || (carrito!['lineas'] as List).isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      const Text(
                        'O carrito está vacío',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Escanea produtos para empezar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header con información: número de productos e botón de actualizar
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue.shade50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${carrito!['lineas'].length} productos',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          // Botón para actualizar o carrito
                          TextButton.icon(
                            onPressed: cargarCarrito,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Actualizar'),
                          ),
                        ],
                      ),
                    ),
                    // Lista de productos no carrito
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: carrito!['lineas'].length,
                        itemBuilder: (context, index) {
                          // Datos da linea de carrito (producto)
                          final linea = carrito!['lineas'][index];
                          final subtotal = linea['subtotal'] ?? 0;
                          final cantidad = linea['cantidad'] ?? 1;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Icono representativo do producto
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.shopping_bag,
                                      color: Colors.blue.shade400,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Información do producto: nome, prezo unitario e cantidad
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Nome do producto
                                        Text(
                                          linea['nome_produto'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Prezo unitario e cantidad
                                        Text(
                                          '${linea['prezo_unitario']} € x $cantidad',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Subtotal (prezo unitario x cantidad)
                                  Text(
                                    '${subtotal.toStringAsFixed(2)} €',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Pie do carrito con total e botón de finalizar compra
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Fila con total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Cantidade total a pagar
                              Text(
                                '${carrito!['total'].toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Botón para finalizar a compra
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Mostra un SnackBar (próximamente integrar con pago)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Finalizando compra (próximo)...'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Finalizar compra'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
