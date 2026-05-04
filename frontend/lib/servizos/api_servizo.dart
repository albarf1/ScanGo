import 'package:http/http.dart' as http;
import 'dart:convert';

/// Servizo de comunicación co backend, con todos os métodos para chamar aos endpoints da API

class ApiServizo {
  /// URL base do servidor backend
  static const String baseUrl = 'http://127.0.0.1:8000';

  /// Token JWT gardado tras o login, envíase en cada petición protexida
  static String? _token;

  /// Garda o token JWT recibido tras o login
  static void setToken(String token) => _token = token;

  /// Elimina o token ao pechar sesión
  static void borrarToken() => _token = null;

  /// Cabeceiras con autenticación Bearer para rutas protexidas
  static Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// Cabeceiras só con autenticación, sen Content-Type (para GET e DELETE)
  static Map<String, String> get _authHeadersGet => {
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// Escanea un producto polo QR, chamada GET a /produtos/escanear/{codigoQr}
  static Future<Map<String, dynamic>> escanearProduto(String codigoQr) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produtos/escanear/$codigoQr'),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Produto non atopado');
    } catch (e) {
      throw Exception('Error ao escanear: $e');
    }
  }

  /// Obtén os detalles dun producto polo ID, chamada GET a /produtos/id/{idProduto}
  static Future<Map<String, dynamic>> obterProduto(int idProduto) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/produtos/id/$idProduto'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Produto non atopado');
    } catch (e) {
      throw Exception('Error ao obter produto: $e');
    }
  }

  /// Lista todos os productos dispoñibles, chamada GET a /produtos/
  static Future<List<dynamic>> listarProductos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/produtos/'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Erro ao listar productos');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Engade un producto ao carrito do usuario, chamada POST a /carrito/engadir
  static Future<void> engadirAoCarrito(
    int usuarioId,
    String codigoQr, {
    int cantidad = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/carrito/engadir'),
        headers: _authHeaders,
        body: jsonEncode({
          'usuario_id': usuarioId,
          'codigo_qr': codigoQr,
          'cantidad': cantidad,
        }),
      );
      if (response.statusCode != 201) throw Exception('Error ao engadir ao carrito');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtén o carrito activo do usuario, chamada GET a /carrito/ver/{usuarioId}
  static Future<Map<String, dynamic>> verCarrito(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/carrito/ver/$usuarioId'),
        headers: _authHeadersGet,
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      if (response.statusCode == 404) return {'id': -1, 'lineas': [], 'total': 0.0};
      throw Exception('Error ao obter carrito');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Inicia sesión, chamada POST a /auth/login. Garda o token e retorna os datos do usuario.
  static Future<Map<String, dynamic>> iniciarSesion(
    String email,
    String contrasinal,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'contrasinal': contrasinal}),
      );

      if (response.statusCode == 200) {
        final corpo = jsonDecode(response.body);
        // Gardamos o token para as seguintes peticións
        setToken(corpo['access_token'] as String);
        // Devolvemos os datos do usuario
        return corpo['usuario'] as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'Correo ou contrasinal incorrectos');
      } else {
        throw Exception('Erro no servidor. Inténtao máis tarde.');
      }
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('Sen conexión co servidor');
    }
  }

  /// Rexistra un novo usuario, chamada POST a /auth/register
  static Future<Map<String, dynamic>> registrarse(
    String nome,
    String email,
    String contrasinal,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nome': nome, 'email': email, 'contrasinal': contrasinal}),
      );

      if (response.statusCode == 201) return jsonDecode(response.body);
      if (response.statusCode == 409) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'O correo xa está rexistrado');
      }
      if (response.statusCode == 422) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'Datos non válidos');
      }
      throw Exception('Erro no servidor. Inténtao máis tarde.');
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('Sen conexión co servidor');
    }
  }

  /// Finaliza a compra, chamada POST a /carrito/finalizar/{usuarioId}
  static Future<Map<String, dynamic>> finalizarCompra(int usuarioId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/carrito/finalizar/$usuarioId'),
        headers: _authHeaders,
      );
      if (response.statusCode == 201) return jsonDecode(response.body);
      if (response.statusCode == 400) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'O carrito está baleiro');
      }
      if (response.statusCode == 404) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'Non hai carrito activo');
      }
      throw Exception('Erro no servidor. Inténtao máis tarde.');
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('Sen conexión co servidor');
    }
  }

  /// Actualiza a cantidade dun produto no carrito, chamada PUT a /carrito/actualizar
  static Future<void> actualizarCantidade(int usuarioId, String codigoQr, int cantidad) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/carrito/actualizar/$usuarioId/$codigoQr'),
        headers: _authHeaders,
        body: jsonEncode({'cantidad': cantidad}),
      );
      if (response.statusCode != 200) throw Exception('Erro ao actualizar cantidade');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Elimina un produto do carrito, chamada DELETE a /carrito/eliminar
  static Future<void> eliminarDoCarrito(int usuarioId, String codigoQr) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/carrito/eliminar/$usuarioId/$codigoQr'),
        headers: _authHeadersGet,
      );
      if (response.statusCode != 200) throw Exception('Erro ao eliminar do carrito');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtén a información do usuario, chamada GET a /usuarios/{usuarioId}
  static Future<Map<String, dynamic>> obterUsuario(int usuarioId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/usuarios/$usuarioId'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Usuario non atopado');
    } catch (e) {
      throw Exception('Error ao obter usuario: $e');
    }
  }

  /// Edita un produto existente, chamada PUT a /produtos/{id} (só admin)
  static Future<Map<String, dynamic>> editarProduto({
    required int id,
    required String nome,
    required double prezo,
    required int stock,
    required String codigoQr,
    String? descripcion,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/produtos/$id'),
        headers: _authHeaders,
        body: jsonEncode({
          'nome': nome,
          'prezo': prezo,
          'stock': stock,
          'codigo_qr': codigoQr,
          'descripcion': descripcion,
        }),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      if (response.statusCode == 409) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'O código QR xa está en uso');
      }
      if (response.statusCode == 422) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'Datos non válidos');
      }
      throw Exception('Error no servidor. Inténtao máis tarde.');
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('Sen conexión co servidor');
    }
  }

  /// Elimina un produto do catálogo, chamada DELETE a /produtos/{id} (só admin)
  static Future<void> eliminarProduto(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/produtos/$id'),
        headers: _authHeadersGet,
      );
      if (response.statusCode != 204) throw Exception('Error ao eliminar o produto');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Crea un novo produto no catálogo, chamada POST a /produtos/ (só admin)
  static Future<Map<String, dynamic>> crearProduto({
    required String nome,
    required double prezo,
    required int stock,
    required String codigoQr,
    String? descripcion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/produtos/'),
        headers: _authHeaders,
        body: jsonEncode({
          'nome': nome,
          'prezo': prezo,
          'stock': stock,
          'codigo_qr': codigoQr,
          'descripcion': descripcion,
        }),
      );
      if (response.statusCode == 201) return jsonDecode(response.body);
      if (response.statusCode == 409) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'O código QR xa está en uso');
      }
      if (response.statusCode == 422) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'Datos non válidos');
      }
      throw Exception('Erro no servidor. Inténtao máis tarde.');
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('Sen conexión co servidor');
    }
  }
}
