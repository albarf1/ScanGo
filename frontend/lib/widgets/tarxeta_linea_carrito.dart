import 'package:flutter/material.dart';

/// Card que representa unha liña do carrito con botóns +/- e eliminar
class TarxetaLineaCarrito extends StatelessWidget {
  final String nomeProduto;
  final double prezoUnitario;
  final int cantidad;
  final double subtotal;
  final VoidCallback onEliminar;
  final VoidCallback onAumentar;
  final VoidCallback? onDiminuir;

  const TarxetaLineaCarrito({
    super.key,
    required this.nomeProduto,
    required this.prezoUnitario,
    required this.cantidad,
    required this.subtotal,
    required this.onEliminar,
    required this.onAumentar,
    this.onDiminuir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // Icono do produto
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.shopping_bag, color: Colors.blue.shade400),
                ),
                const SizedBox(width: 12),
                // Nome e prezo unitario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomeProduto,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${prezoUnitario.toStringAsFixed(2)} € / ud',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Subtotal
                Text(
                  '${subtotal.toStringAsFixed(2)} €',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Fila con botóns +/- e eliminar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón eliminar
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  tooltip: 'Eliminar',
                  onPressed: onEliminar,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                // Botón diminuír
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.blue, size: 22),
                  onPressed: onDiminuir,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                // Cantidade actual
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$cantidad',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                // Botón aumentar
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.blue, size: 22),
                  onPressed: onAumentar,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
