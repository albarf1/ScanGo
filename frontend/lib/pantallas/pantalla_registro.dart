import 'package:flutter/material.dart';
import 'pantalla_login.dart';
import '../servizos/api_servizo.dart';

/// Pantalla de rexistro de usuario, permite que o usuario cree unha nova conta introducindo nome, correo e contrasinal
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

/// Xestiona:campos de nome, correo, contrasinal e confirmación,validación do formulario,envío dos datos ao backend e redirección á pantalla de login ao rexistrarse correctamente
class _PantallaRegistroState extends State<PantallaRegistro> {
  /// Clave para validar o formulario
  final _formKey = GlobalKey<FormState>();

  /// Controlador do nome completo
  final _nomeController = TextEditingController();

  /// Controlador do correo
  final _correoController = TextEditingController();

  /// Controlador do contrasinal
  final _contrasinalController = TextEditingController();

  /// Controlador da confirmación do contrasinal
  final _contrasinalConfirmController = TextEditingController();

  /// Indica se se está cargando a petición ao backend
  bool _cargando = false;

  /// Controla se se mostra ou oculta o contrasinal
  bool _mostrarContrasinal = false;

  /// Controla se se mostra ou oculta o contrasinal de confirmación
  bool _mostrarContrasinalConfirm = false;

  /// Almacena o mensaxe de erro si o rexistro falla
  String? _erroMensaxe;

  /// Libera os recursos dos controladores
  @override
  void dispose() {
    _nomeController.dispose();
    _correoController.dispose();
    _contrasinalController.dispose();
    _contrasinalConfirmController.dispose();
    super.dispose();
  }

  /// Realiza o rexistro do usuario,valida o formulario e navega á pantalla de login si todo é correcto

  Future<void> _registrarse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _erroMensaxe = null;
    });

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

      if (mensaxe.contains('xa está rexistrado')) {
        setState(() => _cargando = false);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Correo xa rexistrado'),
            content: const Text(
              'O correo electrónico xa ten unha conta en ScanGo.\n\n¿Queres iniciar sesión?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const PantallaLogin()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(color: Colors.white),
                ),
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
                  'Crea a túa conta',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Erro de servidor (correo duplicado, sen conexión, etc.)
                if (_erroMensaxe != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _erroMensaxe!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Campo de nome completo
                TextFormField(
                  controller: _nomeController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'Nome completo',
                    hintText: 'Alba Rodríguez',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Validador do campo
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Introduce o teu nome';
                    }
                    if (value.length < 2) {
                      return 'O nome debe ter polo menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                    hintText: 'Polo menos 8 caracteres',
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
                      return 'Introduce un contrasinal';
                    }
                    if (value.length < 8) {
                      return 'O contrasinal debe ter polo menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de confirmación do contrasinal
                TextFormField(
                  controller: _contrasinalConfirmController,
                  obscureText: !_mostrarContrasinalConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contrasinal',
                    hintText: 'Repite o contrasinal',
                    prefixIcon: const Icon(Icons.lock),
                    // Botón para mostrar/ocultar o contrasinal
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarContrasinalConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() =>
                            _mostrarContrasinalConfirm =
                                !_mostrarContrasinalConfirm);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Validador do campo
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirma o contrasinal';
                    }
                    if (value != _contrasinalController.text) {
                      return 'Os contrasinais non coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botón de rexistro
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _registrarse,
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
                            'Crear conta',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Vínculo para ir a pantalla de login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Xa tes conta?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const PantallaLogin(),
                          ),
                        );
                      },
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
