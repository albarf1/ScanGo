import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'pantalla_produto.dart';

/// Pantalla de escaneo de códigos QR, utiliza a cámara do dispositivo para detectar códigos
class PantallaEscaner extends StatefulWidget {
  const PantallaEscaner({super.key});

  @override
  State<PantallaEscaner> createState() => _PantallaEscanerState();
}

class _PantallaEscanerState extends State<PantallaEscaner> {
  /// Controla se o escaneo está activo, evita detectar o mesmo código dúas veces
  bool escanando = true;

  /// Controlador do campo de introdución manual do código QR
  final _codigoController = TextEditingController();

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  /// Navega á pantalla do produto co código indicado
  void _irAProduto(String codigo) {
    if (codigo.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PantallaProduto(codigoQr: codigo.trim())),
    ).then((_) => setState(() => escanando = true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Visor da cámara QR
          Expanded(
            child: Stack(
              children: [
                // Librería mobile_scanner para captar códigos de barras
                MobileScanner(
                  onDetect: (captura) {
                    if (!escanando) return;
                    if (captura.barcodes.isEmpty) return;
                    final codigo = captura.barcodes.first.rawValue;
                    if (codigo == null) return;
                    setState(() => escanando = false);
                    _irAProduto(codigo);
                  },
                ),

                // Marco guía para enfocar o código QR
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                // Texto instructivo na parte inferior do visor
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Apunta ao código QR do produto',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Separador con texto
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[400])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'ou introduce o código manualmente',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[400])),
              ],
            ),
          ),

          // Campo de introdución manual do código QR
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codigoController,
                    decoration: InputDecoration(
                      labelText: 'Código QR',
                      hintText: 'Ex: QR001',
                      prefixIcon: const Icon(Icons.qr_code),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    onSubmitted: _irAProduto,
                  ),
                ),
                const SizedBox(width: 10),
                // Botón para buscar o produto polo código introducido
                ElevatedButton(
                  onPressed: () => _irAProduto(_codigoController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
