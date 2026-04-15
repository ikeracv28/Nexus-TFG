import 'package:flutter/material.dart';
import '../../data/models/practica_model.dart';
import '../../data/services/practica_service.dart';

/**
 * Gestor de estado para las prácticas del usuario.
 */
class PracticaProvider extends ChangeNotifier {
  final PracticaService _practicaService = PracticaService();

  List<Practica> _practicas = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Practica> get practicas => _practicas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /**
   * Carga las prácticas de un alumno específico.
   */
  Future<void> cargarPracticas(int alumnoId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _practicas = await _practicaService.getPracticasPorAlumno(alumnoId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Obtiene la práctica activa (si existe).
   */
  Practica? get practicaActiva {
    if (_practicas.isEmpty) return null;
    return _practicas.firstWhere(
      (p) => p.estado == 'ACTIVA',
      orElse: () => _practicas.first, // Por ahora devolvemos la primera si no hay activa
    );
  }
}
