import 'package:flutter/material.dart';

/// Campos do formulario compartido entre crear e editar produto
class FormularioCamposProduto extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController prezoController;
  final TextEditingController stockController;
  final TextEditingController codigoQrController;
  final TextEditingController descripcionController;

  const FormularioCamposProduto({
    super.key,
    required this.nomeController,
    required this.prezoController,
    required this.stockController,
    required this.codigoQrController,
    required this.descripcionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo nome do produto
        TextFormField(
          controller: nomeController,
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
          controller: prezoController,
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
          controller: stockController,
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
          controller: codigoQrController,
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
          controller: descripcionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Descrición (opcional)',
            hintText: 'Breve descrición do produto',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
