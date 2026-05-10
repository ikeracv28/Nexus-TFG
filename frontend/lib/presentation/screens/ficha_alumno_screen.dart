import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/ausencia_model.dart';
import '../../data/models/incidencia_model.dart';
import '../../data/models/practica_model.dart';
import '../../data/models/seguimiento_model.dart';
import '../providers/tutor_centro_provider.dart';
import '../widgets/nexus_charts.dart';

class FichaAlumnoScreen extends StatelessWidget {
  final Practica practica;

  const FichaAlumnoScreen({super.key, required this.practica});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TutorCentroProvider>();
    final seguimientos = provider.seguimientosDe(practica.id);
    final incidencias = provider.incidenciasDe(practica.id);
    final ausencias = provider.ausenciasDe(practica.id);
    final horasCompletadas = provider.horasCompletadasDe(practica.id);
    final horasTotales = practica.horasTotales ?? 0;

    return Scaffold(
      backgroundColor: context.nxt.surfaceAlt,
      appBar: AppBar(
        backgroundColor: context.nxt.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.nxt.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expediente FCT',
                style: NexusText.small.copyWith(fontWeight: FontWeight.w600)),
            Text(practica.alumnoNombre,
                style: NexusText.caption.copyWith(color: context.nxt.inkSecondary)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, thickness: 0.5, color: context.nxt.border),
        ),
        // Botón PDF — se activará en la feature 5
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: null, // TODO: Feature 5 — PDF export
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
              label: const Text('PDF'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cabecera del alumno ─────────────────────────────────────
                _FichaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: NexusColors.primaryLight,
                            child: Text(
                              _initials(practica.alumnoNombre),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: NexusColors.primaryText),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(practica.alumnoNombre,
                                    style: NexusText.heading2
                                        .copyWith(letterSpacing: -0.3)),
                                const SizedBox(height: 2),
                                Text(
                                  '${practica.empresaNombre}  ·  ${practica.codigo}',
                                  style: NexusText.body.copyWith(
                                      color: context.nxt.inkSecondary),
                                ),
                              ],
                            ),
                          ),
                          _EstadoBadge(estado: practica.estado),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(
                          height: 1,
                          thickness: 0.5,
                          color: context.nxt.border),
                      const SizedBox(height: 14),
                      _FichaRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Periodo',
                        value: _formatPeriodo(
                            practica.fechaInicio, practica.fechaFin),
                      ),
                      const SizedBox(height: 8),
                      _FichaRow(
                        icon: Icons.school_outlined,
                        label: 'Tutor centro',
                        value: practica.tutorCentroNombre,
                      ),
                      const SizedBox(height: 8),
                      _FichaRow(
                        icon: Icons.business_center_outlined,
                        label: 'Tutor empresa',
                        value: practica.tutorEmpresaNombre,
                      ),
                      if (horasTotales > 0) ...[
                        const SizedBox(height: 8),
                        _FichaRow(
                          icon: Icons.access_time_outlined,
                          label: 'Duración',
                          value: '${horasTotales}h totales · ${horasCompletadas}h validadas',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Progreso FCT ────────────────────────────────────────────
                if (horasTotales > 0) ...[
                  _SectionTitle('Progreso FCT'),
                  const SizedBox(height: 8),
                  _FichaCard(
                    child: Column(
                      children: [
                        ProgresoDonutChart(
                          horasCompletadas: horasCompletadas,
                          horasTotales: horasTotales,
                        ),
                        if (seguimientos
                            .any((s) => s.cuentaParaProgreso)) ...[
                          const SizedBox(height: 20),
                          Divider(
                              height: 1,
                              thickness: 0.5,
                              color: context.nxt.border),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Horas por semana',
                                style: NexusText.caption
                                    .copyWith(color: context.nxt.inkSecondary)),
                          ),
                          const SizedBox(height: 8),
                          HorasSemanaChart(
                            seguimientos: seguimientos,
                            fechaInicio: practica.fechaInicio,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Seguimientos ────────────────────────────────────────────
                _SectionTitle(
                    'Seguimientos  ·  ${seguimientos.length} partes'),
                const SizedBox(height: 8),
                _FichaCard(
                  child: seguimientos.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text('Sin partes registrados',
                                style: NexusText.caption
                                    .copyWith(color: context.nxt.inkTertiary)),
                          ),
                        )
                      : _SeguimientosTable(seguimientos: seguimientos),
                ),
                const SizedBox(height: 16),

                // ── Incidencias ─────────────────────────────────────────────
                if (incidencias.isNotEmpty) ...[
                  _SectionTitle(
                      'Incidencias  ·  ${incidencias.length}'),
                  const SizedBox(height: 8),
                  _FichaCard(
                    child: Column(
                      children: incidencias.asMap().entries.map((e) {
                        final isLast = e.key == incidencias.length - 1;
                        return _IncidenciaFichaRow(
                            incidencia: e.value, isLast: isLast);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Ausencias ───────────────────────────────────────────────
                if (ausencias.isNotEmpty) ...[
                  _SectionTitle('Ausencias  ·  ${ausencias.length}'),
                  const SizedBox(height: 8),
                  _FichaCard(
                    child: Column(
                      children: ausencias.asMap().entries.map((e) {
                        final isLast = e.key == ausencias.length - 1;
                        return _AusenciaFichaRow(
                            ausencia: e.value, isLast: isLast);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String nombre) {
    final parts =
        nombre.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatPeriodo(DateTime? inicio, DateTime? fin) {
    String fmt(DateTime d) =>
        DateFormat('d MMM yyyy', 'es_ES').format(d);
    if (inicio == null) return 'Sin fecha de inicio';
    if (fin == null) return 'Desde ${fmt(inicio)}';
    return '${fmt(inicio)} → ${fmt(fin)}';
  }
}

// ── Componentes ────────────────────────────────────────────────────────────────

class _FichaCard extends StatelessWidget {
  final Widget child;
  const _FichaCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border.all(color: context.nxt.border, width: NexusSizes.borderWidth),
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: NexusText.label.copyWith(
          color: context.nxt.inkTertiary, letterSpacing: 1.0),
    );
  }
}

class _FichaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _FichaRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.nxt.inkTertiary),
        const SizedBox(width: 8),
        Text('$label  ',
            style:
                NexusText.caption.copyWith(color: context.nxt.inkSecondary)),
        Expanded(
          child: Text(value,
              style:
                  NexusText.small.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (estado) {
      'ACTIVA' => ('Activa', NexusColors.primaryLight, NexusColors.primaryText),
      'FINALIZADA' => ('Finalizada', NexusColors.successLight, NexusColors.successText),
      _ => ('Borrador', NexusColors.neutralLight, NexusColors.neutralText),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NexusSizes.radiusFull),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg)),
    );
  }
}

// ── Tabla de seguimientos ──────────────────────────────────────────────────────

class _SeguimientosTable extends StatelessWidget {
  final List<Seguimiento> seguimientos;
  const _SeguimientosTable({required this.seguimientos});

  @override
  Widget build(BuildContext context) {
    // Ordenar por fecha descendente
    final sorted = [...seguimientos]
      ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));

    return Column(
      children: [
        // Cabecera
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text('Fecha',
                      style: NexusText.label.copyWith(
                          color: context.nxt.inkTertiary))),
              Expanded(
                  flex: 1,
                  child: Text('Horas',
                      style: NexusText.label.copyWith(
                          color: context.nxt.inkTertiary))),
              Expanded(
                  flex: 3,
                  child: Text('Estado',
                      style: NexusText.label.copyWith(
                          color: context.nxt.inkTertiary))),
            ],
          ),
        ),
        Divider(height: 1, thickness: 0.5, color: context.nxt.border),
        ...sorted.asMap().entries.map((e) {
          final s = e.value;
          final isLast = e.key == sorted.length - 1;
          return _SeguimientoFila(seguimiento: s, isLast: isLast);
        }),
      ],
    );
  }
}

class _SeguimientoFila extends StatelessWidget {
  final Seguimiento seguimiento;
  final bool isLast;
  const _SeguimientoFila(
      {required this.seguimiento, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('d MMM yy', 'es_ES')
        .format(seguimiento.fechaRegistro);

    final (label, color) = switch (seguimiento.estado) {
      'COMPLETADO' => ('Validado', NexusColors.success),
      'PENDIENTE_CENTRO' => ('Pte. centro', NexusColors.primary),
      'PENDIENTE_EMPRESA' => ('Pte. empresa', NexusColors.warning),
      'RECHAZADO' => ('Rechazado', NexusColors.danger),
      _ => (seguimiento.estado, NexusColors.inkSecondary),
    };

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color: context.nxt.border,
                    width: NexusSizes.borderWidth)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(fecha, style: NexusText.small)),
          Expanded(
              flex: 1,
              child: Text('${seguimiento.horasRealizadas}h',
                  style: NexusText.small
                      .copyWith(fontWeight: FontWeight.w500))),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(label,
                    style: NexusText.small.copyWith(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fila de incidencia ─────────────────────────────────────────────────────────

class _IncidenciaFichaRow extends StatelessWidget {
  final Incidencia incidencia;
  final bool isLast;
  const _IncidenciaFichaRow(
      {required this.incidencia, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('d MMM yy', 'es_ES')
        .format(incidencia.fechaCreacion);

    final color = switch (incidencia.estado) {
      'ABIERTA' => NexusColors.danger,
      'EN_PROCESO' => NexusColors.primary,
      'RESUELTA' => NexusColors.success,
      _ => NexusColors.inkSecondary,
    };

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color: context.nxt.border,
                    width: NexusSizes.borderWidth)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 36,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(incidencia.descripcion,
                    style: NexusText.small,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '$fecha  ·  ${incidencia.estado}',
                  style: NexusText.caption
                      .copyWith(color: context.nxt.inkTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fila de ausencia ───────────────────────────────────────────────────────────

class _AusenciaFichaRow extends StatelessWidget {
  final Ausencia ausencia;
  final bool isLast;
  const _AusenciaFichaRow(
      {required this.ausencia, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final fecha =
        DateFormat('d MMM yy', 'es_ES').format(ausencia.fecha);

    final (label, color) = switch (ausencia.tipo) {
      'JUSTIFICADA' => ('Justificada', NexusColors.success),
      'INJUSTIFICADA' => ('Injustificada', NexusColors.danger),
      _ => ('Pendiente', NexusColors.warning),
    };

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color: context.nxt.border,
                    width: NexusSizes.borderWidth)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 10, top: 2),
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ausencia.motivo,
                    style: NexusText.small,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(fecha,
                    style: NexusText.caption
                        .copyWith(color: context.nxt.inkTertiary)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius:
                  BorderRadius.circular(NexusSizes.radiusFull),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ),
        ],
      ),
    );
  }
}
