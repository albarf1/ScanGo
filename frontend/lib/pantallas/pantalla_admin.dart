import 'package:flutter/material.dart';
import '../servizos/api_servizo.dart';
import 'pantalla_crear_produto.dart';

/// Pantalla de administración: lista de produtos con opcións de xestión
class PantallaAdmin extends StatefulWidget {
  const PantallaAdmin({super.key});

  @override
  State<PantallaAdmin> createState() => _PantallaAdminState();
}

class _PantallaAdminState extends State<PantallaAdmin> {
  List<dynamic> _produtos = [];
  bool _cargando = true;
  String? _erroMensaxe;

  @override
  void initState() {
    super.initState();
    _cargarProdutos();
  }

  /// Carga a lista de produtos dende o backend
  Future<void> _cargarProdutos() async {
    setState(() { _cargando = true; _erroMensaxe = null; });
    try {
      final lista = await ApiServizo.listarProductos();
      setState(() => _produtos = lista);
    } catch (e) {
      setState(() => _erroMensaxe = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _cargando = false);
    }
  }

  /// Navega á pantalla de crear produto e recarga ao volver
  Future<void> _irCrearProduto() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PantallaCrearProduto()),
    );
    // Recargamos por se se creou un produto novo
    _cargarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _erroMensaxe != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mensaxe de erro
                      Text(_erroMensaxe!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      // Botón para reintentar
                      ElevatedButton(
                        onPressed: _cargarProdutos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _produtos.isEmpty
                  ? const Center(child: Text('Non hai produtos no catálogo'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _produtos.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) {
                        final p = _produtos[i];
                        return ListTile(
                          // Icono do produto
                          leading: const Icon(Icons.inventory_2, color: Colors.blue),
                          // Nome e código QR
                          title: Text(p['nome'] ?? ''),
                          subtitle: Text('QR: ${p['codigo_qr']}  ·  Stock: ${p['stock']}'),
                          // Prezo á dereita
                          trailing: Text(
                            '${(p['prezo'] as num).toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        );
                      },
                    ),
      // Botón flotante para crear un novo produto
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irCrearProduto,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
    );
  }
}
