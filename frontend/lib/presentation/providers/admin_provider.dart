import 'package:flutter/material.dart';
import '../../data/models/usuario_model.dart';
import '../../data/models/practica_model.dart';
import '../../data/models/empresa_model.dart';
import '../../data/services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _service = AdminService();

  // Usuarios
  List<UsuarioModel> _usuarios = [];
  // Prácticas
  List<Practica> _practicas = [];
  // Empresas
  List<EmpresaModel> _empresas = [];

  bool _cargando = false;
  String? _error;

  List<UsuarioModel> get usuarios => _usuarios;
  List<Practica> get practicas => _practicas;
  List<EmpresaModel> get empresas => _empresas;
  bool get cargando => _cargando;
  String? get error => _error;

  // Stats calculados desde las prácticas
  int get totalPracticas => _practicas.length;
  int get practicasActivas => _practicas.where((p) => p.estado == 'ACTIVA').length;
  int get practicasBorrador => _practicas.where((p) => p.estado == 'BORRADOR').length;
  int get practicasFinalizadas => _practicas.where((p) => p.estado == 'FINALIZADA').length;

  // Filtros por rol para los dropdowns de creación de práctica
  List<UsuarioModel> get alumnos =>
      _usuarios.where((u) => u.roles.contains('ROLE_ALUMNO')).toList();
  List<UsuarioModel> get tutoresCentro =>
      _usuarios.where((u) => u.roles.contains('ROLE_TUTOR_CENTRO')).toList();
  List<UsuarioModel> get tutoresEmpresa =>
      _usuarios.where((u) => u.roles.contains('ROLE_TUTOR_EMPRESA')).toList();

  Future<void> cargarTodo() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.listarUsuarios(),
        _service.listarPracticas(),
        _service.listarEmpresas(),
      ]);
      _usuarios = results[0] as List<UsuarioModel>;
      _practicas = results[1] as List<Practica>;
      _empresas = results[2] as List<EmpresaModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarUsuarios() async {
    try {
      _usuarios = await _service.listarUsuarios();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
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
        dni: dni, nombre: nombre, apellidos: apellidos,
        email: email, password: password, rolNombre: rolNombre,
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

  Future<bool> crearPractica({
    required String codigo,
    required int alumnoId,
    required int tutorCentroId,
    required int tutorEmpresaId,
    required int empresaId,
    required String fechaInicio,
    required String fechaFin,
    required int horasTotales,
  }) async {
    try {
      final nueva = await _service.crearPractica(
        codigo: codigo, alumnoId: alumnoId, tutorCentroId: tutorCentroId,
        tutorEmpresaId: tutorEmpresaId, empresaId: empresaId,
        fechaInicio: fechaInicio, fechaFin: fechaFin, horasTotales: horasTotales,
      );
      _practicas = [nueva, ..._practicas];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}
