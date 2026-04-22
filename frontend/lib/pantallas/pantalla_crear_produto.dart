import 'package:flutter/material.dart';
import '../servizos/api_servizo.dart';
import '../widgets/boton_principal.dart';
import '../widgets/contedor_erro.dart';

/// Pantalla para que o administrador cree un novo produto no catálogo
class PantallaCrearProduto extends StatefulWidget {
  const PantallaCrearProduto({super.key});

  @override
  State<PantallaCrearProduto> createState() => _PantallaCrearProdutoState();
}

class _PantallaCrearProdutoState extends State<PantallaCrearProduto> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _prezoController = TextEditingController();
  final _stockController = TextEditingController();
  final _codigoQrController = TextEditingController();
  final _descripcionController = TextEditingController();
  bool _cargando = false;
  String? _erroMensaxe;

  @override
  void dispose() {
    _nomeController.dispose();
    _prezoController.dispose();
    _stockController.dispose();
    _codigoQrController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  /// Valida o formulario e envía os datos ao backend para crear o produto
  Future<void> _gardarProduto() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _cargando = true; _erroMensaxe = null; });

    try {
      await ApiServizo.crearProduto(
        nome: _nomeController.text.trim(),
        prezo: double.parse(_prezoController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        codigoQr: _codigoQrController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
      );

      if (!mounted) return;
      // Mostra confirmación e volta á lista
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto creado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
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
        title: const Text('Novo produto'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo nome do produto
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do produto',
                  hintText: 'Ex: Leite enteiro 1L',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Introduce o nome do produto';
                  if (v.trim().length < 2) return 'O nome debe ter polo menos 2 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo prezo
              TextFormField(
                controller: _prezoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Prezo (€)',
                  hintText: 'Ex: 1.25',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.euro),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Introduce o prezo';
                  final prezo = double.tryParse(v.trim());
                  if (prezo == null) return 'O prezo debe ser un número';
                  if (prezo <= 0) return 'O prezo debe ser maior que cero';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo stock
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  hintText: 'Ex: 100',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Introduce o stock';
                  final stock = int.tryParse(v.trim());
                  if (stock == null) return 'O stock debe ser un número enteiro';
                  if (stock < 0) return 'O stock non pode ser negativo';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo código QR
              TextFormField(
                controller: _codigoQrController,
                decoration: const InputDecoration(
                  labelText: 'Código QR',
                  hintText: 'Ex: QR007',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Introduce o código QR';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo descrición (opcional)
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrición (opcional)',
                  hintText: 'Breve descrición do produto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),

              // Mensaxe de erro se a hai
              if (_erroMensaxe != null) ...[
                ContedorErro(mensaxe: _erroMensaxe!),
                const SizedBox(height: 12),
              ],

              // Botón para gardar o produto
              BotonPrincipal(
                texto: 'Gardar produto',
                cargando: _cargando,
                onPressed: _gardarProduto,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
