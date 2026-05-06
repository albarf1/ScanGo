import 'package:flutter/material.dart';
import '../servizos/api_servizo.dart';
import '../widgets/boton_principal.dart';
import '../widgets/contedor_erro.dart';
import '../widgets/formulario_campos_produto.dart';

/// Pantalla para que o administrador edite un produto existente
class PantallaEditarProduto extends StatefulWidget {
  /// Datos actuais do produto a editar
  final Map<String, dynamic> produto;

  const PantallaEditarProduto({super.key, required this.produto});

  @override
  State<PantallaEditarProduto> createState() => _PantallaEditarProdutoState();
}

class _PantallaEditarProdutoState extends State<PantallaEditarProduto> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _prezoController;
  late final TextEditingController _stockController;
  late final TextEditingController _codigoQrController;
  late final TextEditingController _descripcionController;
  bool _cargando = false;
  String? _erroMensaxe;

  @override
  void initState() {
    super.initState();
    // Pre-rellenamos os campos cos datos actuais do produto
    _nomeController = TextEditingController(text: widget.produto['nome'] ?? '');
    _prezoController = TextEditingController(text: '${widget.produto['prezo'] ?? ''}');
    _stockController = TextEditingController(text: '${widget.produto['stock'] ?? ''}');
    _codigoQrController = TextEditingController(text: widget.produto['codigo_qr'] ?? '');
    _descripcionController = TextEditingController(text: widget.produto['descripcion'] ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _prezoController.dispose();
    _stockController.dispose();
    _codigoQrController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  /// Valida e envía os datos editados ao backend
  Future<void> _gardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _cargando = true; _erroMensaxe = null; });

    try {
      await ApiServizo.editarProduto(
        id: widget.produto['id'] as int,
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
        const SnackBar(
          content: Text('Produto actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
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
        title: const Text('Editar produto'),
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
                texto: 'Gardar cambios',
                cargando: _cargando,
                onPressed: _gardarCambios,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
