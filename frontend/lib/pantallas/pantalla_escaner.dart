import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'pantalla_produto.dart';

/// Pantalla de escaneo de códigos QR,utiliizamos a camara do dispositivo para detectar códigos
class PantallaEscaner extends StatefulWidget {
  const PantallaEscaner({super.key});

  @override
  State<PantallaEscaner> createState() => _PantallaEscanerState();
}

/// Estado da pantalla de escaneo,detecta o código QR e navega á pantalla de detalles do produto
class _PantallaEscanerState extends State<PantallaEscaner> {
  /// Booleano que controla se o escaneo está activo,evita que se detecte o mesmo código dúas veces
  bool escanando = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // imou usar a librería mobile_scanner para captar códigos de barras
          MobileScanner(
            onDetect: (captura) {
              // Non fai nada se o escaneo está desactivado
              if (!escanando) return;

              // Obtén o valor do primeiro código detectado
              final codigo = captura.barcodes.first.rawValue;
              if (codigo == null) return;

              // desactivamos o escaneo para non procesar o mismo código dúas veces
              setState(() => escanando = false);
              // Navega á pantalla de detalles do produto, co codigo
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PantallaProduto(codigoQr: codigo),
                ),
              ).then((_) => setState(() => escanando = true)); // Reactiva o escaneo ó volver
            },
          ),
        
          // Mostra onde debe estar o código QR
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          
          // Botón de volta 
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
          // Texto instructivo na parte inferior
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Text(
                'Apunta ao código QR do produto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
