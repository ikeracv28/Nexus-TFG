import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/incidencia_model.dart';
import '../../data/services/incidencia_service.dart';
import '../providers/practica_provider.dart';

class IncidenciasScreen extends StatefulWidget {
  const IncidenciasScreen({super.key});

  @override
  State<IncidenciasScreen> createState() => _IncidenciasScreenState();
}

class _IncidenciasScreenState extends State<IncidenciasScreen> {
  int _tabIndex = 0; // 0=Todas, 1=Abiertas, 2=Resueltas

  @override
  Widget build(BuildContext context) {
    return Consumer<PracticaProvider>(
      builder: (_, provider, __) {
        final all = provider.incidencias;
        final abiertas = all.where((i) => i.estaAbierta).toList();
        final resueltas = all.where((i) => !i.estaAbierta).toList();

        final filtered = switch (_tabIndex) {
          1 => abiertas,
          2 => resueltas,
          _ => all,
        };

        return Scaffold(
          backgroundColor: context.nxt.surfaceAlt,
          body: RefreshIndicator(
            color: NexusColors.primary,
            onRefresh: provider.cargarDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(NexusSizes.space2XL),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PageHeader(onReportar: () => _mostrarBottomSheet(context, provider)),
                      const SizedBox(height: NexusSizes.space2XL),
                      _FilterTabs(
                        selectedIndex: _tabIndex,
                        counts: [all.length, abiertas.length, resueltas.length],
                        onChanged: (i) => setState(() => _tabIndex = i),
                      ),
                      const SizedBox(height: NexusSizes.spaceLG),
                      _IncidenciasList(
                        incidencias: filtered,
                        onRefresh: provider.cargarDashboard,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarBottomSheet(BuildContext context, PracticaProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.nxt.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(NexusSizes.radiusLG)),
      ),
      builder: (_) => _ReportarIncidenciaSheet(onReportado: provider.cargarDashboard),
    );
  }
}

// ─── Cabecera ─────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final VoidCallback onReportar;
  const _PageHeader({required this.onReportar});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Centro de Incidencias',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.nxt.ink,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gestiona y revisa el estado de tus reportes técnicos.',
                style: NexusText.caption,
              ),
            ],
          ),
        ),
        const SizedBox(width: NexusSizes.spaceLG),
        FilledButton.icon(
          onPressed: onReportar,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Reportar Incidencia'),
          style: FilledButton.styleFrom(
            backgroundColor: NexusColors.danger,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }
}

// ─── Pestañas filtro ──────────────────────────────────────────────────────────

class _FilterTabs extends StatelessWidget {
  final int selectedIndex;
  final List<int> counts;
  final ValueChanged<int> onChanged;

  const _FilterTabs({
    required this.selectedIndex,
    required this.counts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Todas', 'Abiertas', 'Resueltas'];
    return Container(
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border.all(color: context.nxt.border, width: NexusSizes.borderWidth),
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selectedIndex == i ? NexusColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(NexusSizes.radiusSM),
                ),
                child: Text(
                  '${labels[i]} (${counts[i]})',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: selectedIndex == i ? Colors.white : context.nxt.inkSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Lista incidencias ────────────────────────────────────────────────────────

class _IncidenciasList extends StatelessWidget {
  final List<Incidencia> incidencias;
  final VoidCallback onRefresh;

  const _IncidenciasList({required this.incidencias, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (incidencias.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: NexusSizes.space3XL),
        decoration: BoxDecoration(
          color: context.nxt.surface,
          border: Border.all(color: context.nxt.border, width: NexusSizes.borderWidth),
          borderRadius: BorderRadius.circular(NexusSizes.radiusLG),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, size: 36, color: context.nxt.inkTertiary),
              const SizedBox(height: NexusSizes.spaceMD),
              Text('Sin incidencias', style: NexusText.small.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: NexusSizes.spaceXS),
              Text('No hay incidencias en esta categoría.', style: NexusText.caption),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border.all(color: context.nxt.border, width: NexusSizes.borderWidth),
        borderRadius: BorderRadius.circular(NexusSizes.radiusLG),
      ),
      child: Column(
        children: [
          for (int i = 0; i < incidencias.length; i++) ...[
            _IncidenciaRow(incidencias[i]),
            if (i < incidencias.length - 1)
              Divider(height: 1, thickness: NexusSizes.borderWidth, color: context.nxt.border),
          ],
        ],
      ),
    );
  }
}

class _IncidenciaRow extends StatelessWidget {
  final Incidencia incidencia;
  const _IncidenciaRow(this.incidencia);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color;
    final Color bgColor;
    if (incidencia.estaAbierta) {
      color = isDark ? const Color(0xFFFF8A80) : NexusColors.danger;
      bgColor = isDark ? const Color(0xFF4A1515) : NexusColors.dangerLight;
    } else {
      color = isDark ? const Color(0xFF86C962) : NexusColors.success;
      bgColor = isDark ? const Color(0xFF1E3D10) : NexusColors.successLight;
    }
    final label = incidencia.estaAbierta ? 'Abierta' : 'Resuelta';

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: NexusSizes.space2XL, vertical: NexusSizes.spaceLG),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(NexusSizes.radiusSM),
            ),
            child: Icon(
              incidencia.estaAbierta ? Icons.warning_amber_outlined : Icons.check_circle_outline,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: NexusSizes.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (incidencia.tipo != null)
                      Text(
                        '${incidencia.tipo} · ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: context.nxt.inkTertiary,
                        ),
                      ),
                    Text(
                      _fmtDate(incidencia.fechaCreacion),
                      style: NexusText.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  incidencia.descripcion,
                  style: NexusText.small,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: NexusSizes.spaceMD),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(NexusSizes.radiusFull),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    const m = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${d.day} ${m[d.month - 1]}, ${d.year}';
  }
}

