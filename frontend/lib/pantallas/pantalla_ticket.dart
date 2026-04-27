import 'package:flutter/material.dart';
import 'pantalla_principal.dart';

/// Pantalla de ticket que se mostra tras finalizar a compra con éxito
class PantallaTicket extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final int usuarioId;
  final String nomeUsuario;
  final bool eAdmin;

  const PantallaTicket({
    super.key,
    required this.ticket,
    required this.usuarioId,
    this.nomeUsuario = '',
    this.eAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final lineas = ticket['lineas'] as List<dynamic>;
    final total = (ticket['total'] as num).toStringAsFixed(2);
    final data = ticket['data'] as String;
    final compraId = ticket['compra_id'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compra finalizada'),
        backgroundColor: Colors.green,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Icono de confirmación
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 12),
            const Text(
              'Grazas pola túa compra!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Nº $compraId  ·  $data',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Ticket con liñas de produtos
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Cabeceira do ticket
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(child: Text('Produto', style: TextStyle(fontWeight: FontWeight.bold))),
                        Text('Cant.', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 16),
                        SizedBox(
                          width: 70,
                          child: Text('Subtotal', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  // Liñas de cada produto
                  ...lineas.map((l) {
                    final subtotal = (l['subtotal'] as num).toStringAsFixed(2);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l['nome_produto'], style: const TextStyle(fontWeight: FontWeight.w500)),
                                Text(
                                  '${(l['prezo_unitario'] as num).toStringAsFixed(2)} € / ud',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text('x${l['cantidad']}'),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 70,
                            child: Text(
                              '$subtotal €',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // Liña divisoria
                  Divider(color: Colors.grey.shade300, height: 1),
                  // Total
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '$total €',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botón para volver á app sen pechar sesión
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Nova compra', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => PantallaPrincipal(
                        usuarioId: usuarioId,
                        nomeUsuario: nomeUsuario,
                        eAdmin: eAdmin,
                      ),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
