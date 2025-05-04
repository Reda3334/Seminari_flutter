import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart'; //importar el modelo User

class AuthService {
  // Crear una instancia única de AuthService
  static final AuthService _instance = AuthService._internal();

  // Constructor privado
  AuthService._internal();

  // Factory para devolver la instancia única
  factory AuthService() {
    return _instance;
  }

  bool isLoggedIn = false; // Variable para almacenar el estado de autenticación
  User? _currentUser; // Variable para almacenar el usuario logueado

  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9000/api/users';
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:9000/api/users';
    } else {
      return 'http://localhost:9000/api/users';
    }
  }

  //fetch data
  Future<void> fetchUserData(String userId) async {
  final url = Uri.parse('$_baseUrl/$userId'); // Endpoint para obtener los datos del usuario

  try {
    print("Enviant solicitud GET a: $url");
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    print("Resposta rebuda amb codi: ${response.statusCode}");
    print("Cos de la resposta: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null) {
        // Actualizar _currentUser con los datos completos del usuario
        _currentUser = User.fromJson(data);
        print("Dades de l'usuari actualitzades: $_currentUser");
      } else {
        print("Error: La resposta no conté dades de l'usuari.");
      }
    } else {
      print("Error: No s'ha pogut obtenir les dades de l'usuari.");
    }
  } catch (e) {
    print("Error al fer la solicitud: $e");
  }
}

  //login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    final body = json.encode({'email': email, 'password': password});

    try {
      print("enviant solicitud post a: $url");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("Resposta rebuda amb codi: ${response.statusCode}");
      print("Cos de la resposta: ${response.body}");

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['id'] != null && data['email'] != null) {
            // Crear un objeto User básico con los datos de la respuesta
            _currentUser = User(
              id: data['id'],
              name: '', // Nombre vacío por defecto
              age: 0, // Edad por defecto
              email: data['email'],
              password: '', // Contraseña vacía por defecto
            );
            isLoggedIn = true;

            // Obtener los datos completos del usuario
            await fetchUserData(data['id']);

            return data;
          } else {
            print("Error: La resposta no conté dades suficients de l'usuari.");
            return {'error': 'La resposta no conté dades suficients del usuari.'};
          }
        } else {
        return {'error': 'email o contrasenya incorrectes'};
      }
    } catch (e) {
      print("Error al fer la solicitud: $e");
      return {'error': 'Error de connexió'};
    }
  }
  // Obtener el usuario logueado
  User? getCurrentUser() {
    return _currentUser;
  }

  void logout() {
    isLoggedIn = false; // Cambia el estado de autenticación a no autenticado
     _currentUser = null; // Limpiar el usuario logueado
    print("Sessió tancada");
  }
}
