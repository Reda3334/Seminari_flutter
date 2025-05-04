import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/UserService.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    _setLoading(true);
    _setError(null);
    //notifyListeners();

    try {
      _users = await UserService.getUsers();
    } catch (e) {
      _setError('Error loading users: $e');
      _users = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> crearUsuari(String nom, int edat, String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final nouUsuari = User(name: nom, age: edat, email: email,password: password);
      final createdUser = await UserService.createUser(nouUsuari);
      _users.add(nouUsuari);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error creating user: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> eliminarUsuariPerId (String id) async {
    _setLoading(true);
    _setError(null);
    try{
      final success = await UserService.deleteUser(id);
      if (success) {
        _users.removeWhere((user) => user.id == id);
        notifyListeners();
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Error deleting user: $e');
      _setLoading(false);
      return false;
    }
  }
  Future<bool> eliminarUsuari(String name) async {
    _setLoading(true);
    _setError(null);

    try {
      // Trobem l'usuari pel nom
      final userToDelete = _users.firstWhere((user) => user.name == name);
      
      if (userToDelete.id != null) {
        final success = await UserService.deleteUser(userToDelete.id!);
        
        if (success) {
          // Eliminar l'usuari de la llista local
          _users.removeWhere((user) => user.name == name);
          notifyListeners();
        }
        
        _setLoading(false);
        return success;
      } else {
        // Si no té id, eliminar localment
        _users.removeWhere((user) => user.name == name);
        notifyListeners();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError('Error deleting user: $e');
      _setLoading(false);
      return false;
    }
  }
  // Método para editar un usuario
Future<bool> editarUsuari(String userId, String name, int age, String email) async {
  _setLoading(true);
  _setError(null);

  try {
    final updatedUser = User(
      id: userId,
      name: name,
      age: age,
      email: email,
      password: '',
    );

    final updatedUserFromBackend = await UserService.updateUser(userId, updatedUser);

    if (updatedUserFromBackend != null) {
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = updatedUserFromBackend;
        notifyListeners();
      }
      _setLoading(false);
      return true;
    } else {
      _setLoading(false);
      return false;
    }
  } catch (e) {
    _setError('Error updating user: $e');
    _setLoading(false);
    return false;
  }
}

// Método para cambiar la contraseña
Future<bool> canviarContrasenya(String userId, String newPassword) async {
  _setLoading(true);
  _setError(null);

  try {
    final success = await UserService.changePassword(userId, newPassword); // Llama al servicio para cambiar la contraseña
    _setLoading(false);
    return success;
  } catch (e) {
    _setError('Error changing password: $e');
    _setLoading(false);
    return false;
  }
}
}
