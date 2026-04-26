import 'package:flutter/material.dart';
import '../../data/models/practica_model.dart';
import '../../data/models/seguimiento_model.dart';
import '../../data/services/practica_tutor_service.dart';
import '../../data/services/seguimiento_service.dart';

class TutorEmpresaProvider extends ChangeNotifier {
  final PracticaTutorService _practicaService = PracticaTutorService();
  final SeguimientoService _seguimientoService = SeguimientoService();

  List<Practica> _practicas = [];
  Map<int, List<Seguimiento>> _todosSeguimientosPorPractica = {};
  bool _isLoading = false;
  String? _error;

  List<Practica> get practicas => _practicas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Seguimiento> get todosPendientes => _todosSeguimientosPorPractica.values
      .expand((l) => l)
      .where((s) => s.estado == 'PENDIENTE_EMPRESA')
      .toList();

  int get totalPartes => _todosSeguimientosPorPractica.values
      .expand((l) => l)
      .length;

  int get totalHoras => _todosSeguimientosPorPractica.values
      .expand((l) => l)
      .fold(0, (sum, s) => sum + s.horasRealizadas);

  int get totalValidados => _todosSeguimientosPorPractica.values
      .expand((l) => l)
      .where((s) => s.estado == 'PENDIENTE_CENTRO' || s.estado == 'COMPLETADO')
      .length;

  Future<void> cargar() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _practicas = await _practicaService.getMisPracticasComoTutorEmpresa();
      _todosSeguimientosPorPractica = {};

      for (final practica in _practicas) {
        final todos =
            await _seguimientoService.getSeguimientosPorPractica(practica.id);
        _todosSeguimientosPorPractica[practica.id] = todos;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> validar(int seguimientoId) async {
    try {
      await _seguimientoService.validarEmpresa(seguimientoId, 'PENDIENTE_CENTRO');
      await cargar();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rechazar(int seguimientoId, String motivo) async {
    try {
      await _seguimientoService.validarEmpresa(
        seguimientoId,
        'RECHAZADO',
        motivo: motivo,
      );
      await cargar();
      return true;
    } catch (_) {
      return false;
    }
  }

  Practica? practicaDe(int practicaId) {
    try {
      return _practicas.firstWhere((p) => p.id == practicaId);
    } catch (_) {
      return null;
    }
  }
}
