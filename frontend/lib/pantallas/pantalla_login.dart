import 'package:flutter/material.dart';
import 'pantalla_principal.dart';
import 'pantalla_registro.dart';
import '../servizos/api_servizo.dart';
import '../widgets/logo_cabeceira.dart';
import '../widgets/campo_correo.dart';
import '../widgets/campo_contrasinal.dart';
import '../widgets/boton_principal.dart';
import '../widgets/contedor_erro.dart';
import '../widgets/enlace_navegacion.dart';

/// Pantalla de inicio de sesión
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasinalController = TextEditingController();
  bool _cargando = false;
  String? _erroMensaxe;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasinalController.dispose();
    super.dispose();
  }

  /// Valida o formulario e chama ao backend para autenticar o usuario
  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _cargando = true; _erroMensaxe = null; });

    try {
      final usuario = await ApiServizo.iniciarSesion(
        _correoController.text.trim(),
        _contrasinalController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PantallaPrincipal(
            usuarioId: usuario['id'] as int,
            nomeUsuario: usuario['nome'] as String,
            eAdmin: usuario['e_admin'] as bool,
          ),
        ),
        (route) => false,
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
        title: const Text('ScanGo - Entrar'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LogoCabeceira(subtitulo: 'Inicia sesión para continuar'),
                CampoCorreo(controller: _correoController),
                const SizedBox(height: 16),
                CampoContrasinal(
                  controller: _contrasinalController,
                  labelText: 'Contrasinal',
                  hintText: 'Introduce o teu contrasinal',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Introduce o teu contrasinal';
                    if (v.length < 6) return 'O contrasinal debe ter alomenos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                if (_erroMensaxe != null) ...[
                  ContedorErro(mensaxe: _erroMensaxe!),
                  const SizedBox(height: 12),
                ],
                BotonPrincipal(texto: 'Entrar', cargando: _cargando, onPressed: _entrar),
                const SizedBox(height: 16),
                EnlaceNavegacion(
                  texto: 'Non tes conta?',
                  textoEnlace: 'Rexistrate',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PantallaRegistro()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
