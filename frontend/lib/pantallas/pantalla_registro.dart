import 'package:flutter/material.dart';
import 'pantalla_login.dart';
import '../servizos/api_servizo.dart';
import '../widgets/logo_cabeceira.dart';
import '../widgets/campo_nome.dart';
import '../widgets/campo_correo.dart';
import '../widgets/campo_contrasinal.dart';
import '../widgets/boton_principal.dart';
import '../widgets/contedor_erro.dart';
import '../widgets/enlace_navegacion.dart';

/// Pantalla de rexistro de usuario
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasinalController = TextEditingController();
  final _contrasinalConfirmController = TextEditingController();
  bool _cargando = false;
  String? _erroMensaxe;

  @override
  void dispose() {
    _nomeController.dispose();
    _correoController.dispose();
    _contrasinalController.dispose();
    _contrasinalConfirmController.dispose();
    super.dispose();
  }

  /// Valida o formulario e chama ao backend para crear a conta
  Future<void> _registrarse() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _cargando = true; _erroMensaxe = null; });

    try {
      await ApiServizo.registrarse(
        _nomeController.text.trim(),
        _correoController.text.trim(),
        _contrasinalController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta creada correctamente. Inicia sesión.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaLogin()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final mensaxe = e.toString().replaceFirst('Exception: ', '');

      // Se o correo xa existe mostramos un diálogo con opción de ir ao login
      if (mensaxe.contains('xa está rexistrado')) {
        setState(() => _cargando = false);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Correo xa rexistrado'),
            content: const Text('O correo electrónico xa ten unha conta en ScanGo.\n\n¿Queres iniciar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PantallaLogin()),
                  (route) => false,
                ),
                child: const Text('Iniciar sesión', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        return;
      }
      setState(() => _erroMensaxe = mensaxe);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScanGo - Rexistro'),
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
                const LogoCabeceira(subtitulo: 'Crea a túa conta'),
                if (_erroMensaxe != null) ...[
                  ContedorErro(mensaxe: _erroMensaxe!),
                  const SizedBox(height: 16),
                ],
                CampoNome(controller: _nomeController),
                const SizedBox(height: 16),
                CampoCorreo(controller: _correoController),
                const SizedBox(height: 16),
                CampoContrasinal(
                  controller: _contrasinalController,
                  labelText: 'Contrasinal',
                  hintText: 'Polo menos 8 caracteres',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Introduce un contrasinal';
                    if (v.length < 8) return 'O contrasinal debe ter polo menos 8 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CampoContrasinal(
                  controller: _contrasinalConfirmController,
                  labelText: 'Confirmar contrasinal',
                  hintText: 'Repite o contrasinal',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirma o contrasinal';
                    if (v != _contrasinalController.text) return 'Os contrasinais non coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                BotonPrincipal(texto: 'Crear conta', cargando: _cargando, onPressed: _registrarse),
                const SizedBox(height: 16),
                EnlaceNavegacion(
                  texto: '¿Xa tes conta?',
                  textoEnlace: 'Inicia sesión',
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const PantallaLogin()),
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
