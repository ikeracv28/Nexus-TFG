import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/seguimiento_model.dart';
import '../providers/practica_provider.dart';
import 'seguimiento_screen.dart';

class SeguimientosScreen extends StatefulWidget {
  const SeguimientosScreen({super.key});

  @override
  State<SeguimientosScreen> createState() => _SeguimientosScreenState();
}

class _SeguimientosScreenState extends State<SeguimientosScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PracticaProvider>(
      builder: (_, provider, __) {
        final seguimientos = provider.seguimientos;
        final horasCompletadas = provider.horasCompletadas;
        final horasTotales = provider.practicaActiva?.horasTotales ?? 0;
        final pct = horasTotales > 0
            ? (horasCompletadas / horasTotales * 100).round()
            : 0;

        final now = DateTime.now();
        final horasMes = seguimientos
            .where((s) => s.fechaRegistro.year == now.year && s.fechaRegistro.month == now.month)
            .fold(0, (sum, s) => sum + s.horasRealizadas);

        final pendientes = seguimientos
            .where((s) => s.estado == 'PENDIENTE_EMPRESA' || s.estado == 'PENDIENTE_CENTRO')
            .length;

        final filtered = _query.isEmpty
            ? seguimientos
            : seguimientos.where((s) {
                final q = _query.toLowerCase();
                return (s.descripcion ?? '').toLowerCase().contains(q) ||
                    s.estado.toLowerCase().contains(q);
              }).toList();

        return Scaffold(
          backgroundColor: context.nxt.surfaceAlt,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SeguimientoScreen()),
            ).then((_) => provider.cargarDashboard()),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo parte'),
            backgroundColor: NexusColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
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
                      const _PageHeader(),
                      const SizedBox(height: NexusSizes.space2XL),
                      _KpiRow(
                        horasCompletadas: horasCompletadas,
                        horasTotales: horasTotales,
                        pct: pct,
                        horasMes: horasMes,
                        pendientes: pendientes,
                      ),
                      const SizedBox(height: NexusSizes.space2XL),
                      _HistorialCard(
                        seguimientos: filtered,
                        query: _query,
                        searchCtrl: _searchCtrl,
                        onSearch: (v) => setState(() => _query = v),
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
}

// ─── Cabecera de página ────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seguimiento de Horas',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: context.nxt.ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text('Visualiza y gestiona tus partes de trabajo diarios.', style: NexusText.caption),
      ],
    );
  }
}

// ─── KPI Cards ────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  final int horasCompletadas;
  final int horasTotales;
  final int pct;
  final int horasMes;
  final int pendientes;

  const _KpiRow({
    required this.horasCompletadas,
    required this.horasTotales,
    required this.pct,
    required this.horasMes,
    required this.pendientes,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final cards = [
          _KpiCard(
            label: 'TOTAL ACUMULADO',
            icon: Icons.schedule_outlined,
            iconColor: NexusColors.primary,
            iconBg: NexusColors.primaryLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${horasCompletadas}h',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: context.nxt.ink,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('/ $horasTotales objetivo', style: NexusText.caption),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: horasTotales > 0
                        ? (horasCompletadas / horasTotales).clamp(0.0, 1.0)
                        : 0.0,
                    minHeight: 4,
                    backgroundColor: NexusColors.primaryLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(NexusColors.primary),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$pct% Completado', style: NexusText.caption.copyWith(color: NexusColors.primary)),
                    Text('${horasTotales - horasCompletadas}h restantes', style: NexusText.caption),
                  ],
                ),
              ],
            ),
          ),
          _KpiCard(
            label: 'ESTE MES',
            icon: Icons.calendar_month_outlined,
            iconColor: NexusColors.success,
            iconBg: NexusColors.successLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${horasMes}h',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: context.nxt.ink,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Horas registradas este mes.',
                  style: NexusText.caption,
                ),
              ],
            ),
          ),
          _KpiCard(
            label: 'PENDIENTES',
            icon: Icons.error_outline,
            iconColor: NexusColors.danger,
            iconBg: NexusColors.dangerLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pendientes',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: context.nxt.ink,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text('partes por corregir', style: NexusText.caption),
                if (pendientes > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: NexusColors.danger.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(NexusSizes.radiusFull),
                    ),
                    child: const Text(
                      'Revisión requerida',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: NexusColors.danger,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ];

        if (isWide) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  Expanded(child: cards[i]),
                  if (i < cards.length - 1) const SizedBox(width: NexusSizes.spaceLG),
                ],
              ],
            ),
          );
        }
        return Column(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              cards[i],
              if (i < cards.length - 1) const SizedBox(height: NexusSizes.spaceMD),
            ],
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Widget child;

  const _KpiCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NexusSizes.space2XL),
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border.all(color: context.nxt.border, width: NexusSizes.borderWidth),
        borderRadius: BorderRadius.circular(NexusSizes.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: context.nxt.inkTertiary,
                ),
              ),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(NexusSizes.radiusMD)),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: NexusSizes.spaceMD),
          child,
        ],
      ),
    );
  }
}

