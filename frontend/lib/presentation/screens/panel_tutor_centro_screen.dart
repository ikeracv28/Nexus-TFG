import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/incidencia_model.dart';
import '../../data/models/practica_model.dart';
import '../../data/models/seguimiento_model.dart';
import '../providers/auth_provider.dart';
import '../providers/tutor_centro_provider.dart';

// Modos del sidebar: alumnos = lista + detalle, partes = todos los partes, incidencias = todas
enum _Mode { alumnos, partes, incidencias }

class PanelTutorCentroScreen extends StatefulWidget {
  const PanelTutorCentroScreen({super.key});

  @override
  State<PanelTutorCentroScreen> createState() => _PanelTutorCentroScreenState();
}

class _PanelTutorCentroScreenState extends State<PanelTutorCentroScreen> {
  _Mode _mode = _Mode.alumnos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TutorCentroProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<TutorCentroProvider>();

    return Scaffold(
      backgroundColor: NexusColors.surfaceAlt,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          if (isWide) {
            return Row(
              children: [
                _Sidebar(
                  auth: auth,
                  provider: provider,
                  mode: _mode,
                  onChangeMode: (m) => setState(() => _mode = m),
                ),
                if (_mode == _Mode.alumnos) ...[
                  _StudentList(provider: provider),
                  const VerticalDivider(width: 1, thickness: 0.5, color: NexusColors.border),
                  Expanded(
                    child: _DetailPanel(
                      provider: provider,
                      auth: auth,
                      onValidar: _confirmarValidar,
                      onCambiarEstadoIncidencia: _mostrarModalEstado,
                    ),
                  ),
                ] else
                  Expanded(
                    child: _mode == _Mode.partes
                        ? _AllPartesPanel(
                            provider: provider,
                            onValidar: _confirmarValidar,
                          )
                        : _AllIncidenciasPanel(
                            provider: provider,
                            onCambiarEstado: _mostrarModalEstado,
                          ),
                  ),
              ],
            );
          }

          // Mobile: bottom nav + contenido
          return Column(
            children: [
              _MobileHeader(auth: auth),
              Expanded(child: _buildMobileBody(provider, auth)),
              _MobileBottomNav(
                mode: _mode,
                onChangeMode: (m) => setState(() {
                  _mode = m;
                  if (m != _Mode.alumnos) provider.seleccionar(-1);
                }),
                pendientePartes: provider.todosPendientesCentro.length,
                pendienteIncidencias:
                    provider.todasIncidencias.where((i) => i.estaAbierta).length,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileBody(TutorCentroProvider provider, AuthProvider auth) {
    switch (_mode) {
      case _Mode.partes:
        return _AllPartesPanel(provider: provider, onValidar: _confirmarValidar);
      case _Mode.incidencias:
        return _AllIncidenciasPanel(
            provider: provider, onCambiarEstado: _mostrarModalEstado);
      case _Mode.alumnos:
        if (provider.selectedPractica == null) {
          return _StudentList(provider: provider, isMobile: true);
        }
        return _DetailPanel(
          provider: provider,
          auth: auth,
          onValidar: _confirmarValidar,
          onCambiarEstadoIncidencia: _mostrarModalEstado,
          showBackButton: true,
          onBack: () => provider.seleccionar(-1),
        );
    }
  }

  Future<void> _confirmarValidar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dar visto bueno'),
        content: const Text('¿Confirmas que este parte cumple los requisitos formativos?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final ok = await context.read<TutorCentroProvider>().validarCentro(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(ok ? 'Parte completado correctamente' : 'Error al completar el parte'),
        backgroundColor: ok ? NexusColors.success : NexusColors.danger,
      ));
    }
  }

  Future<void> _mostrarModalEstado(Incidencia incidencia) async {
    final siguientes = _siguientesEstados(incidencia.estado);
    if (siguientes.isEmpty) return;

    final nuevoEstado = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: NexusColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(NexusSizes.radiusLG)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(NexusSizes.space2XL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestionar incidencia', style: NexusText.heading2),
            const SizedBox(height: NexusSizes.spaceXS),
            Text(
              incidencia.descripcion,
              style: NexusText.body.copyWith(color: NexusColors.inkSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: NexusSizes.spaceLG),
            ...siguientes.map((estado) => Padding(
                  padding: const EdgeInsets.only(bottom: NexusSizes.spaceSM),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, estado),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _colorEstado(estado),
                        side: BorderSide(color: _colorEstado(estado)),
                      ),
                      child: Text('Marcar como ${_labelEstado(estado)}'),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );

    if (nuevoEstado == null || !mounted) return;
    final ok = await context
        .read<TutorCentroProvider>()
        .actualizarEstadoIncidencia(incidencia.id, nuevoEstado);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Incidencia actualizada' : 'Error al actualizar'),
        backgroundColor: ok ? NexusColors.success : NexusColors.danger,
      ));
    }
  }

  List<String> _siguientesEstados(String actual) {
    const orden = ['ABIERTA', 'EN_PROCESO', 'RESUELTA', 'CERRADA'];
    final idx = orden.indexOf(actual);
    if (idx == -1 || idx >= orden.length - 1) return [];
    return orden.sublist(idx + 1);
  }

  String _labelEstado(String estado) {
    const labels = {
      'EN_PROCESO': 'En proceso',
      'RESUELTA': 'Resuelta',
      'CERRADA': 'Cerrada',
    };
    return labels[estado] ?? estado;
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'EN_PROCESO':
        return NexusColors.primary;
      case 'RESUELTA':
        return NexusColors.success;
      default:
        return NexusColors.inkSecondary;
    }
  }
}

