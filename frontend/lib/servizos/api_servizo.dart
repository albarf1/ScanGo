import 'package:http/http.dart' as http;
import 'dart:convert';

/// Servizo de comunicación co backend, con todos os métodos para chamar aos endpoints da API

class ApiServizo {
  /// URL base do servidor backend
  static const String baseUrl = 'http://127.0.0.1:8001';

  /// Escanea un producto polo QR,chamada GET a /produtos/escanear/{codigoQr} e retorna os datos do producto se existe
  static Future<Map<String, dynamic>> escanearProduto(String codigoQr) async {
    try {
      // Fai a chamada GET ao endpoint de escaneo
      final response = await http.get(
        Uri.parse('$baseUrl/produtos/escanear/$codigoQr'),
      );

      // Si a resposta é correcta (código 200), decodifica e retorna
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Produto non atopado');
      }
    } catch (e) {
      throw Exception('Error ao escanear: $e');
    }
  }

  /// Obtén os detalles dun producto polo ID,chamada GET a /produtos/id/{idProduto} e volve a información do producto
  static Future<Map<String, dynamic>> obterProduto(int idProduto) async {
    try {
      // Fai a chamada GET ao endpoint de busca por ID
      final response = await http.get(
        Uri.parse('$baseUrl/produtos/id/$idProduto'),
      );

      // Si a resposta é correcta, decodifica e retorna
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Produto non atopado');
      }
    } catch (e) {
      throw Exception('Error ao obter produto: $e');
    }
  }

  /// Lista todos os productos dispoñibles,chamada GET a /produtos/ e retorna a lista con todos os productos
  static Future<List<dynamic>> listarProductos() async {
    try {
      // Fai a chamada GET ao endpoint de listado
      final response = await http.get(
        Uri.parse('$baseUrl/produtos/'),
      );

      // Si a resposta é correcta, decodifica e retorna a lista
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao listar productos');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Engade un producto ao carrito do usuario,chamada POST a /carrito/engadir e recibe usuario_id, codigo_qr e cantidade
  static Future<void> engadirAoCarrito(
    int usuarioId,
    String codigoQr, {
    int cantidad = 1,
  }) async {
    try {
      // Fai a chamada POST con os datos do producto a engadir
      final response = await http.post(
        Uri.parse('$baseUrl/carrito/engadir'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': usuarioId,       // ID do usuario
          'codigo_qr': codigoQr,         // Código QR do producto
          'cantidad': cantidad,           // Cantidad a engadir (por defecto 1)
        }),
      );

      // Se non é 201, hai un erro
      if (response.statusCode != 201) {
        throw Exception('Error ao engadir ao carrito');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtén o carrito activo do usuario,chamada GET a /carrito/ver/{usuarioId} e retorna os productos no carrito, lineas e total
  static Future<Map<String, dynamic>> verCarrito(int usuarioId) async {
    try {
      // Fai a chamada GET para obter o carrito
      final response = await http.get(
        Uri.parse('$baseUrl/carrito/ver/$usuarioId'),
      );

      // Si a resposta é correcta, decodifica e retorna
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        // Se non hai carrito activo, retorna un carrito vacio
        return {
          'id': -1,
          'lineas': [],
          'total': 0.0,
        };
      } else {
        throw Exception('Error ao obter carrito');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Inicia sesión, chamada POST a /auth/login. Retorna os datos do usuario se as credenciais son correctas.
  /// Lanza excepción con mensaxe se as credenciais son incorrectas 
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
        return jsonDecode(response.body);
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

  /// Rexistra un novo usuario, chamada POST a /auth/register. Retorna os datos do usuario creado.
  /// Lanza se o correo xa existe ou hai erro de validación 
  static Future<Map<String, dynamic>> registrarse(
    String nome,
    String email,
    String contrasinal,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'contrasinal': contrasinal,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 409) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'O correo xa está rexistrado');
      } else if (response.statusCode == 422) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'Datos non válidos');
      } else {
        throw Exception('Erro no servidor. Inténtao máis tarde.');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Sen conexión co servidor');
    }
  }

  /// Obtén a información do usuario,chamada GET a /usuarios/{usuarioId} e retorna os datos do usuario
  static Future<Map<String, dynamic>> obterUsuario(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$usuarioId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Usuario non atopado');
      }
    } catch (e) {
      throw Exception('Error ao obter usuario: $e');
    }
  }

  /// Crea un novo produto no catálogo, chamada POST a /produtos/
  /// Lanza excepción se o código QR xa existe (409) ou os datos non son válidos (422)
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'prezo': prezo,
          'stock': stock,
          'codigo_qr': codigoQr,
          'descripcion': descripcion,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 409) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'O código QR xa está en uso');
      } else if (response.statusCode == 422) {
        final corpo = jsonDecode(response.body);
        throw Exception(corpo['detail'] ?? 'Datos non válidos');
      } else {
        throw Exception('Erro no servidor. Inténtao máis tarde.');
      }
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('Sen conexión co servidor');
    }
  }
}
