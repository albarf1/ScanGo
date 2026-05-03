import 'package:flutter/material.dart';
import '../servizos/api_servizo.dart';
import 'pantalla_crear_produto.dart';
import 'pantalla_editar_produto.dart';

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
    _cargarProdutos();
  }

  /// Navega á pantalla de editar produto e recarga ao volver
  Future<void> _irEditarProduto(Map<String, dynamic> produto) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PantallaEditarProduto(produto: produto)),
    );
    _cargarProdutos();
  }

  /// Mostra diálogo de confirmación e elimina o produto
  Future<void> _confirmarEliminar(Map<String, dynamic> produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar produto'),
        content: Text('¿Seguro que queres eliminar "${produto['nome']}"? Esta acción non se pode desfacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await ApiServizo.eliminarProduto(produto['id'] as int);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      _cargarProdutos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
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
                      Text(_erroMensaxe!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
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
                          leading: const Icon(Icons.inventory_2, color: Colors.blue),
                          title: Text(p['nome'] ?? ''),
                          subtitle: Text('QR: ${p['codigo_qr']}  ·  Stock: ${p['stock']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Prezo
                              Text(
                                '${(p['prezo'] as num).toStringAsFixed(2)} €',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              // Botón editar
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                tooltip: 'Editar',
                                onPressed: () => _irEditarProduto(Map<String, dynamic>.from(p)),
                              ),
                              // Botón eliminar
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: 'Eliminar',
                                onPressed: () => _confirmarEliminar(p),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irCrearProduto,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
    );
  }
}
