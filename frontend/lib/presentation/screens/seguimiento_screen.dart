import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/practica_provider.dart';
import '../../data/services/seguimiento_service.dart';

class SeguimientoScreen extends StatefulWidget {
  const SeguimientoScreen({super.key});

  @override
  State<SeguimientoScreen> createState() => _SeguimientoScreenState();
}

class _SeguimientoScreenState extends State<SeguimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();
  final _horasCtrl = TextEditingController();
  final _seguimientoService = SeguimientoService();

  // Tipo: 'DIARIO' o 'SEMANAL'
  String _tipo = 'DIARIO';

  // Para DIARIO: día concreto. Para SEMANAL: lunes de la semana.
  DateTime _fechaSeleccionada = DateTime.now();

  bool _enviando = false;

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _horasCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Selección de fecha
  // ──────────────────────────────────────────────

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: NexusColors.primary,
            onPrimary: Colors.white,
            surface: NexusColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        // Para SEMANAL normalizamos al lunes de la semana elegida
        _fechaSeleccionada = _tipo == 'SEMANAL'
            ? picked.subtract(Duration(days: picked.weekday - 1))
            : picked;
      });
    }
  }

  // ──────────────────────────────────────────────
  // Envío del formulario
  // ──────────────────────────────────────────────

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<PracticaProvider>(context, listen: false);
    final practica = provider.practicaActiva;
    if (practica == null) {
      _mostrarError('No tienes una practica activa asignada.');
      return;
    }

    setState(() => _enviando = true);
    try {
      final nuevo = await _seguimientoService.registrar(
        practicaId: practica.id,
        fechaRegistro: _fechaSeleccionada,
        horasRealizadas: double.parse(_horasCtrl.text.trim().replaceAll(',', '.')),
        descripcion: _descripcionCtrl.text.trim(),
        tipo: _tipo,
      );
      provider.agregarSeguimiento(nuevo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Parte registrado correctamente'),
            backgroundColor: NexusColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NexusSizes.radiusMD)),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) _mostrarError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: NexusColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NexusSizes.radiusMD)),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Helpers de display
  // ──────────────────────────────────────────────

  String get _labelFecha {
    if (_tipo == 'SEMANAL') {
      final lunes = _fechaSeleccionada;
      final viernes = lunes.add(const Duration(days: 4));
      final fmtD = DateFormat('d MMM', 'es_ES');
      final fmtDY = DateFormat('d MMM yyyy', 'es_ES');
      return 'Semana del ${fmtD.format(lunes)} al ${fmtDY.format(viernes)}';
    }
    return DateFormat('dd/MM/yyyy').format(_fechaSeleccionada);
  }

  String get _hintHoras =>
      _tipo == 'SEMANAL' ? 'Ej. 35 (total semana)' : 'Ej. 8';

  String get _validatorMaxHoras =>
      _tipo == 'SEMANAL' ? 'Introduce un valor entre 0.5 y 50' : 'Introduce un valor entre 0.5 y 24';

  double get _maxHoras => _tipo == 'SEMANAL' ? 50.0 : 24.0;

  // ──────────────────────────────────────────────
  // UI
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.nxt.surfaceAlt,
      appBar: AppBar(
        backgroundColor: context.nxt.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Registrar seguimiento', style: NexusText.heading3),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, thickness: 0.5, color: context.nxt.border),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(NexusSizes.space2XL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Toggle DIARIO / SEMANAL ────────────
                      _FieldLabel('Tipo de registro'),
                      const SizedBox(height: NexusSizes.spaceSM),
                      _TipoToggle(
                        selected: _tipo,
                        onChanged: (t) => setState(() {
                          _tipo = t;
                          // Renormalizamos la fecha al cambiar de tipo
                          if (t == 'SEMANAL') {
                            _fechaSeleccionada = _fechaSeleccionada.subtract(
                                Duration(days: _fechaSeleccionada.weekday - 1));
                          }
                        }),
                      ),
                      const SizedBox(height: NexusSizes.spaceLG),

                      // ── Fecha / Semana ─────────────────────
                      _FieldLabel(_tipo == 'SEMANAL' ? 'Semana' : 'Fecha del parte'),
                      const SizedBox(height: NexusSizes.spaceSM),
                      _FechaPicker(
                        label: _labelFecha,
                        icon: _tipo == 'SEMANAL'
                            ? Icons.date_range_outlined
                            : Icons.calendar_today_outlined,
                        onTap: _seleccionarFecha,
                      ),
                      const SizedBox(height: NexusSizes.spaceLG),

                      // ── Horas ──────────────────────────────
                      _FieldLabel(_tipo == 'SEMANAL'
                          ? 'Horas totales de la semana'
                          : 'Horas realizadas'),
                      const SizedBox(height: NexusSizes.spaceSM),
                      TextFormField(
                        controller: _horasCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: _hintHoras,
                          suffixText: 'h',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Introduce las horas realizadas';
                          }
                          final horas = double.tryParse(
                              value.trim().replaceAll(',', '.'));
                          if (horas == null || horas < 0.5 || horas > _maxHoras) {
                            return _validatorMaxHoras;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: NexusSizes.spaceLG),

                      // ── Descripción ────────────────────────
                      _FieldLabel('Descripcion de las tareas'),
                      const SizedBox(height: NexusSizes.spaceSM),
                      TextFormField(
                        controller: _descripcionCtrl,
                        maxLines: 5,
                        maxLength: 1000,
                        decoration: InputDecoration(
                          hintText: _tipo == 'SEMANAL'
                              ? 'Resume las actividades realizadas durante toda la semana...'
                              : 'Describe brevemente las tareas realizadas durante este periodo...',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La descripcion es obligatoria';
                          }
                          if (value.trim().length < 10) {
                            return 'Minimo 10 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: NexusSizes.space2XL),

                      // ── Botón envío ────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _enviando ? null : _enviar,
                          child: _enviando
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Registrar parte'),
                        ),
                      ),
                      const SizedBox(height: NexusSizes.spaceMD),

                      // ── Info ───────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(NexusSizes.spaceMD),
                        decoration: BoxDecoration(
                          color: NexusColors.primaryLight,
                          borderRadius:
                              BorderRadius.circular(NexusSizes.radiusMD),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline,
                                size: 15, color: NexusColors.primary),
                            const SizedBox(width: NexusSizes.spaceSM),
                            Expanded(
                              child: Text(
                                _tipo == 'SEMANAL'
                                    ? 'El parte semanal agrupa todas las horas de la semana en un solo registro. Quedara pendiente de validacion por tu tutor de empresa.'
                                    : 'El parte quedara pendiente de validacion por tu tutor de empresa. Una vez validado, tu tutor del centro dara el visto bueno final.',
                                style: NexusText.caption.copyWith(
                                    color: NexusColors.primaryText),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────────────

class _TipoToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _TipoToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleBtn(
          label: 'Diario',
          icon: Icons.today_outlined,
          active: selected == 'DIARIO',
          onTap: () => onChanged('DIARIO'),
        ),
        const SizedBox(width: 8),
        _ToggleBtn(
          label: 'Semanal',
          icon: Icons.date_range_outlined,
          active: selected == 'SEMANAL',
          onTap: () => onChanged('SEMANAL'),
        ),
      ],
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ToggleBtn(
      {required this.label,
      required this.icon,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? NexusColors.primary : context.nxt.surface,
          borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
          border: Border.all(
            color: active ? NexusColors.primary : context.nxt.border,
            width: NexusSizes.borderWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: active ? Colors.white : context.nxt.inkSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: NexusText.small.copyWith(
                color: active ? Colors.white : context.nxt.inkSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: NexusText.small.copyWith(fontWeight: FontWeight.w500));
  }
}

class _FechaPicker extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _FechaPicker(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.nxt.surface,
          border: Border.all(
              color: context.nxt.border, width: NexusSizes.borderWidth),
          borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: context.nxt.inkSecondary),
            const SizedBox(width: NexusSizes.spaceSM),
            Expanded(child: Text(label, style: NexusText.small)),
            Icon(Icons.keyboard_arrow_down,
                size: 16, color: context.nxt.inkSecondary),
          ],
        ),
      ),
    );
  }
}