// ─── Tabla historial ───────────────────────────────────────────────────────────

class _HistorialCard extends StatelessWidget {
  final List<Seguimiento> seguimientos;
  final String query;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;

  const _HistorialCard({
    required this.seguimientos,
    required this.query,
    required this.searchCtrl,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border.all(color: context.nxt.border, width: NexusSizes.borderWidth),
        borderRadius: BorderRadius.circular(NexusSizes.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                NexusSizes.space2XL, NexusSizes.spaceLG, NexusSizes.spaceLG, NexusSizes.spaceLG),
            child: Row(
              children: [
                Text('Historial de Partes',
                    style: NexusText.small.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: onSearch,
                    style: NexusText.small,
                    decoration: InputDecoration(
                      hintText: 'Buscar partes...',
                      hintStyle: NexusText.caption,
                      prefixIcon: Icon(Icons.search, size: 16, color: context.nxt.inkTertiary),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
                        borderSide: BorderSide(color: context.nxt.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
                        borderSide: BorderSide(color: context.nxt.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
                        borderSide: const BorderSide(color: NexusColors.primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: NexusSizes.borderWidth, color: context.nxt.border),
          // Cabecera tabla
          Container(
            color: context.nxt.surfaceAlt,
            padding: const EdgeInsets.symmetric(
                horizontal: NexusSizes.space2XL, vertical: 10),
            child: Row(
              children: [
                _TH('Fecha', flex: 2),
                _TH('Horas', flex: 1),
                _TH('Descripción de Tarea', flex: 5),
                _TH('Estado', flex: 2),
              ],
            ),
          ),
          Divider(height: 1, thickness: NexusSizes.borderWidth, color: context.nxt.border),

          if (seguimientos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: NexusSizes.space3XL),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.list_alt_outlined, size: 32, color: context.nxt.inkTertiary),
                    const SizedBox(height: NexusSizes.spaceMD),
                    Text(
                      query.isEmpty ? 'Aún no has registrado ningún parte' : 'Sin resultados',
                      style: NexusText.small.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
          else
            for (final s in seguimientos) _SeguimientoRow(s),

          Padding(
            padding: const EdgeInsets.fromLTRB(
                NexusSizes.space2XL, NexusSizes.spaceMD, NexusSizes.space2XL, NexusSizes.spaceMD),
            child: Text(
              'Mostrando ${seguimientos.length} registros',
              style: NexusText.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String label;
  final int flex;
  const _TH(this.label, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: context.nxt.inkTertiary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SeguimientoRow extends StatelessWidget {
  final Seguimiento s;
  const _SeguimientoRow(this.s);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.nxt.border, width: NexusSizes.borderWidth)),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: NexusSizes.space2XL, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(_fmtDate(s.fechaRegistro), style: NexusText.small)),
          Expanded(flex: 1, child: Text('${s.horasRealizadas}h', style: NexusText.small)),
          Expanded(
            flex: 5,
            child: Text(
              s.descripcion?.isNotEmpty == true
                  ? s.descripcion!
                  : '${s.horasRealizadas} horas de trabajo',
              style: NexusText.small,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(flex: 2, child: _EstadoBadge(s.estado)),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    const m = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${d.day} ${m[d.month - 1]}, ${d.year}';
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge(this.estado);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color fg;
    Color bg;
    Color dot;
    String label;
    switch (estado) {
      case 'COMPLETADO':
        fg = isDark ? const Color(0xFF86C962) : NexusColors.successText;
        bg = isDark ? const Color(0xFF1E3D10) : NexusColors.successLight;
        dot = isDark ? const Color(0xFF86C962) : NexusColors.success; label = 'Completado';
      case 'RECHAZADO':
        fg = isDark ? const Color(0xFFFF8A80) : NexusColors.dangerText;
        bg = isDark ? const Color(0xFF4A1515) : NexusColors.dangerLight;
        dot = isDark ? const Color(0xFFFF8A80) : NexusColors.danger; label = 'Rechazado';
      case 'PENDIENTE_EMPRESA':
        fg = isDark ? const Color(0xFFFFB74D) : NexusColors.warningText;
        bg = isDark ? const Color(0xFF3D2A06) : NexusColors.warningLight;
        dot = isDark ? const Color(0xFFFFB74D) : NexusColors.warning; label = 'Pend. Empresa';
      default:
        fg = isDark ? const Color(0xFF7AB5F5) : NexusColors.primaryText;
        bg = isDark ? const Color(0xFF0D2B4F) : NexusColors.primaryLight;
        dot = isDark ? const Color(0xFF7AB5F5) : NexusColors.primary; label = 'Pend. Centro';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(NexusSizes.radiusFull)),
            child: Text(
              label,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: fg),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
