import 'package:flutter/material.dart';
import 'pantalla_principal.dart';

/// Pantalla de inicio de sesión,permite que o usuario introduza o seu correo e contrasinal para acceder 
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}


/// Xestiona:campos de correo e contrasinal,validación do formulario,envío dos datos ao backend e redirección á pantalla principal ao entrar correctamente
class _PantallaLoginState extends State<PantallaLogin> {
  /// Clave para validar o formulario
  final _formKey = GlobalKey<FormState>();

  /// Controlador do correo
  final _correoController = TextEditingController();

  /// Controlador do contrasinal
  final _contrasinalController = TextEditingController();

  /// Indica se se está cargando a petición ao backend
  bool _cargando = false;

  /// Controla se se mostra ou oculta o contrasinal
  bool _mostrarContrasinal = false;

  /// Almacena o mensaxe de erro si o login falla
  String? _erroMensaxe;

  /// Libera os recursos dos controladores
  @override
  void dispose() {
    _correoController.dispose();
    _contrasinalController.dispose();
    super.dispose();
  }

  /// Realiza o login do usuario,valida o formulario e navega á pantalla principal se as credenciais son correctas

  Future<void> _entrar() async {
    // Valida que os campos non estean vacios e teñan formato correcto
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _erroMensaxe = null;
    });

    try {
      // Validación básica 
      if (_correoController.text.contains('@') &&
          _contrasinalController.text.length >= 6) {
        if (!mounted) return;

        // Navega a PantallaPrincipal e elimina a pantalla de login 
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const PantallaPrincipal(),
          ),
          (route) => false,
        );
      } else {
        setState(() => _erroMensaxe = 'Correo ou contrasinal incorrecto');
      }
    } catch (e) {
      setState(() => _erroMensaxe = 'Erro ao intentar entrar: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Constrúe a interfaz da pantalla de login
  /// Mostra un formulario co logo o correo e contrasinal
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
                // Logo de ScanGo con icono de QR
                Icon(
                  Icons.qr_code_2,
                  size: 80,
                  color: Colors.blue[600],
                ),
                const SizedBox(height: 20),

                // Título da aplicación
                const Text(
                  'ScanGo',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtítulo
                const Text(
                  'Inicia sesión para continuar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Campo de correo
                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'alba@scango.com',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Validador do campo
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Introduce o teu email';
                    }
                    if (!value.contains('@')) {
                      return 'Email non válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de contrasinal
                TextFormField(
                  controller: _contrasinalController,
                  obscureText: !_mostrarContrasinal,
                  decoration: InputDecoration(
                    labelText: 'Contrasinal',
                    hintText: 'Introduce o teu contrasinal',
                    prefixIcon: const Icon(Icons.lock),
                    // Botón para mostrar/ocultar o contrasinal
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarContrasinal
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() =>
                            _mostrarContrasinal = !_mostrarContrasinal);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Validador do campo
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Introduce o teu contrasinal';
                    }
                    if (value.length < 6) {
                      return 'O contrasinal debe ter alomenos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Mostra mensaxe de erro se existe
                if (_erroMensaxe != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _erroMensaxe!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Botón de entrar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _entrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Entrar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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
