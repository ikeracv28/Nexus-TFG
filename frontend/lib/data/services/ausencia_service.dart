import 'package:dio/dio.dart';
import '../../core/config/api_client.dart';
import '../models/ausencia_model.dart';

class AusenciaService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Ausencia>> getAusenciasPorPractica(int practicaId) async {
    try {
      final response = await _apiClient.dio.get('/ausencias/practica/$practicaId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Ausencia.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Error al obtener ausencias: ${e.message}');
    }
  }

  Future<Ausencia> registrar({
    required int practicaId,
    required DateTime fecha,
    required String motivo,
  }) async {
    try {
      final response = await _apiClient.dio.post('/ausencias', data: {
        'practicaId': practicaId,
        'fecha': '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}',
        'motivo': motivo,
      });
      return Ausencia.fromJson(response.data);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Error al registrar ausencia';
      throw Exception(msg);
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _apiClient.dio.delete('/ausencias/$id');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Error al eliminar ausencia';
      throw Exception(msg);
    }
  }
}