// ─── Modal reportar ──────────────────────────────────────────────────────────

class _ReportarIncidenciaSheet extends StatefulWidget {
  final VoidCallback onReportado;
  const _ReportarIncidenciaSheet({required this.onReportado});

  @override
  State<_ReportarIncidenciaSheet> createState() => _ReportarIncidenciaSheetState();
}

class _ReportarIncidenciaSheetState extends State<_ReportarIncidenciaSheet> {
  static const _tipos = ['ACCESO', 'AUSENCIA', 'COMPORTAMIENTO', 'ACCIDENTE', 'OTROS'];
  String _tipoSeleccionado = 'ACCESO';
  final _descripcionController = TextEditingController();
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        NexusSizes.space2XL, NexusSizes.space2XL,
        NexusSizes.space2XL, NexusSizes.space2XL + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Reportar incidencia', style: NexusText.heading3),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, size: 20, color: context.nxt.inkSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: NexusSizes.spaceLG),
          Text('Tipo', style: NexusText.caption),
          const SizedBox(height: NexusSizes.spaceSM),
          DropdownButtonFormField<String>(
            value: _tipoSeleccionado,
            decoration: _inputDeco(),
            items: _tipos.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _tipoSeleccionado = v!),
          ),
          const SizedBox(height: NexusSizes.spaceLG),
          Text('Descripción', style: NexusText.caption),
          const SizedBox(height: NexusSizes.spaceSM),
          TextFormField(
            controller: _descripcionController,
            maxLines: 4,
            decoration: _inputDeco(hint: 'Describe lo que ha ocurrido...'),
            style: NexusText.small,
          ),
          if (_error != null) ...[
            const SizedBox(height: NexusSizes.spaceMD),
            Text(_error!, style: NexusText.caption.copyWith(color: NexusColors.danger)),
          ],
          const SizedBox(height: NexusSizes.space2XL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _enviando ? null : _enviar,
              style: ElevatedButton.styleFrom(
                backgroundColor: NexusColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: NexusSizes.spaceMD),
              ),
              child: _enviando
                  ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Enviar reporte'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco({String? hint}) => InputDecoration(
    hintText: hint,
    hintStyle: NexusText.caption,
    filled: true,
    fillColor: context.nxt.surfaceAlt,
    contentPadding: const EdgeInsets.all(NexusSizes.spaceMD),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
      borderSide: BorderSide(color: context.nxt.border, width: NexusSizes.borderWidth),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
      borderSide: BorderSide(color: context.nxt.border, width: NexusSizes.borderWidth),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
      borderSide: const BorderSide(color: NexusColors.primary, width: 1),
    ),
  );

  Future<void> _enviar() async {
    final descripcion = _descripcionController.text.trim();
    if (descripcion.length < 10) {
      setState(() => _error = 'La descripción debe tener al menos 10 caracteres.');
      return;
    }
    setState(() { _enviando = true; _error = null; });
    try {
      await IncidenciaService().reportar(tipo: _tipoSeleccionado, descripcion: descripcion);
      if (mounted) {
        Navigator.pop(context);
        widget.onReportado();
      }
    } catch (e) {
      setState(() { _enviando = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }
}
