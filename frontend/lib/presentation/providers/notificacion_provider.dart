import 'package:flutter/foundation.dart';
import '../../data/services/notificacion_service.dart';

class NotificacionProvider extends ChangeNotifier {
  final _service = NotificacionService();

  List<NotificacionItem> _items = [];
  int _noLeidas = 0;
  bool _cargando = false;

  List<NotificacionItem> get items => _items;
  int get noLeidas => _noLeidas;
  bool get cargando => _cargando;

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();
    try {
      _items = await _service.listar();
      _noLeidas = _items.where((n) => !n.leida).length;
    } catch (_) {
      _items = [];
      _noLeidas = 0;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> marcarLeida(int id) async {
    try {
      await _service.marcarLeida(id);
      _items = _items.map((n) => n.id == id
          ? NotificacionItem(
              id: n.id,
              tipo: n.tipo,
              mensaje: n.mensaje,
              leida: true,
              fechaCreacion: n.fechaCreacion)
          : n).toList();
      _noLeidas = _items.where((n) => !n.leida).length;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> marcarTodasLeidas() async {
    try {
      await _service.marcarTodasLeidas();
      _items = _items.map((n) => NotificacionItem(
              id: n.id,
              tipo: n.tipo,
              mensaje: n.mensaje,
              leida: true,
              fechaCreacion: n.fechaCreacion))
          .toList();
      _noLeidas = 0;
      notifyListeners();
    } catch (_) {}
  }
}
