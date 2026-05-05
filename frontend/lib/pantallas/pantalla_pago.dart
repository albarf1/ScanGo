import 'package:flutter/material.dart';
import '../servizos/api_servizo.dart';
import '../widgets/boton_principal.dart';
import '../widgets/contedor_erro.dart';
import '../widgets/tarxeta_metodo_pago.dart';
import 'pantalla_ticket.dart';

/// Pantalla de selección de método de pago (funcionalidade futura)
class PantallaPago extends StatefulWidget {
  final int usuarioId;
  final String nomeUsuario;
  final bool eAdmin;
  final double total;

  const PantallaPago({
    super.key,
    required this.usuarioId,
    required this.total,
    this.nomeUsuario = '',
    this.eAdmin = false,
  });

  @override
  State<PantallaPago> createState() => _PantallaPagoState();
}

class _PantallaPagoState extends State<PantallaPago> {
  /// Método de pago seleccionado polo usuario
  int _metodoSeleccionado = 0;
  bool _cargando = false;
  String? _erroMensaxe;

  /// Opcións de pago dispoñibles
  final List<Map<String, dynamic>> _metodos = [
    {'icono': Icons.credit_card, 'titulo': 'Tarxeta bancaria', 'subtitulo': 'Débito ou crédito'},
    {'icono': Icons.money, 'titulo': 'Efectivo', 'subtitulo': 'Paga na caixa ao saír'},
    {'icono': Icons.phone_android, 'titulo': 'Pago por móbil', 'subtitulo': 'Apple Pay / Google Pay'},
  ];

  /// Chama ao backend para finalizar a compra e navega ao ticket
  Future<void> _confirmarPago() async {
    setState(() { _cargando = true; _erroMensaxe = null; });
    try {
      final ticket = await ApiServizo.finalizarCompra(widget.usuarioId);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PantallaTicket(
            ticket: ticket,
            usuarioId: widget.usuarioId,
            nomeUsuario: widget.nomeUsuario,
            eAdmin: widget.eAdmin,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _erroMensaxe = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Método de pago'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumo do importe a pagar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  const Text('IMPORTE TOTAL', style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.total.toStringAsFixed(2)} €',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'FORMA DE PAGO',
              style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Lista de métodos de pago
            ...List.generate(_metodos.length, (i) {
              final metodo = _metodos[i];
              return TarxetaMetodoPago(
                icono: metodo['icono'] as IconData,
                titulo: metodo['titulo'] as String,
                subtitulo: metodo['subtitulo'] as String,
                seleccionado: _metodoSeleccionado == i,
                onTap: () => setState(() => _metodoSeleccionado = i),
              );
            }),

            const SizedBox(height: 20),

            // Mensaxe de erro se a hai
            if (_erroMensaxe != null) ...[
              ContedorErro(mensaxe: _erroMensaxe!),
              const SizedBox(height: 12),
            ],

            // Botón confirmar pago
            BotonPrincipal(
              texto: 'Pagar ${widget.total.toStringAsFixed(2)} €',
              cargando: _cargando,
              onPressed: _confirmarPago,
            ),
            const SizedBox(height: 12),

            // Aviso de funcionalidade futura
            const Center(
              child: Text(
                'Pasarela de pago real — funcionalidade futura',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
