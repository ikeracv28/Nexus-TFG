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
  State<PanelTutorEmpresaScreen> createState() =>
      _PanelTutorEmpresaScreenState();
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Row(
            children: [
              if (isWide) _Sidebar(auth: auth),
              Expanded(child: _buildContent(auth, provider)),
            ],
          );
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) return const SizedBox.shrink();
          return _buildBottomBar(auth);
        },
      ),
    );
  }

  Widget _buildContent(AuthProvider auth, TutorEmpresaProvider provider) {
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
    final empresa = provider.practicas.isNotEmpty
        ? provider.practicas.first.empresaNombre
        : '';

    return RefreshIndicator(
      onRefresh: () => context.read<TutorEmpresaProvider>().cargar(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(NexusSizes.space2XL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('Partes pendientes de firma', style: NexusText.heading2),
            const SizedBox(height: NexusSizes.spaceXS),
            Text(
              '${auth.user?.nombreCompleto ?? ''} · $empresa',
              style: NexusText.caption.copyWith(color: NexusColors.inkSecondary),
            ),
            const SizedBox(height: NexusSizes.space2XL),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: '${pendientes.length}',
                    label: 'Pendientes',
                    bg: NexusColors.warningLight,
                    valueColor: NexusColors.warning,
                    labelColor: NexusColors.warningText,
                  ),
                ),
                const SizedBox(width: NexusSizes.spaceSM),
                Expanded(
                  child: _StatCard(
                    value: '${provider.totalValidados}',
                    label: 'Procesados',
                    bg: NexusColors.successLight,
                    valueColor: NexusColors.success,
                    labelColor: NexusColors.successText,
                  ),
                ),
                const SizedBox(width: NexusSizes.spaceSM),
                Expanded(
                  child: _StatCard(
                    value: '${provider.totalHoras}h',
                    label: 'Horas totales',
                    bg: NexusColors.neutralLight,
                    valueColor: NexusColors.neutral,
                    labelColor: NexusColors.neutralText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: NexusSizes.space2XL),

            if (pendientes.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: NexusSizes.space3XL),
                decoration: BoxDecoration(
                  color: NexusColors.surface,
                  border: Border.all(color: NexusColors.border, width: NexusSizes.borderWidth),
                  borderRadius: BorderRadius.circular(NexusSizes.radiusLG),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 48, color: Color.fromRGBO(59, 109, 17, 0.5)),
                    const SizedBox(height: NexusSizes.spaceMD),
                    Text('Sin partes pendientes', style: NexusText.heading3),
                    const SizedBox(height: NexusSizes.spaceXS),
                    Text('Todos los partes han sido procesados.',
                        style: NexusText.caption.copyWith(color: NexusColors.inkSecondary)),
                  ],
                ),
              )
            else ...[
              Container(
                decoration: BoxDecoration(
                  color: NexusColors.surface,
                  border: Border.all(color: NexusColors.border, width: NexusSizes.borderWidth),
                  borderRadius: BorderRadius.circular(NexusSizes.radiusLG),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        NexusSizes.spaceLG, NexusSizes.spaceMD,
                        NexusSizes.spaceLG, NexusSizes.spaceMD,
                      ),
                      child: Text(
                        'Partes de seguimiento',
                        style: NexusText.label.copyWith(
                          color: NexusColors.inkSecondary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.5, color: NexusColors.border),
                    ...pendientes.asMap().entries.map((e) {
                      final isLast = e.key == pendientes.length - 1;
                      final practica = provider.practicaDe(e.value.practicaId);
                      return _ParteItem(
                        seguimiento: e.value,
                        alumnoNombre: practica?.alumnoNombre ?? 'Alumno',
                        isLast: isLast,
                        onValidar: () => _confirmarValidar(e.value.id),
                        onRechazar: () => _mostrarModalRechazo(e.value.id),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: NexusSizes.spaceLG),
              Container(
                padding: const EdgeInsets.all(NexusSizes.spaceMD),
                decoration: BoxDecoration(
                  color: NexusColors.primaryLight,
                  border: Border.all(color: const Color(0xFFB5D4F4), width: 0.5),
                  borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
                ),
                child: Text(
                  'Al rechazar un parte deberás indicar el motivo. El tutor del centro será notificado automáticamente.',
                  style: NexusText.small.copyWith(color: NexusColors.primaryText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(AuthProvider auth) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
            top: BorderSide(color: NexusColors.border, width: NexusSizes.borderWidth)),
      ),
      child: BottomAppBar(
        color: NexusColors.surface,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: NexusSizes.spaceSM),
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: NexusColors.success,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.star_outline, size: 12, color: Colors.white),
                ),
                const SizedBox(width: NexusSizes.spaceMD),
                Text('Partes', style: NexusText.caption.copyWith(color: NexusColors.success, fontWeight: FontWeight.w600)),
              ],
            ),
            TextButton.icon(
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout_outlined, size: 16, color: NexusColors.inkTertiary),
              label: Text('Salir', style: NexusText.caption.copyWith(color: NexusColors.inkSecondary)),
            ),
          ],
        ),
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
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: NexusColors.success),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Validar y firmar'),
          ),
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
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: NexusColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(NexusSizes.radiusLG)),
        ),
        builder: (ctx) => Padding(
          padding: EdgeInsets.fromLTRB(
            NexusSizes.space2XL, NexusSizes.space2XL,
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
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'El motivo es obligatorio' : null,
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
                        style: FilledButton.styleFrom(backgroundColor: NexusColors.danger),
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
    } finally {
      motivoController.dispose();
    }
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final AuthProvider auth;
  const _Sidebar({required this.auth});

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(auth.user?.nombreCompleto ?? '');
    return Container(
      width: 52,
      decoration: const BoxDecoration(
        color: NexusColors.surface,
        border: Border(
            right: BorderSide(color: NexusColors.border, width: NexusSizes.borderWidth)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Logo Nexus
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: NexusColors.success,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.star_outline, size: 14, color: Colors.white),
          ),
          const SizedBox(height: 10),
          // Icono partes (único, activo)
          Tooltip(
            message: 'Partes pendientes',
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: NexusColors.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.list_alt_outlined, size: 17, color: NexusColors.success),
            ),
          ),
          const Spacer(),
          // Avatar (solo informativo)
          Tooltip(
            message: auth.user?.nombreCompleto ?? '',
            child: CircleAvatar(
              radius: 15,
              backgroundColor: NexusColors.successLight,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: NexusColors.successText,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Logout explícito
          Tooltip(
            message: 'Cerrar sesión',
            child: IconButton(
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout_outlined, size: 18, color: NexusColors.inkSecondary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _getInitials(String nombre) {
    final parts = nombre.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color valueColor;
  final Color labelColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.bg,
    required this.valueColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: NexusSizes.spaceMD, horizontal: NexusSizes.spaceSM),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w500, color: valueColor)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: labelColor),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Parte item ────────────────────────────────────────────────────────────────

class _ParteItem extends StatelessWidget {
  final Seguimiento seguimiento;
  final String alumnoNombre;
  final bool isLast;
  final VoidCallback onValidar;
  final VoidCallback onRechazar;

  const _ParteItem({
    required this.seguimiento,
    required this.alumnoNombre,
    required this.isLast,
    required this.onValidar,
    required this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('d MMM yyyy', 'es_ES').format(seguimiento.fechaRegistro);
    final initials = alumnoNombre.trim().split(' ').where((p) => p.isNotEmpty).take(2)
        .map((p) => p[0].toUpperCase()).join();

    return Container(
      padding: const EdgeInsets.all(NexusSizes.spaceLG),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: NexusColors.border, width: NexusSizes.borderWidth)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: NexusColors.primaryLight,
            child: Text(initials,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: NexusColors.primaryText)),
          ),
          const SizedBox(width: NexusSizes.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(alumnoNombre,
                          style: NexusText.small.copyWith(fontWeight: FontWeight.w500)),
                    ),
                    nexusEstadoBadge('Pendiente firma',
                        bg: NexusColors.warningLight, textColor: NexusColors.warningText),
                  ],
                ),
                const SizedBox(height: NexusSizes.spaceXS),
                Text(
                  '$fecha · ${seguimiento.horasRealizadas}h',
                  style: NexusText.caption.copyWith(color: NexusColors.inkSecondary),
                ),
                if (seguimiento.descripcion != null &&
                    seguimiento.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: NexusSizes.spaceSM),
                  Container(
                    padding: const EdgeInsets.all(NexusSizes.spaceSM),
                    decoration: BoxDecoration(
                      color: NexusColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(NexusSizes.radiusSM),
                    ),
                    child: Text(
                      '"${seguimiento.descripcion}"',
                      style: NexusText.small.copyWith(color: NexusColors.inkSecondary),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: NexusSizes.spaceMD),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRechazar,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: NexusColors.danger,
                          side: const BorderSide(color: NexusColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: NexusSizes.spaceSM),
                        ),
                        child: const Text('Rechazar', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: NexusSizes.spaceSM),
                    Expanded(
                      child: FilledButton(
                        onPressed: onValidar,
                        style: FilledButton.styleFrom(
                          backgroundColor: NexusColors.success,
                          padding: const EdgeInsets.symmetric(vertical: NexusSizes.spaceSM),
                        ),
                        child: const Text('Validar y firmar',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
