import 'package:flutter/material.dart';

/// Campo de texto para contrasinal con botón para mostrar/ocultar
class CampoContrasinal extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? Function(String?) validator;

  const CampoContrasinal({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.validator,
  });

  @override
  State<CampoContrasinal> createState() => _CampoContrasinalState();
}

class _CampoContrasinalState extends State<CampoContrasinal> {
  // Controla se o contrasinal está visible ou oculto
  bool _mostrar = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !_mostrar,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock),
        // Botón para alternar visibilidade
        suffixIcon: IconButton(
          icon: Icon(_mostrar ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _mostrar = !_mostrar),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: widget.validator,
    );
  }
}