// ── Sidebar funcional ─────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final AuthProvider auth;
  final TutorCentroProvider provider;
  final _Mode mode;
  final ValueChanged<_Mode> onChangeMode;
  const _Sidebar(
      {required this.auth,
      required this.provider,
      required this.mode,
      required this.onChangeMode});

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(auth.user?.nombreCompleto ?? '');
    final incidenciasAbiertas =
        provider.todasIncidencias.where((i) => i.estaAbierta).length;
    final partesAbiertas = provider.todosPendientesCentro.length;

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
          // Logo Nexus azul
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: NexusColors.primary,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.star_outline, size: 13, color: Colors.white),
          ),
          const SizedBox(height: 10),
          // Alumnos (modo por defecto)
          _SidebarBtn(
            icon: Icons.people_outlined,
            activeIcon: Icons.people,
            tooltip: 'Alumnos',
            isActive: mode == _Mode.alumnos,
            onTap: () => onChangeMode(_Mode.alumnos),
          ),
          const SizedBox(height: 4),
          // Partes pendientes
          _SidebarBadgeBtn(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            tooltip: 'Partes pendientes',
            isActive: mode == _Mode.partes,
            badgeCount: partesAbiertas,
            onTap: () => onChangeMode(_Mode.partes),
          ),
          const SizedBox(height: 4),
          // Incidencias
          _SidebarBadgeBtn(
            icon: Icons.warning_amber_outlined,
            activeIcon: Icons.warning_amber,
            tooltip: 'Incidencias',
            isActive: mode == _Mode.incidencias,
            badgeCount: incidenciasAbiertas,
            onTap: () => onChangeMode(_Mode.incidencias),
          ),
          const Spacer(),
          // Avatar informativo
          Tooltip(
            message: auth.user?.nombreCompleto ?? '',
            child: CircleAvatar(
              radius: 15,
              backgroundColor: NexusColors.successLight,
              child: Text(
                initials,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: NexusColors.successText),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Logout
          Tooltip(
            message: 'Cerrar sesión',
            child: IconButton(
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout_outlined,
                  size: 18, color: NexusColors.inkSecondary),
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

class _SidebarBtn extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;
  const _SidebarBtn(
      {required this.icon,
      required this.activeIcon,
      required this.tooltip,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isActive ? NexusColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isActive ? activeIcon : icon,
            size: 17,
            color: isActive ? NexusColors.primary : NexusColors.inkSecondary,
          ),
        ),
      ),
    );
  }
}

