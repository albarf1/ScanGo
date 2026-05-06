import 'package:flutter/material.dart';
import '../servizos/api_servizo.dart';
import '../widgets/boton_principal.dart';
import '../widgets/contedor_erro.dart';
import '../widgets/formulario_campos_produto.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto creado correctamente'), backgroundColor: Colors.green),
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
              FormularioCamposProduto(
                nomeController: _nomeController,
                prezoController: _prezoController,
                stockController: _stockController,
                codigoQrController: _codigoQrController,
                descripcionController: _descripcionController,
              ),
              const SizedBox(height: 20),
              if (_erroMensaxe != null) ...[
                ContedorErro(mensaxe: _erroMensaxe!),
                const SizedBox(height: 12),
              ],
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
