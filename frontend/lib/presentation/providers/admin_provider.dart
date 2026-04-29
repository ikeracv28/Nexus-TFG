import 'package:flutter/material.dart';
import '../../data/models/usuario_model.dart';
import '../../data/services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _service = AdminService();

  List<UsuarioModel> _usuarios = [];
  bool _cargando = false;
  String? _error;

  List<UsuarioModel> get usuarios => _usuarios;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarUsuarios() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _usuarios = await _service.listarUsuarios();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> crearUsuario({
    required String dni,
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
    required String rolNombre,
  }) async {
    try {
      final nuevo = await _service.crearUsuario(
        dni: dni,
        nombre: nombre,
        apellidos: apellidos,
        email: email,
        password: password,
        rolNombre: rolNombre,
      );
      _usuarios = [nuevo, ..._usuarios];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleActivo(int id) async {
    try {
      final actualizado = await _service.toggleActivo(id);
      _usuarios = _usuarios.map((u) => u.id == id ? actualizado : u).toList();
      notifyListeners();
    } catch (_) {}
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