class _SidebarBadgeBtn extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String tooltip;
  final bool isActive;
  final int badgeCount;
  final VoidCallback onTap;
  const _SidebarBadgeBtn(
      {required this.icon,
      required this.activeIcon,
      required this.tooltip,
      required this.isActive,
      required this.badgeCount,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isActive ? NexusColors.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 17,
                color: isActive ? NexusColors.primary : NexusColors.inkSecondary,
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: badgeCount > 0
                        ? (tooltip.contains('Incidencia')
                            ? NexusColors.danger
                            : NexusColors.warning)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: NexusColors.surface, width: 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Student list ──────────────────────────────────────────────────────────────

class _StudentList extends StatelessWidget {
  final TutorCentroProvider provider;
  final bool isMobile;
  const _StudentList({required this.provider, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return Container(
        width: isMobile ? double.infinity : 220,
        color: NexusColors.surface,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final practicas = provider.practicas;

    return Container(
      width: isMobile ? double.infinity : 220,
      decoration: const BoxDecoration(
        color: NexusColors.surface,
        border: Border(
          right: BorderSide(color: NexusColors.border, width: NexusSizes.borderWidth),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: NexusColors.border, width: NexusSizes.borderWidth)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mis alumnos',
                    style: NexusText.small.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  '${practicas.length} en prácticas activas',
                  style: NexusText.caption.copyWith(color: NexusColors.inkSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: practicas.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(NexusSizes.spaceLG),
                      child: Text(
                        'Sin alumnos asignados',
                        style:
                            NexusText.caption.copyWith(color: NexusColors.inkSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: practicas.length,
                    itemBuilder: (context, index) {
                      final p = practicas[index];
                      return _StudentItem(
                        practica: p,
                        isSelected: provider.selectedPracticaId == p.id,
                        pendientesCentro: provider.pendientesCentroDe(p.id).length,
                        incidenciasAbiertas: provider
                            .incidenciasDe(p.id)
                            .where((i) => i.estaAbierta)
                            .length,
                        onTap: () => provider.seleccionar(p.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StudentItem extends StatelessWidget {
  final Practica practica;
  final bool isSelected;
  final int pendientesCentro;
  final int incidenciasAbiertas;
  final VoidCallback onTap;

  const _StudentItem({
    required this.practica,
    required this.isSelected,
    required this.pendientesCentro,
    required this.incidenciasAbiertas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(practica.alumnoNombre);
    final Color selBg = isSelected ? NexusColors.primaryLight : Colors.transparent;

    Widget badge;
    if (incidenciasAbiertas > 0) {
      badge = _ListBadge(
          label: '!$incidenciasAbiertas',
          bg: NexusColors.dangerLight,
          textColor: NexusColors.dangerText);
    } else if (pendientesCentro > 0) {
      badge = _ListBadge(
          label: 'Rev.',
          bg: NexusColors.warningLight,
          textColor: NexusColors.warningText);
    } else {
      badge = _ListBadge(
          label: 'OK',
          bg: NexusColors.successLight,
          textColor: NexusColors.successText);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: selBg,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: NexusColors.border, width: NexusSizes.borderWidth)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor:
                  isSelected ? NexusColors.primary : NexusColors.primaryLight,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : NexusColors.primaryText,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    practica.alumnoNombre,
                    style: NexusText.small.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? NexusColors.primary : NexusColors.ink,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    practica.empresaNombre,
                    style: NexusText.caption.copyWith(
                      color: isSelected
                          ? NexusColors.primary
                          : NexusColors.inkSecondary,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            badge,
          ],
        ),
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

class _ListBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;
  const _ListBadge(
      {required this.label, required this.bg, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NexusSizes.radiusFull),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500, color: textColor)),
    );
  }
}

// ── All partes panel ──────────────────────────────────────────────────────────

class _AllPartesPanel extends StatelessWidget {
  final TutorCentroProvider provider;
  final void Function(int) onValidar;
  const _AllPartesPanel({required this.provider, required this.onValidar});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pendientes = provider.todosPendientesCentro;

    if (pendientes.isEmpty) {
      return _EmptyState(
        icon: Icons.check_circle_outline,
        mensaje: 'Sin partes pendientes',
        detalle: 'Todos los partes han sido procesados.',
        iconColor: Color.fromRGBO(59, 109, 17, 0.5),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TutorCentroProvider>().cargar(),
      child: ListView.separated(
        padding: const EdgeInsets.all(NexusSizes.spaceLG),
        itemCount: pendientes.length,
        separatorBuilder: (_, __) => const SizedBox(height: NexusSizes.spaceMD),
        itemBuilder: (context, index) {
          final s = pendientes[index];
          final practica = provider.practicaDe(s.practicaId);
          return _ParteCard(
            seguimiento: s,
            alumnoNombre: practica?.alumnoNombre ?? 'Alumno',
            empresaNombre: practica?.empresaNombre ?? '',
            onValidar: () => onValidar(s.id),
          );
        },
      ),
    );
  }
}

class _ParteCard extends StatelessWidget {
  final Seguimiento seguimiento;
  final String alumnoNombre;
  final String empresaNombre;
  final VoidCallback onValidar;

  const _ParteCard({
    required this.seguimiento,
    required this.alumnoNombre,
    required this.empresaNombre,
    required this.onValidar,
  });

  @override
  Widget build(BuildContext context) {
    final fecha =
        DateFormat('d MMM yyyy', 'es_ES').format(seguimiento.fechaRegistro);

    return Container(
      decoration: BoxDecoration(
        color: NexusColors.surface,
        border:
            Border.all(color: NexusColors.border, width: NexusSizes.borderWidth),
        borderRadius: BorderRadius.circular(NexusSizes.radiusLG),
      ),
      padding: const EdgeInsets.all(NexusSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(alumnoNombre,
                      style: NexusText.heading3, overflow: TextOverflow.ellipsis)),
              nexusEstadoBadge('Pendiente centro',
                  bg: NexusColors.primaryLight, textColor: NexusColors.primaryText),
            ],
          ),
          if (empresaNombre.isNotEmpty) ...[
            const SizedBox(height: NexusSizes.spaceXS),
            Text(empresaNombre,
                style:
                    NexusText.caption.copyWith(color: NexusColors.inkSecondary)),
          ],
          const SizedBox(height: NexusSizes.spaceMD),
          const Divider(color: NexusColors.border, height: 1),
          const SizedBox(height: NexusSizes.spaceMD),
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
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onValidar,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Dar visto bueno'),
              style: FilledButton.styleFrom(backgroundColor: NexusColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

// ── All incidencias panel ─────────────────────────────────────────────────────

class _AllIncidenciasPanel extends StatelessWidget {
  final TutorCentroProvider provider;
  final void Function(Incidencia) onCambiarEstado;
  const _AllIncidenciasPanel(
      {required this.provider, required this.onCambiarEstado});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final incidencias = provider.todasIncidencias;

    if (incidencias.isEmpty) {
      return _EmptyState(
        icon: Icons.shield_outlined,
        mensaje: 'Sin incidencias',
        detalle: 'No hay incidencias registradas.',
        iconColor: Color.fromRGBO(24, 95, 165, 0.4),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TutorCentroProvider>().cargar(),
      child: ListView.separated(
        padding: const EdgeInsets.all(NexusSizes.spaceLG),
        itemCount: incidencias.length,
        separatorBuilder: (_, __) => const SizedBox(height: NexusSizes.spaceMD),
        itemBuilder: (context, index) {
          final inc = incidencias[index];
          final practica = provider.practicaDe(inc.practicaId);
          return _IncidenciaCard(
            incidencia: inc,
            alumnoNombre: practica?.alumnoNombre ?? 'Alumno',
            onCambiarEstado:
                inc.estado == 'CERRADA' ? null : () => onCambiarEstado(inc),
          );
        },
      ),
    );
  }
}

class _IncidenciaCard extends StatelessWidget {
  final Incidencia incidencia;
  final String alumnoNombre;
  final VoidCallback? onCambiarEstado;

  const _IncidenciaCard({
    required this.incidencia,
    required this.alumnoNombre,
    this.onCambiarEstado,
  });

  @override
  Widget build(BuildContext context) {
    final fecha =
        DateFormat('d MMM yyyy', 'es_ES').format(incidencia.fechaCreacion);

    Color bg, textColor;
    switch (incidencia.estado) {
      case 'ABIERTA':
        bg = NexusColors.dangerLight;
        textColor = NexusColors.dangerText;
        break;
      case 'EN_PROCESO':
        bg = NexusColors.primaryLight;
        textColor = NexusColors.primaryText;
        break;
      case 'RESUELTA':
        bg = NexusColors.successLight;
        textColor = NexusColors.successText;
        break;
      default:
        bg = NexusColors.neutralLight;
        textColor = NexusColors.neutralText;
    }

    final label = const {
          'ABIERTA': 'Abierta',
          'EN_PROCESO': 'En proceso',
          'RESUELTA': 'Resuelta',
          'CERRADA': 'Cerrada',
        }[incidencia.estado] ??
        incidencia.estado;

    return Container(
      decoration: BoxDecoration(
        color: NexusColors.surface,
        border:
            Border.all(color: NexusColors.border, width: NexusSizes.borderWidth),
        borderRadius: BorderRadius.circular(NexusSizes.radiusLG),
      ),
      padding: const EdgeInsets.all(NexusSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(alumnoNombre,
                      style: NexusText.heading3, overflow: TextOverflow.ellipsis)),
              nexusEstadoBadge(label, bg: bg, textColor: textColor),
            ],
          ),
          if (incidencia.tipo != null) ...[
            const SizedBox(height: NexusSizes.spaceXS),
            Text(incidencia.tipo!,
                style:
                    NexusText.caption.copyWith(color: NexusColors.inkSecondary)),
          ],
          const SizedBox(height: NexusSizes.spaceMD),
          const Divider(color: NexusColors.border, height: 1),
          const SizedBox(height: NexusSizes.spaceMD),
          Text(
            incidencia.descripcion,
            style: NexusText.body.copyWith(color: NexusColors.inkSecondary),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: NexusSizes.spaceXS),
          Text(fecha,
              style: NexusText.caption.copyWith(color: NexusColors.inkTertiary)),
          if (onCambiarEstado != null) ...[
            const SizedBox(height: NexusSizes.spaceLG),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCambiarEstado,
                child: const Text('Cambiar estado'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Detail panel ──────────────────────────────────────────────────────────────

class _DetailPanel extends StatelessWidget {
  final TutorCentroProvider provider;
  final AuthProvider auth;
  final void Function(int id) onValidar;
  final void Function(Incidencia) onCambiarEstadoIncidencia;
  final bool showBackButton;
  final VoidCallback? onBack;

  const _DetailPanel({
    required this.provider,
    required this.auth,
    required this.onValidar,
    required this.onCambiarEstadoIncidencia,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => context.read<TutorCentroProvider>().cargar(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final practica = provider.selectedPractica;
    if (practica == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 56, color: NexusColors.border),
            const SizedBox(height: NexusSizes.spaceLG),
            Text('Selecciona un alumno', style: NexusText.heading3),
            const SizedBox(height: NexusSizes.spaceXS),
            Text(
              'Elige un alumno de la lista para ver su seguimiento.',
              style: NexusText.body.copyWith(color: NexusColors.inkSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final pendientes = provider.pendientesCentroDe(practica.id);
    final incidencias = provider.incidenciasDe(practica.id);
    final horasCompletadas = provider.horasCompletadasDe(practica.id);
    final horasTotales = practica.horasTotales ?? 240;
    final progreso =
        horasTotales > 0 ? (horasCompletadas / horasTotales).clamp(0.0, 1.0) : 0.0;

    return RefreshIndicator(
      onRefresh: () => context.read<TutorCentroProvider>().cargar(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header alumno
            Row(
              children: [
                if (showBackButton) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    onPressed: onBack,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: NexusSizes.spaceSM),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(practica.alumnoNombre,
                          style: NexusText.small
                              .copyWith(fontWeight: FontWeight.w500, fontSize: 14)),
                      Text(
                        '${practica.empresaNombre} · ${practica.codigo}',
                        style: NexusText.caption
                            .copyWith(color: NexusColors.inkSecondary),
                      ),
                    ],
                  ),
                ),
                nexusEstadoBadge(
                  practica.estado == 'ACTIVA' ? 'En curso' : practica.estado,
                  bg: practica.estado == 'ACTIVA'
                      ? NexusColors.primaryLight
                      : NexusColors.neutralLight,
                  textColor: practica.estado == 'ACTIVA'
                      ? NexusColors.primaryText
                      : NexusColors.neutralText,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Barra de progreso
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progreso FCT',
                    style: NexusText.caption
                        .copyWith(color: NexusColors.inkSecondary)),
                Text('$horasCompletadas / ${horasTotales}h',
                    style: NexusText.caption
                        .copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progreso,
                minHeight: 5,
                backgroundColor: NexusColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(NexusColors.primary),
              ),
            ),
            const SizedBox(height: 14),

            // Partes pendientes
            if (pendientes.isNotEmpty) ...[
              _SectionCard(
                label: 'Seguimiento pendiente de validar',
                child: Column(
                  children: pendientes.asMap().entries.map((e) {
                    final isLast = e.key == pendientes.length - 1;
                    return _ParteRow(
                      seguimiento: e.value,
                      isLast: isLast,
                      onValidar: () => onValidar(e.value.id),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Incidencias abiertas
            ...incidencias.where((i) => i.estaAbierta).map((inc) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _IncidenciaDetailCard(
                    incidencia: inc,
                    onGestionar: () => onCambiarEstadoIncidencia(inc),
                  ),
                )),

            // Chat placeholder
            _SectionCard(
              label: 'Chat',
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: NexusColors.primaryLight,
                        child: Text(
                          _getInitials(practica.alumnoNombre),
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: NexusColors.primaryText),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            color: NexusColors.surfaceAlt,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(2),
                            ),
                          ),
                          child: Text(
                            'El chat en tiempo real estará disponible en el Hito 4.',
                            style: NexusText.caption
                                .copyWith(color: NexusColors.inkSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: NexusColors.surfaceAlt,
                            border: Border.all(
                                color: NexusColors.border,
                                width: NexusSizes.borderWidth),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Escribe un mensaje...',
                            style: NexusText.caption
                                .copyWith(color: NexusColors.inkTertiary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: NexusColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded,
                            size: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _SectionCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NexusColors.surface,
        border:
            Border.all(color: NexusColors.border, width: NexusSizes.borderWidth),
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: NexusText.label.copyWith(
              color: NexusColors.inkSecondary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ── Parte row (en detail panel) ───────────────────────────────────────────────

class _ParteRow extends StatelessWidget {
  final Seguimiento seguimiento;
  final bool isLast;
  final VoidCallback onValidar;

  const _ParteRow(
      {required this.seguimiento, required this.isLast, required this.onValidar});

  @override
  Widget build(BuildContext context) {
    final fecha =
        DateFormat('d/MM', 'es_ES').format(seguimiento.fechaRegistro);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                    color: NexusColors.border, width: NexusSizes.borderWidth)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: NexusColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seguimiento.descripcion ?? 'Parte de seguimiento',
                  style: NexusText.small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$fecha · ${seguimiento.horasRealizadas}h · Validado por empresa',
                  style: NexusText.caption.copyWith(
                      color: NexusColors.inkSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 28,
            child: FilledButton(
              onPressed: onValidar,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                backgroundColor: NexusColors.primary,
                textStyle: const TextStyle(fontSize: 10),
                minimumSize: Size.zero,
              ),
              child: const Text('Validar'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Incidencia card en detail panel ──────────────────────────────────────────

class _IncidenciaDetailCard extends StatelessWidget {
  final Incidencia incidencia;
  final VoidCallback onGestionar;
  const _IncidenciaDetailCard(
      {required this.incidencia, required this.onGestionar});

  @override
  Widget build(BuildContext context) {
    final fecha =
        DateFormat('d/MM', 'es_ES').format(incidencia.fechaCreacion);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NexusColors.surface,
        border:
            Border.all(color: NexusColors.border, width: NexusSizes.borderWidth),
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'INCIDENCIA ABIERTA',
                  style: NexusText.label.copyWith(
                      color: NexusColors.inkSecondary, letterSpacing: 0.6),
                ),
              ),
              nexusEstadoBadge('Urgente',
                  bg: NexusColors.dangerLight, textColor: NexusColors.dangerText),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            incidencia.descripcion,
            style: NexusText.small.copyWith(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Reportada $fecha · ${incidencia.estaAbierta ? "Sin resolver" : incidencia.estado}',
            style: NexusText.caption.copyWith(color: NexusColors.inkSecondary),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onGestionar,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              textStyle: const TextStyle(fontSize: 11),
              minimumSize: Size.zero,
            ),
            child: const Text('Gestionar incidencia'),
          ),
        ],
      ),
    );
  }
}

// ── Mobile bottom nav ─────────────────────────────────────────────────────────

class _MobileBottomNav extends StatelessWidget {
  final _Mode mode;
  final ValueChanged<_Mode> onChangeMode;
  final int pendientePartes;
  final int pendienteIncidencias;
  const _MobileBottomNav(
      {required this.mode,
      required this.onChangeMode,
      required this.pendientePartes,
      required this.pendienteIncidencias});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NexusColors.surface,
        border: Border(
            top: BorderSide(
                color: NexusColors.border, width: NexusSizes.borderWidth)),
      ),
      child: Row(
        children: [
          _BottomNavItem(
            icon: Icons.people_outlined,
            activeIcon: Icons.people,
            label: 'Alumnos',
            isActive: mode == _Mode.alumnos,
            onTap: () => onChangeMode(_Mode.alumnos),
          ),
          _BottomNavItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            label: 'Partes${pendientePartes > 0 ? " ($pendientePartes)" : ""}',
            isActive: mode == _Mode.partes,
            onTap: () => onChangeMode(_Mode.partes),
          ),
          _BottomNavItem(
            icon: Icons.warning_amber_outlined,
            activeIcon: Icons.warning_amber,
            label: 'Incidencias${pendienteIncidencias > 0 ? " ($pendienteIncidencias)" : ""}',
            isActive: mode == _Mode.incidencias,
            onTap: () => onChangeMode(_Mode.incidencias),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _BottomNavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? NexusColors.primary : NexusColors.inkTertiary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color:
                      isActive ? NexusColors.primary : NexusColors.inkTertiary,
                  fontWeight:
                      isActive ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mobile header ─────────────────────────────────────────────────────────────

class _MobileHeader extends StatelessWidget {
  final AuthProvider auth;
  const _MobileHeader({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NexusColors.surface,
        border: Border(
            bottom: BorderSide(
                color: NexusColors.border, width: NexusSizes.borderWidth)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: NexusColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.star_outline, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Tutor Centro',
                style: NexusText.small.copyWith(fontWeight: FontWeight.w500)),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                size: 20, color: NexusColors.inkSecondary),
            tooltip: 'Cerrar sesión',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String mensaje;
  final String detalle;
  final Color? iconColor;

  const _EmptyState({
    required this.icon,
    required this.mensaje,
    required this.detalle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NexusSizes.space3XL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 64, color: iconColor ?? Color.fromRGBO(24, 95, 165, 0.4)),
            const SizedBox(height: NexusSizes.spaceLG),
            Text(mensaje, style: NexusText.heading2),
            const SizedBox(height: NexusSizes.spaceSM),
            Text(detalle,
                style: NexusText.body.copyWith(color: NexusColors.inkSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
