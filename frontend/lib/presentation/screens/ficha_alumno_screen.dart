import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:provider/provider.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import '../../core/theme/app_theme.dart';
import '../../data/models/ausencia_model.dart';
import '../../data/models/evaluacion_final_model.dart';
import '../../data/models/incidencia_model.dart';
import '../../data/models/practica_model.dart';
import '../../data/models/seguimiento_model.dart';
import '../providers/tutor_centro_provider.dart';
import '../widgets/nexus_charts.dart';

class FichaAlumnoScreen extends StatefulWidget {
  final Practica practica;

  const FichaAlumnoScreen({super.key, required this.practica});

  @override
  State<FichaAlumnoScreen> createState() => _FichaAlumnoScreenState();
}

class _FichaAlumnoScreenState extends State<FichaAlumnoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TutorCentroProvider>().cargarEvaluacionDe(widget.practica.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TutorCentroProvider>();
    final seguimientos = provider.seguimientosDe(widget.practica.id);
    final incidencias = provider.incidenciasDe(widget.practica.id);
    final ausencias = provider.ausenciasDe(widget.practica.id);
    final horasCompletadas = provider.horasCompletadasDe(widget.practica.id);
    final horasTotales = widget.practica.horasTotales ?? 0;

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
            Text(widget.practica.alumnoNombre,
                style: NexusText.caption.copyWith(color: context.nxt.inkSecondary)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, thickness: 0.5, color: context.nxt.border),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () => _exportarExcel(context),
            icon: const Icon(Icons.table_chart_outlined, size: 16),
            label: const Text('Excel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF217346),
              side: const BorderSide(color: Color(0xFF217346)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _exportarAnexo8(context),
            icon: const Icon(Icons.assignment_outlined, size: 16),
            label: const Text('Partes FCT'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6A1B9A),
              side: const BorderSide(color: Color(0xFF6A1B9A)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: () => _exportarPdf(context),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
              label: const Text('PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                side: const BorderSide(color: Color(0xFFD32F2F)),
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
                              _initials(widget.practica.alumnoNombre),
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
                                Text(widget.practica.alumnoNombre,
                                    style: NexusText.heading2
                                        .copyWith(letterSpacing: -0.3)),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.practica.empresaNombre}  ·  ${widget.practica.codigo}',
                                  style: NexusText.body.copyWith(
                                      color: context.nxt.inkSecondary),
                                ),
                              ],
                            ),
                          ),
                          _EstadoBadge(estado: widget.practica.estado),
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
                            widget.practica.fechaInicio, widget.practica.fechaFin),
                      ),
                      const SizedBox(height: 8),
                      _FichaRow(
                        icon: Icons.school_outlined,
                        label: 'Tutor centro',
                        value: widget.practica.tutorCentroNombre,
                      ),
                      const SizedBox(height: 8),
                      _FichaRow(
                        icon: Icons.business_center_outlined,
                        label: 'Tutor empresa',
                        value: widget.practica.tutorEmpresaNombre,
                      ),
                      if (horasTotales > 0) ...[
                        const SizedBox(height: 8),
                        _FichaRow(
                          icon: Icons.access_time_outlined,
                          label: 'Duración',
                          value: '${horasTotales}h totales · ${fmtH(horasCompletadas)} validadas',
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
                            fechaInicio: widget.practica.fechaInicio,
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
                  _SectionTitle(_ausenciasTitulo(ausencias)),
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

                // ── Evaluación final (solo lectura para tutor centro) ───────
                _SectionTitle('Evaluación final'),
                const SizedBox(height: 8),
                Consumer<TutorCentroProvider>(
                  builder: (_, prov, __) =>
                      _EvaluacionCard(evaluacion: prov.evaluacionDe(widget.practica.id)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Export helpers ───────────────────────────────────────────────────────

  String _estadoLabel(String estado) => switch (estado) {
        'COMPLETADO' => 'Validado',
        'PENDIENTE_CENTRO' => 'Pte. centro',
        'PENDIENTE_EMPRESA' => 'Pte. empresa',
        'RECHAZADO' => 'Rechazado',
        _ => estado,
      };

  Future<void> _exportarPdf(BuildContext ctx) async {
    final provider = ctx.read<TutorCentroProvider>();
    final practica = widget.practica;
    final seguimientos = provider.seguimientosDe(practica.id);
    final incidencias = provider.incidenciasDe(practica.id);
    final ausencias = provider.ausenciasDe(practica.id);
    final evaluacion = provider.evaluacionDe(practica.id);
    final horasCompletadas = provider.horasCompletadasDe(practica.id);

    final ausJust = ausencias.where((a) => a.tipo == 'JUSTIFICADA').length;
    final ausInjust = ausencias.where((a) => a.tipo == 'INJUSTIFICADA').length;
    final ausPend = ausencias.where((a) => a.tipo == 'PENDIENTE').length;

    final doc = pw.Document();
    final fechaGen = DateFormat("d 'de' MMMM yyyy", 'es_ES').format(DateTime.now());

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      header: (_) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Generado el $fechaGen',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
      ),
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Nexus FCT — Expediente ${practica.codigo}',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
          pw.Text('Pág. ${ctx.pageNumber} / ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        ],
      ),
      build: (_) => [
        // Título
        pw.Text('EXPEDIENTE FCT',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(practica.alumnoNombre,
            style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
        pw.SizedBox(height: 16),
        // Información práctica
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _pdfRow('Empresa', practica.empresaNombre),
              _pdfRow('Código', practica.codigo),
              _pdfRow('Estado', practica.estado),
              _pdfRow('Periodo',
                  _formatPeriodo(practica.fechaInicio, practica.fechaFin)),
              _pdfRow('Tutor centro', practica.tutorCentroNombre),
              _pdfRow('Tutor empresa', practica.tutorEmpresaNombre),
              if (practica.horasTotales != null && practica.horasTotales! > 0)
                _pdfRow('Progreso',
                    '${fmtH(horasCompletadas)} / ${practica.horasTotales}h  (${(horasCompletadas / practica.horasTotales! * 100).round()}%)'),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        // Seguimientos
        _pdfSection('SEGUIMIENTOS  ·  ${seguimientos.length} partes'),
        pw.SizedBox(height: 8),
        if (seguimientos.isEmpty)
          pw.Text('Sin partes registrados',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey))
        else
          pw.TableHelper.fromTextArray(
            headers: ['Fecha', 'Horas', 'Estado', 'Descripción'],
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.centerLeft,
            },
            data: seguimientos
                .map((s) => [
                      DateFormat('d MMM yy', 'es_ES').format(s.fechaRegistro),
                      fmtH(s.horasRealizadas),
                      _estadoLabel(s.estado),
                      (s.descripcion ?? '').length > 55
                          ? '${(s.descripcion ?? '').substring(0, 55)}…'
                          : (s.descripcion ?? ''),
                    ])
                .toList(),
          ),
        pw.SizedBox(height: 20),
        // Incidencias
        if (incidencias.isNotEmpty) ...[
          _pdfSection('INCIDENCIAS  ·  ${incidencias.length}'),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Fecha', 'Estado', 'Descripción'],
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
            cellStyle: const pw.TextStyle(fontSize: 8),
            data: incidencias
                .map((i) => [
                      DateFormat('d MMM yy', 'es_ES').format(i.fechaCreacion),
                      i.estado,
                      i.descripcion.length > 70
                          ? '${i.descripcion.substring(0, 70)}…'
                          : i.descripcion,
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 20),
        ],
        // Ausencias
        if (ausencias.isNotEmpty) ...[
          _pdfSection(
              'AUSENCIAS  ·  ${ausencias.length}   (Justificadas: $ausJust  |  Injustificadas: $ausInjust  |  Pendientes: $ausPend)'),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Fecha', 'Estado', 'Motivo', 'Revisada por'],
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
            },
            data: ausencias
                .map((a) => [
                      DateFormat('d MMM yy', 'es_ES').format(a.fecha),
                      _ausenciaLabel(a.tipo),
                      a.motivo.length > 60
                          ? '${a.motivo.substring(0, 60)}…'
                          : a.motivo,
                      a.revisadaPorNombre ?? '—',
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 20),
        ],
        // Evaluación
        _pdfSection('EVALUACIÓN FINAL'),
        pw.SizedBox(height: 8),
        if (evaluacion == null)
          pw.Text('Pendiente de evaluación por el tutor de empresa',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey))
        else
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(4))),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                    'Nota global: ${evaluacion.notaGlobal.toStringAsFixed(2)} / 10',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(
                    'Por ${evaluacion.tutorEmpresaNombre}  ·  ${DateFormat("d MMM yyyy", "es_ES").format(evaluacion.fechaEvaluacion)}',
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColors.grey700)),
                pw.SizedBox(height: 8),
                if (evaluacion.actitudPuntualidad != null)
                  _pdfCrit('Actitud y puntualidad',
                      evaluacion.actitudPuntualidad!),
                if (evaluacion.competenciaTecnica != null)
                  _pdfCrit(
                      'Competencia técnica', evaluacion.competenciaTecnica!),
                if (evaluacion.iniciativaAutonomia != null)
                  _pdfCrit(
                      'Iniciativa y autonomía', evaluacion.iniciativaAutonomia!),
                if (evaluacion.trabajoEquipo != null)
                  _pdfCrit('Trabajo en equipo', evaluacion.trabajoEquipo!),
                if (evaluacion.cumplimientoTareas != null)
                  _pdfCrit('Cumplimiento de tareas',
                      evaluacion.cumplimientoTareas!),
                if (evaluacion.comentario != null &&
                    evaluacion.comentario!.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text('Comentario:',
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text(evaluacion.comentario!,
                      style: const pw.TextStyle(fontSize: 9)),
                ],
              ],
            ),
          ),
      ],
    ));

    final bytes = await doc.save();
    await Printing.sharePdf(
        bytes: bytes, filename: 'expediente_${practica.codigo}.pdf');
  }

  // ── EXPORTAR PARTES EN FORMATO ANEXO 8 ──────────────────────────────────────

  Future<void> _exportarAnexo8(BuildContext ctx) async {
    final provider = ctx.read<TutorCentroProvider>();
    final practica = widget.practica;
    final seguimientos = provider.seguimientosDe(practica.id)
      ..sort((a, b) => a.fechaRegistro.compareTo(b.fechaRegistro));

    if (seguimientos.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('No hay partes registrados para exportar')),
      );
      return;
    }

    final doc = pw.Document();
    final fmtDate = DateFormat('dd/MM/yyyy');
    final cursoAcademico = _calcularCursoAcademico(practica.fechaInicio);

    // Separar nombre completo en apellidos + nombre (formato: "Nombre Apellido1 Apellido2")
    final parts = practica.alumnoNombre.trim().split(' ');
    final nombreAlumno = parts.isNotEmpty ? parts.first : practica.alumnoNombre;
    final apellidosAlumno = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final partesTutor = practica.tutorEmpresaNombre.trim().split(' ');
    final nombreTutor = partesTutor.isNotEmpty ? partesTutor.first : '';
    final apellidosTutor = partesTutor.length > 1 ? partesTutor.sublist(1).join(' ') : '';

    for (int i = 0; i < seguimientos.length; i++) {
      final seg = seguimientos[i];

      // Calcular inicio de semana (lunes) a partir de la fecha del seguimiento
      final fechaFin = seg.fechaRegistro;
      final fechaInicio = fechaFin.subtract(Duration(days: fechaFin.weekday - 1));
      final periodoStr = 'De ${fmtDate.format(fechaInicio)} a ${fmtDate.format(fechaFin)}';

      final estadoTexto = _estadoAnexo(seg.estado);

      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ── Cabecera convenio ──────────────────────────────────────────
            _anexoHeaderTable(cursoAcademico, practica.codigo, '${i + 1}/${seguimientos.length}'),
            pw.SizedBox(height: 4),

            // ── Datos del alumno ──────────────────────────────────────────
            _anexoSectionTable([
              ['Apellidos: $apellidosAlumno', 'Nombre: $nombreAlumno'],
              ['E-mail de contacto: ', ''],
            ], title: 'Datos del alumno'),
            pw.SizedBox(height: 4),

            // ── Datos del centro de trabajo ───────────────────────────────
            _anexoSectionTable([
              ['EMPRESA: ${practica.empresaNombre}', ''],
              ['Tutor/a de la empresa:', ''],
              ['Apellidos: $apellidosTutor', 'Nombre: $nombreTutor'],
              ['Email tutor empresa: ', ''],
            ], title: 'Datos del centro de trabajo'),
            pw.SizedBox(height: 4),

            // ── Periodo ───────────────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey600, width: 0.5)),
              child: pw.Text(periodoStr,
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 4),

            // ── Tabla de actividades ──────────────────────────────────────
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(5),
                1: const pw.FixedColumnWidth(42),
                2: const pw.FixedColumnWidth(18),
                3: const pw.FixedColumnWidth(32),
                4: const pw.FixedColumnWidth(32),
                5: const pw.FixedColumnWidth(32),
                6: const pw.FlexColumnWidth(2),
              },
              children: [
                // Cabecera
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tCell('Actividad formativa desarrollada', bold: true, size: 7),
                    _tCell('Módulo profesional', bold: true, size: 7, center: true),
                    _tCell('R.A.', bold: true, size: 7, center: true),
                    _tCell('No superado', bold: true, size: 7, center: true),
                    _tCell('En proceso', bold: true, size: 7, center: true),
                    _tCell('Superado', bold: true, size: 7, center: true),
                    _tCell('Observaciones', bold: true, size: 7, center: true),
                  ],
                ),
                // Fila con la descripción del seguimiento
                pw.TableRow(children: [
                  _tCellMulti(seg.descripcion ?? '—', size: 8),
                  _tCell('', size: 8, center: true),
                  _tCell('', size: 8, center: true),
                  _tCell(estadoTexto == 'Superado' ? '' : '', size: 8, center: true),
                  _tCell(estadoTexto == 'En proceso' ? '✓' : '', size: 8, center: true),
                  _tCell(estadoTexto == 'Superado' ? '✓' : '', size: 8, center: true),
                  _tCell(
                    seg.comentarioTutor != null && seg.comentarioTutor!.isNotEmpty
                        ? seg.comentarioTutor!
                        : '',
                    size: 7,
                  ),
                ]),
                // Filas vacías para completar manualmente
                for (int r = 0; r < 4; r++)
                  pw.TableRow(children: [
                    _tCellMulti('', size: 8),
                    _tCell('', size: 8),
                    _tCell('', size: 8),
                    _tCell('', size: 8),
                    _tCell('', size: 8),
                    _tCell('', size: 8),
                    _tCell('', size: 8),
                  ]),
              ],
            ),
            pw.SizedBox(height: 8),

            // ── Horas + estado ────────────────────────────────────────────
            pw.Row(children: [
              pw.Expanded(child: pw.Text('Horas realizadas: ${_fmtHoras(seg.horasRealizadas)}',
                  style: const pw.TextStyle(fontSize: 9))),
              pw.Text('Estado: $estadoTexto',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ]),
            pw.SizedBox(height: 12),

            // ── Firma ─────────────────────────────────────────────────────
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'El/la tutor/a de la empresa u organismo equiparado (Firma digital preferentemente)',
                        style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
                      ),
                      pw.SizedBox(height: 24),
                      pw.Text('Fecha: ${fmtDate.format(fechaFin)}',
                          style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey600, width: 0.5)),
              child: pw.Text(
                'Destinatario: profesor/a tutor/a del centro docente: ${practica.tutorCentroNombre}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ],
        ),
      ));
    }

    final bytes = await doc.save();
    await Printing.sharePdf(
        bytes: bytes, filename: 'partes_fct_${practica.codigo}.pdf');
  }

  String _calcularCursoAcademico(DateTime? fecha) {
    final d = fecha ?? DateTime.now();
    return d.month >= 9
        ? '${d.year} / ${d.year + 1}'
        : '${d.year - 1} / ${d.year}';
  }

  String _estadoAnexo(String estado) {
    switch (estado) {
      case 'COMPLETADO': return 'Superado';
      case 'PENDIENTE_EMPRESA': return 'En proceso';
      case 'RECHAZADO': return 'No superado';
      default: return 'En proceso';
    }
  }

  String _fmtHoras(double h) {
    if (h == h.truncate()) return '${h.truncate()}h';
    return '${h.toStringAsFixed(1)}h';
  }

  pw.Widget _anexoHeaderTable(String curso, String convenio, String anexo) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tCell('Curso académico', bold: true, size: 7, center: true),
            _tCell('Nº del Convenio o Acuerdo de aprendizaje', bold: true, size: 7, center: true),
            _tCell('Nº del Anexo Relación de alumnos', bold: true, size: 7, center: true),
          ],
        ),
        pw.TableRow(children: [
          _tCell(curso, size: 9, center: true),
          _tCell(convenio, size: 9, center: true),
          _tCell(anexo, size: 9, center: true),
        ]),
      ],
    );
  }

  pw.Widget _anexoSectionTable(List<List<String>> rows, {required String title}) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(title,
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(),
          ],
        ),
        for (final row in rows)
          pw.TableRow(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              child: pw.Text(row[0], style: const pw.TextStyle(fontSize: 9)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              child: pw.Text(row[1], style: const pw.TextStyle(fontSize: 9)),
            ),
          ]),
      ],
    );
  }

  pw.Widget _tCell(String text, {bool bold = false, double size = 9, bool center = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        text,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(fontSize: size, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }

  pw.Widget _tCellMulti(String text, {double size = 9}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(text, style: pw.TextStyle(fontSize: size)),
    );
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(children: [
          pw.SizedBox(
              width: 100,
              child: pw.Text(label,
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700))),
          pw.Expanded(
              child: pw.Text(value, style: const pw.TextStyle(fontSize: 9))),
        ]),
      );

  pw.Widget _pdfSection(String title) => pw.Text(title,
      style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey700));

  pw.Widget _pdfCrit(String label, double value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Row(children: [
          pw.Expanded(
              child: pw.Text('• $label',
                  style: const pw.TextStyle(fontSize: 9))),
          pw.Text('${value.toStringAsFixed(1)} / 10',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ]),
      );

  Future<void> _exportarExcel(BuildContext ctx) async {
    final provider = ctx.read<TutorCentroProvider>();
    final practica = widget.practica;
    final seguimientos = provider.seguimientosDe(practica.id);
    final incidencias = provider.incidenciasDe(practica.id);
    final ausencias = provider.ausenciasDe(practica.id);
    final evaluacion = provider.evaluacionDe(practica.id);

    final wb = Excel.createExcel();
    wb.delete('Sheet1');

    // Sheet: Información
    final info = wb['Información'];
    _xlRow(info, ['Campo', 'Valor']);
    _xlRow(info, ['Alumno', practica.alumnoNombre]);
    _xlRow(info, ['Empresa', practica.empresaNombre]);
    _xlRow(info, ['Código', practica.codigo]);
    _xlRow(info, ['Estado', practica.estado]);
    _xlRow(info, ['Tutor centro', practica.tutorCentroNombre]);
    _xlRow(info, ['Tutor empresa', practica.tutorEmpresaNombre]);
    if (practica.fechaInicio != null)
      _xlRow(info,
          ['Fecha inicio', DateFormat('dd/MM/yyyy').format(practica.fechaInicio!)]);
    if (practica.fechaFin != null)
      _xlRow(info,
          ['Fecha fin', DateFormat('dd/MM/yyyy').format(practica.fechaFin!)]);
    if (practica.horasTotales != null)
      _xlRow(info, ['Horas totales', '${practica.horasTotales}']);

    // Sheet: Seguimientos
    final segSheet = wb['Seguimientos'];
    _xlRow(segSheet, ['Fecha', 'Horas', 'Estado', 'Descripción', 'Validado por', 'Comentario tutor']);
    for (final s in seguimientos) {
      _xlRow(segSheet, [
        DateFormat('dd/MM/yyyy').format(s.fechaRegistro),
        '${s.horasRealizadas}',
        _estadoLabel(s.estado),
        s.descripcion ?? '',
        s.validadoPorNombre ?? '',
        s.comentarioTutor ?? '',
      ]);
    }

    // Sheet: Incidencias
    if (incidencias.isNotEmpty) {
      final incSheet = wb['Incidencias'];
      _xlRow(incSheet, ['Fecha', 'Estado', 'Descripción']);
      for (final i in incidencias) {
        _xlRow(incSheet, [
          DateFormat('dd/MM/yyyy').format(i.fechaCreacion),
          i.estado,
          i.descripcion,
        ]);
      }
    }

    // Sheet: Ausencias
    if (ausencias.isNotEmpty) {
      final ausSheet = wb['Ausencias'];
      _xlRow(ausSheet, ['Fecha', 'Estado', 'Motivo', 'Revisada por', 'Comentario revisión']);
      for (final a in ausencias) {
        _xlRow(ausSheet, [
          DateFormat('dd/MM/yyyy').format(a.fecha),
          _ausenciaLabel(a.tipo),
          a.motivo,
          a.revisadaPorNombre ?? '',
          a.comentarioRevision ?? '',
        ]);
      }
    }

    // Sheet: Evaluación
    if (evaluacion != null) {
      final evalSheet = wb['Evaluación'];
      _xlRow(evalSheet, ['Criterio', 'Nota']);
      _xlRow(evalSheet, ['Nota global', evaluacion.notaGlobal.toStringAsFixed(2)]);
      if (evaluacion.actitudPuntualidad != null)
        _xlRow(evalSheet, ['Actitud y puntualidad', evaluacion.actitudPuntualidad!.toStringAsFixed(1)]);
      if (evaluacion.competenciaTecnica != null)
        _xlRow(evalSheet, ['Competencia técnica', evaluacion.competenciaTecnica!.toStringAsFixed(1)]);
      if (evaluacion.iniciativaAutonomia != null)
        _xlRow(evalSheet, ['Iniciativa y autonomía', evaluacion.iniciativaAutonomia!.toStringAsFixed(1)]);
      if (evaluacion.trabajoEquipo != null)
        _xlRow(evalSheet, ['Trabajo en equipo', evaluacion.trabajoEquipo!.toStringAsFixed(1)]);
      if (evaluacion.cumplimientoTareas != null)
        _xlRow(evalSheet, ['Cumplimiento de tareas', evaluacion.cumplimientoTareas!.toStringAsFixed(1)]);
      if (evaluacion.comentario != null && evaluacion.comentario!.isNotEmpty)
        _xlRow(evalSheet, ['Comentario', evaluacion.comentario!]);
      _xlRow(evalSheet, ['Evaluado por', evaluacion.tutorEmpresaNombre]);
      _xlRow(evalSheet, [
        'Fecha evaluación',
        DateFormat('dd/MM/yyyy').format(evaluacion.fechaEvaluacion)
      ]);
    }

    final rawBytes = wb.save();
    if (rawBytes == null) return;
    final blob = html.Blob([Uint8List.fromList(rawBytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'expediente_${practica.codigo}.xlsx')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _xlRow(Sheet sheet, List<String> values) {
    final row = sheet.maxRows;
    for (int i = 0; i < values.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
          .value = TextCellValue(values[i]);
    }
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

  String _ausenciaLabel(String tipo) => switch (tipo) {
        'JUSTIFICADA' => 'Justificada',
        'INJUSTIFICADA' => 'Injustificada',
        _ => 'Pendiente',
      };

  String _ausenciasTitulo(List<Ausencia> ausencias) {
    final just = ausencias.where((a) => a.tipo == 'JUSTIFICADA').length;
    final injust = ausencias.where((a) => a.tipo == 'INJUSTIFICADA').length;
    final pend = ausencias.where((a) => a.tipo == 'PENDIENTE').length;
    final parts = <String>[];
    if (just > 0) parts.add('$just justificada${just == 1 ? '' : 's'}');
    if (injust > 0) parts.add('$injust injustificada${injust == 1 ? '' : 's'}');
    if (pend > 0) parts.add('$pend pendiente${pend == 1 ? '' : 's'}');
    return 'Ausencias  ·  ${ausencias.length}  (${parts.join(', ')})';
  }
}

// ── Evaluación widgets ─────────────────────────────────────────────────────────

class _EvaluacionCard extends StatelessWidget {
  final EvaluacionFinalModel? evaluacion;
  const _EvaluacionCard({required this.evaluacion});

  @override
  Widget build(BuildContext context) {
    if (evaluacion == null) {
      return _FichaCard(
        child: Row(
          children: [
            Icon(Icons.grade_outlined, color: context.nxt.inkTertiary, size: 22),
            const SizedBox(width: 12),
            Text('Pendiente de evaluación por el tutor de empresa',
                style: NexusText.body.copyWith(color: context.nxt.inkSecondary)),
          ],
        ),
      );
    }

    final nota = evaluacion!.notaGlobal;
    final color = nota >= 9
        ? NexusColors.success
        : nota >= 7
            ? NexusColors.primary
            : nota >= 5
                ? NexusColors.warning
                : NexusColors.danger;

    final criterios = <String, double?>{
      'Actitud y puntualidad': evaluacion!.actitudPuntualidad,
      'Competencia técnica': evaluacion!.competenciaTecnica,
      'Iniciativa y autonomía': evaluacion!.iniciativaAutonomia,
      'Trabajo en equipo': evaluacion!.trabajoEquipo,
      'Cumplimiento de tareas': evaluacion!.cumplimientoTareas,
    }.entries.where((e) => e.value != null).toList();

    return _FichaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(nota.toStringAsFixed(2),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nota global', style: NexusText.small.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Por ${evaluacion!.tutorEmpresaNombre}',
                        style: NexusText.caption.copyWith(color: context.nxt.inkSecondary)),
                    Text(DateFormat('d MMM yyyy', 'es_ES').format(evaluacion!.fechaEvaluacion),
                        style: NexusText.caption.copyWith(color: context.nxt.inkTertiary)),
                  ],
                ),
              ),
            ],
          ),
          if (criterios.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(height: 1, thickness: 0.5, color: context.nxt.border),
            const SizedBox(height: 12),
            ...criterios.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(child: Text(e.key, style: NexusText.caption)),
                  Text(e.value!.toStringAsFixed(1),
                      style: NexusText.caption.copyWith(fontWeight: FontWeight.w600)),
                  Text('/10', style: NexusText.caption.copyWith(color: context.nxt.inkTertiary)),
                ],
              ),
            )),
          ],
          if (evaluacion!.comentario != null && evaluacion!.comentario!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(height: 1, thickness: 0.5, color: context.nxt.border),
            const SizedBox(height: 10),
            Text(evaluacion!.comentario!,
                style: NexusText.body.copyWith(color: context.nxt.inkSecondary)),
          ],
        ],
      ),
    );
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
              child: Text(fmtH(seguimiento.horasRealizadas),
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
