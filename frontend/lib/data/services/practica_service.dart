import 'package:dio/dio.dart';
import '../../core/config/api_client.dart';
import '../models/practica_model.dart';

/**
 * Servicio encargado de la comunicación con los endpoints de Prácticas.
 */
class PracticaService {
  final ApiClient _apiClient = ApiClient();

  /**
   * Obtiene las prácticas asociadas a un alumno específico.
   * Utiliza el endpoint: GET /api/v1/practicas/alumno/{alumnoId}
   */
  Future<List<Practica>> getPracticasPorAlumno(int alumnoId) async {
    try {
      final response = await _apiClient.dio.get('/practicas/alumno/$alumnoId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Practica.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      // Propagar el error o gestionar localmente
      throw Exception('Error al obtener prácticas: ${e.message}');
    }
  }

  /**
   * Obtiene los detalles de una práctica por su ID.
   * Utiliza el endpoint: GET /api/v1/practicas/{id}
   */
  Future<Practica> getPracticaPorId(int id) async {
    try {
      final response = await _apiClient.dio.get('/practicas/$id');
      
      if (response.statusCode == 200) {
        return Practica.fromJson(response.data);
      }
      throw Exception('Práctica no encontrada');
    } on DioException catch (e) {
      throw Exception('Error al obtener detalle de práctica: ${e.message}');
    }
  }
}
