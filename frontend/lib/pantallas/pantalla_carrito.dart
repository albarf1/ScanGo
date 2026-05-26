import 'package:flutter/material.dart';
import '../servizos/api_servizo.dart';
import '../widgets/tarxeta_linea_carrito.dart';
import 'pantalla_pago.dart';

/// Pantalla que mostra o carrito de compra do usuario
class PantallaCarrito extends StatefulWidget {
  final int usuarioId;
  final String nomeUsuario;
  final bool eAdmin;
  final VoidCallback? onSeguirComprando;

  const PantallaCarrito({
    super.key,
    required this.usuarioId,
    this.nomeUsuario = '',
    this.eAdmin = false,
    this.onSeguirComprando,
  });

  @override
  State<PantallaCarrito> createState() => _PantallaCarritoState();
}

class _PantallaCarritoState extends State<PantallaCarrito> {
  Map<String, dynamic>? carrito;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarCarrito();
  }

  /// Carga os datos do carrito dende o backend
  Future<void> cargarCarrito() async {
    setState(() => cargando = true);
    try {
      final datos = await ApiServizo.verCarrito();
      setState(() { carrito = datos; cargando = false; });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  /// Navega á pantalla de pago co total actual
  void _finalizarCompra() {
    final total = (carrito!['total'] as num).toDouble();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaPago(
          usuarioId: widget.usuarioId,
          nomeUsuario: widget.nomeUsuario,
          eAdmin: widget.eAdmin,
          total: total,
        ),
      ),
    );
  }

  /// Elimina un produto do carrito e recarga os datos
  Future<void> _eliminarProduto(String codigoQr) async {
    try {
      await ApiServizo.eliminarDoCarrito(codigoQr);
      await cargarCarrito();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  /// Actualiza a cantidade dun produto e recarga o carrito
  Future<void> _actualizarCantidade(String codigoQr, int novaCantidade) async {
    try {
      await ApiServizo.actualizarCantidade(codigoQr, novaCantidade);
      await cargarCarrito();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  /// Devolve true se o carrito ten produtos
  bool get _tenItems =>
      carrito != null && (carrito!['lineas'] as List).isNotEmpty;

  /// Mostra diálogo de confirmación antes de saír co carriño con produtos
  Future<bool> _confirmarSaida() async {
    if (!_tenItems) return true;
    final sair = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Saír do carrito'),
        content: const Text('Tes produtos no carrito. Se saes perderás a selección actual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Quedarme'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Saír', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return sair ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Bloqueamos o pop automático para xestionalo nós
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final podeSair = await _confirmarSaida();
        if (podeSair && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : carrito == null || (carrito!['lineas'] as List).isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      const Text(
                        'O carrito está vacío',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Escanea produtos para empezar',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Cabeceira con número de produtos e botón actualizar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: Colors.blue.shade50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${carrito!['lineas'].length} produtos',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          // Botón para seguir escaneando
                          TextButton.icon(
                            onPressed: () {
                              if (widget.onSeguirComprando != null) {
                                widget.onSeguirComprando!();
                              } else {
                                Navigator.of(context).maybePop();
                              }
                            },
                            icon: const Icon(Icons.qr_code_scanner, size: 18),
                            label: const Text('Seguir comprando'),
                          ),
                        ],
                      ),
                    ),

                    // Lista de produtos no carrito
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: carrito!['lineas'].length,
                        itemBuilder: (context, index) {
                          final linea = carrito!['lineas'][index];
                          final cantidad = linea['cantidad'] as int? ?? 1;
                          final codigoQr = linea['codigo_qr'] as String;

                          return TarxetaLineaCarrito(
                            nomeProduto: linea['nome_produto'] as String,
                            prezoUnitario: (linea['prezo_unitario'] as num).toDouble(),
                            cantidad: cantidad,
                            subtotal: (linea['subtotal'] as num).toDouble(),
                            onEliminar: () => _eliminarProduto(codigoQr),
                            onAumentar: () => _actualizarCantidade(codigoQr, cantidad + 1),
                            onDiminuir: cantidad > 1
                                ? () => _actualizarCantidade(codigoQr, cantidad - 1)
                                : null,
                          );
                        },
                      ),
                    ),

                    // Pie con total e botón finalizar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border(top: BorderSide(color: Colors.grey[300]!)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(
                                '${(carrito!['total'] as num).toStringAsFixed(2)} €',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _finalizarCompra,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Finalizar compra'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),  // Scaffold
    );  // PopScope
  }
}
