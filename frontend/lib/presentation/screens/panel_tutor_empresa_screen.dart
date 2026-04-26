import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/seguimiento_model.dart';
import '../providers/auth_provider.dart';
import '../providers/tutor_empresa_provider.dart';

class PanelTutorEmpresaScreen extends StatefulWidget {
  const PanelTutorEmpresaScreen({super.key});

  @override
  State<PanelTutorEmpresaScreen> createState() => _PanelTutorEmpresaScreenState();
}

class _PanelTutorEmpresaScreenState extends State<PanelTutorEmpresaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TutorEmpresaProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<TutorEmpresaProvider>();

    return Scaffold(
      backgroundColor: NexusColors.surfaceAlt,
      appBar: AppBar(
        title: const Text('Validar Partes Semanales'),
        actions: [
          TextButton.icon(
            onPressed: () => auth.logout(),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Salir'),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(TutorEmpresaProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: NexusColors.danger),
            const SizedBox(height: NexusSizes.spaceLG),
            Text(provider.error!, style: NexusText.body),
            const SizedBox(height: NexusSizes.spaceLG),
            OutlinedButton(
              onPressed: () => context.read<TutorEmpresaProvider>().cargar(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final pendientes = provider.todosPendientes;

    if (pendientes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: NexusColors.success.withOpacity(0.6)),
            const SizedBox(height: NexusSizes.spaceLG),
            Text('Sin partes pendientes', style: NexusText.heading2),
            const SizedBox(height: NexusSizes.spaceSM),
            Text('Todos los partes han sido procesados.',
                style: NexusText.body.copyWith(color: NexusColors.inkSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TutorEmpresaProvider>().cargar(),
      child: ListView.separated(
        padding: const EdgeInsets.all(NexusSizes.spaceLG),
        itemCount: pendientes.length,
        separatorBuilder: (_, __) => const SizedBox(height: NexusSizes.spaceMD),
        itemBuilder: (context, index) {
          final seguimiento = pendientes[index];
          final practica = provider.practicaDe(seguimiento.practicaId);
          return _PartePendienteCard(
            seguimiento: seguimiento,
            alumnoNombre: practica?.alumnoNombre ?? 'Alumno',
            empresaNombre: practica?.empresaNombre ?? '',
            onValidar: () => _confirmarValidar(seguimiento.id),
            onRechazar: () => _mostrarModalRechazo(seguimiento.id),
          );
        },
      ),
    );
  }

  Future<void> _confirmarValidar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Validar parte'),
        content: const Text('¿Confirmas que las horas y actividades son correctas?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Validar')),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final ok = await context.read<TutorEmpresaProvider>().validar(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Parte validado correctamente' : 'Error al validar el parte'),
        backgroundColor: ok ? NexusColors.success : NexusColors.danger,
      ));
    }
  }

  Future<void> _mostrarModalRechazo(int id) async {
    final motivoController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NexusColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(NexusSizes.radiusLG)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          NexusSizes.space2XL,
          NexusSizes.space2XL,
          NexusSizes.space2XL,
          MediaQuery.of(ctx).viewInsets.bottom + NexusSizes.space2XL,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rechazar parte', style: NexusText.heading2),
              const SizedBox(height: NexusSizes.spaceSM),
              Text(
                'El alumno recibirá una incidencia automática con el motivo indicado.',
                style: NexusText.body.copyWith(color: NexusColors.inkSecondary),
              ),
              const SizedBox(height: NexusSizes.spaceLG),
              TextFormField(
                controller: motivoController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Motivo del rechazo *',
                  hintText: 'Describe qué debe corregir el alumno...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El motivo es obligatorio'
                    : null,
              ),
              const SizedBox(height: NexusSizes.spaceLG),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: NexusSizes.spaceMD),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: NexusColors.danger,
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(ctx);
                        final ok = await context
                            .read<TutorEmpresaProvider>()
                            .rechazar(id, motivoController.text.trim());
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok
                                ? 'Parte rechazado. Se notificará al alumno.'
                                : 'Error al rechazar el parte'),
                            backgroundColor: ok ? NexusColors.warning : NexusColors.danger,
                          ));
                        }
                      },
                      child: const Text('Rechazar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartePendienteCard extends StatelessWidget {
  final Seguimiento seguimiento;
  final String alumnoNombre;
  final String empresaNombre;
  final VoidCallback onValidar;
  final VoidCallback onRechazar;

  const _PartePendienteCard({
    required this.seguimiento,
    required this.alumnoNombre,
    required this.empresaNombre,
    required this.onValidar,
    required this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('d MMM yyyy', 'es_ES').format(seguimiento.fechaRegistro);

    return Container(
      decoration: BoxDecoration(
        color: NexusColors.surface,
        borderRadius: BorderRadius.circular(NexusSizes.radiusLG),
        border: Border.all(color: NexusColors.border, width: NexusSizes.borderWidth),
      ),
      padding: const EdgeInsets.all(NexusSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: alumno + badge pendiente
          Row(
            children: [
              Expanded(
                child: Text(alumnoNombre,
                    style: NexusText.heading3, overflow: TextOverflow.ellipsis),
              ),
              _Badge(label: 'Pendiente firma', color: NexusColors.warning),
            ],
          ),
          if (empresaNombre.isNotEmpty) ...[
            const SizedBox(height: NexusSizes.spaceXS),
            Text(empresaNombre,
                style: NexusText.caption.copyWith(color: NexusColors.inkSecondary)),
          ],
          const SizedBox(height: NexusSizes.spaceMD),
          const Divider(color: NexusColors.border, height: 1),
          const SizedBox(height: NexusSizes.spaceMD),

          // Datos del parte
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: NexusColors.inkTertiary),
              const SizedBox(width: NexusSizes.spaceXS),
              Text(fecha, style: NexusText.caption),
              const SizedBox(width: NexusSizes.spaceLG),
              const Icon(Icons.access_time_outlined,
                  size: 14, color: NexusColors.inkTertiary),
              const SizedBox(width: NexusSizes.spaceXS),
              Text('${seguimiento.horasRealizadas} h', style: NexusText.caption),
            ],
          ),
          if (seguimiento.descripcion != null &&
              seguimiento.descripcion!.isNotEmpty) ...[
            const SizedBox(height: NexusSizes.spaceSM),
            Text(
              seguimiento.descripcion!,
              style: NexusText.body.copyWith(color: NexusColors.inkSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: NexusSizes.spaceLG),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRechazar,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Rechazar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NexusColors.danger,
                    side: const BorderSide(color: NexusColors.danger),
                  ),
                ),
              ),
              const SizedBox(width: NexusSizes.spaceMD),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onValidar,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Validar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: NexusColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: NexusSizes.spaceSM, vertical: NexusSizes.spaceXS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(NexusSizes.radiusFull),
      ),
      child: Text(label,
          style: NexusText.caption.copyWith(
              color: color, fontWeight: FontWeight.w600)),
    );
  }
}
