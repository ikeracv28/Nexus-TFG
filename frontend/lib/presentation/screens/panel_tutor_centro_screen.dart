import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../../data/models/ausencia_model.dart';
import '../../data/models/incidencia_model.dart';
import '../../data/models/practica_model.dart';
import '../../data/models/seguimiento_model.dart';
import '../providers/auth_provider.dart';
import '../providers/tutor_centro_provider.dart';
import 'chat_placeholder_screen.dart';
import 'ficha_alumno_screen.dart';
import 'perfil_screen.dart';
import 'notificaciones_screen.dart';
import '../widgets/nexus_avatar.dart';
import '../providers/notificacion_provider.dart';

enum _Mode { alumnos, partes, incidencias, chat, chatTutores }

class PanelTutorCentroScreen extends StatefulWidget {
  const PanelTutorCentroScreen({super.key});

  @override
  State<PanelTutorCentroScreen> createState() =>
      _PanelTutorCentroScreenState();
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
      backgroundColor: context.nxt.surfaceAlt,
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
                if (_mode == _Mode.alumnos || _mode == _Mode.chat || _mode == _Mode.chatTutores) ...[
                  _StudentList(provider: provider),
                  Expanded(
                    child: switch (_mode) {
                      _Mode.chat => ChatPlaceholderScreen(
                          key: ValueKey('alumno-${provider.selectedPractica?.id}'),
                          practicaId: provider.selectedPractica?.id,
                          canal: 'ALUMNO',
                        ),
                      _Mode.chatTutores => ChatPlaceholderScreen(
                          key: ValueKey('tutores-${provider.selectedPractica?.id}'),
                          practicaId: provider.selectedPractica?.id,
                          canal: 'TUTORES',
                        ),
                      _ => _DetailPanel(
                          provider: provider,
                          auth: auth,
                          onValidar: _confirmarValidar,
                          onCambiarEstadoIncidencia: _mostrarModalEstado,
                          onChatTap: () => setState(() => _mode = _Mode.chat),
                          onChatTutoresTap: () => setState(() => _mode = _Mode.chatTutores),
                        ),
                    },
                  ),
                ] else
                  Expanded(child: _buildWidePanel(provider)),
              ],
            );
          }

          // Mobile
          return Column(
            children: [
              _MobileHeader(auth: auth),
              Expanded(child: _buildMobileBody(provider, auth)),
              _MobileBottomNav(
                mode: _mode,
                onChangeMode: (m) => setState(() {
                  _mode = m;
                  if (m != _Mode.alumnos && m != _Mode.chat && m != _Mode.chatTutores) {
                    provider.seleccionar(-1);
                  }
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

  Widget _buildWidePanel(TutorCentroProvider provider) {
    switch (_mode) {
      case _Mode.partes:
        return _AllPartesPanel(provider: provider, onValidar: _confirmarValidar);
      case _Mode.incidencias:
        return _AllIncidenciasPanel(
            provider: provider, onCambiarEstado: _mostrarModalEstado);
      case _Mode.chat:
        return ChatPlaceholderScreen(
            key: ValueKey('alumno-${provider.selectedPractica?.id}'),
            practicaId: provider.selectedPractica?.id,
            canal: 'ALUMNO');
      case _Mode.chatTutores:
        return ChatPlaceholderScreen(
            key: ValueKey('tutores-${provider.selectedPractica?.id}'),
            practicaId: provider.selectedPractica?.id,
            canal: 'TUTORES');
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMobileBody(TutorCentroProvider provider, AuthProvider auth) {
    switch (_mode) {
      case _Mode.partes:
        return _AllPartesPanel(provider: provider, onValidar: _confirmarValidar);
      case _Mode.incidencias:
        return _AllIncidenciasPanel(
            provider: provider, onCambiarEstado: _mostrarModalEstado);
      case _Mode.chat:
        if (provider.selectedPractica == null) {
          return _StudentList(provider: provider, isMobile: true);
        }
        return ChatPlaceholderScreen(
          key: ValueKey('alumno-${provider.selectedPractica?.id}'),
          practicaId: provider.selectedPractica?.id,
          canal: 'ALUMNO',
        );
      case _Mode.chatTutores:
        if (provider.selectedPractica == null) {
          return _StudentList(provider: provider, isMobile: true);
        }
        return ChatPlaceholderScreen(
          key: ValueKey('tutores-${provider.selectedPractica?.id}'),
          practicaId: provider.selectedPractica?.id,
          canal: 'TUTORES',
        );
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
          onChatTap: () => setState(() => _mode = _Mode.chat),
          onChatTutoresTap: () => setState(() => _mode = _Mode.chatTutores),
        );
    }
  }

  Future<void> _confirmarValidar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dar visto bueno'),
        content: const Text(
            '¿Confirmas que este parte cumple los requisitos formativos?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final ok =
        await context.read<TutorCentroProvider>().validarCentro(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Parte completado correctamente'
            : 'Error al completar el parte'),
        backgroundColor: ok ? NexusColors.success : NexusColors.danger,
      ));
    }
  }

  Future<void> _mostrarModalEstado(Incidencia incidencia) async {
    final siguientes = _siguientesEstados(incidencia.estado);
    if (siguientes.isEmpty) return;

    final nuevoEstado = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.nxt.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(NexusSizes.radiusLG)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(NexusSizes.space2XL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestionar incidencia', style: NexusText.heading2),
            const SizedBox(height: NexusSizes.spaceXS),
            Text(incidencia.descripcion,
                style: NexusText.body
                    .copyWith(color: context.nxt.inkSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: NexusSizes.spaceLG),
            ...siguientes.map((estado) => Padding(
                  padding: const EdgeInsets.only(bottom: NexusSizes.spaceSM),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, estado),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _colorEstado(context, estado),
                        side: BorderSide(color: _colorEstado(context, estado)),
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

  Color _colorEstado(BuildContext context, String estado) {
    switch (estado) {
      case 'EN_PROCESO':
        return NexusColors.primary;
      case 'RESUELTA':
        return NexusColors.success;
      default:
        return context.nxt.inkSecondary;
    }
  }
}

// ── Sidebar ────────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final AuthProvider auth;
  final TutorCentroProvider provider;
  final _Mode mode;
  final ValueChanged<_Mode> onChangeMode;

  const _Sidebar({
    required this.auth,
    required this.provider,
    required this.mode,
    required this.onChangeMode,
  });

  @override
  Widget build(BuildContext context) {
    final incAbiertos =
        provider.todasIncidencias.where((i) => i.estaAbierta).length;
    final partesPendientes = provider.todosPendientesCentro.length;

    return Container(
      width: 52,
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border(
            right: BorderSide(
                color: context.nxt.border,
                width: NexusSizes.borderWidth)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: NexusColors.primary,
              borderRadius: BorderRadius.circular(7),
            ),
            child:
                const Icon(Icons.star_outline, size: 13, color: Colors.white),
          ),
          const SizedBox(height: 10),
          _NavBtn(
            icon: Icons.people_outlined,
            activeIcon: Icons.people,
            tooltip: 'Alumnos',
            isActive: mode == _Mode.alumnos,
            onTap: () => onChangeMode(_Mode.alumnos),
          ),
          const SizedBox(height: 4),
          _NavBadgeBtn(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            tooltip: 'Partes pendientes',
            isActive: mode == _Mode.partes,
            badgeCount: partesPendientes,
            badgeColor: NexusColors.warning,
            onTap: () => onChangeMode(_Mode.partes),
          ),
          const SizedBox(height: 4),
          _NavBadgeBtn(
            icon: Icons.warning_amber_outlined,
            activeIcon: Icons.warning_amber,
            tooltip: 'Incidencias',
            isActive: mode == _Mode.incidencias,
            badgeCount: incAbiertos,
            badgeColor: NexusColors.danger,
            onTap: () => onChangeMode(_Mode.incidencias),
          ),
          const SizedBox(height: 4),
          const Spacer(),
          Tooltip(
            message: 'Mi perfil',
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PerfilScreen())),
              child: NexusAvatar(
                userId: auth.user!.id,
                nombre: auth.user!.nombreCompleto,
                radius: 15,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Consumer<NotificacionProvider>(
            builder: (ctx, notifProv, _) {
              final count = notifProv.noLeidas;
              return Tooltip(
                message: 'Notificaciones',
                child: IconButton(
                  onPressed: () async {
                    await Navigator.push(ctx,
                        MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(
                          value: notifProv,
                          child: const NotificacionesScreen(),
                        )));
                    notifProv.cargar();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                  icon: Badge(
                    isLabelVisible: count > 0,
                    label: Text(count > 9 ? '9+' : '$count',
                        style: const TextStyle(fontSize: 10)),
                    child: Icon(Icons.notifications_none_outlined,
                        size: 18, color: ctx.nxt.inkSecondary),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Builder(builder: (ctx) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final iconColor = ctx.nxt.inkSecondary;
            return Column(children: [
              Tooltip(
                message: isDark ? 'Modo claro' : 'Modo oscuro',
                child: IconButton(
                  onPressed: () => ctx.read<ThemeProvider>().toggle(),
                  icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      size: 18, color: iconColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                ),
              ),
              Tooltip(
                message: 'Cerrar sesión',
                child: IconButton(
                  onPressed: () => auth.logout(),
                  icon: Icon(Icons.logout_outlined, size: 18, color: iconColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                ),
              ),
            ]);
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _getInitials(String nombre) {
    final parts =
        nombre.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBtn({
    required this.icon,
    required this.activeIcon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isActive ? NexusColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isActive ? activeIcon : icon,
            size: 17,
            color:
                isActive ? NexusColors.primary : context.nxt.inkSecondary,
          ),
        ),
      ),
    );
  }
}

class _NavBadgeBtn extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String tooltip;
  final bool isActive;
  final int badgeCount;
  final Color badgeColor;
  final VoidCallback onTap;

  const _NavBadgeBtn({
    required this.icon,
    required this.activeIcon,
    required this.tooltip,
    required this.isActive,
    required this.badgeCount,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color:
                    isActive ? NexusColors.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 17,
                color: isActive
                    ? NexusColors.primary
                    : context.nxt.inkSecondary,
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
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: context.nxt.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Student list ───────────────────────────────────────────────────────────────

class _StudentList extends StatelessWidget {
  final TutorCentroProvider provider;
  final bool isMobile;
  const _StudentList({required this.provider, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return Container(
        width: isMobile ? double.infinity : 220,
        color: context.nxt.surface,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final practicas = provider.practicas;

    return Container(
      width: isMobile ? double.infinity : 220,
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border(
          right: BorderSide(
              color: context.nxt.border, width: NexusSizes.borderWidth),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: context.nxt.border,
                      width: NexusSizes.borderWidth)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mis alumnos',
                    style: NexusText.small
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${practicas.length} en prácticas activas',
                  style: NexusText.caption
                      .copyWith(color: context.nxt.inkSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: practicas.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(NexusSizes.spaceLG),
                      child: Text('Sin alumnos asignados',
                          style: NexusText.caption
                              .copyWith(color: context.nxt.inkSecondary),
                          textAlign: TextAlign.center),
                    ),
                  )
                : ListView.builder(
                    itemCount: practicas.length,
                    itemBuilder: (context, i) {
                      final p = practicas[i];
                      return _StudentItem(
                        practica: p,
                        isSelected: provider.selectedPracticaId == p.id,
                        pendientesCentro:
                            provider.pendientesCentroDe(p.id).length,
                        incidenciasAbiertas: provider
                            .incidenciasDe(p.id)
                            .where((x) => x.estaAbierta)
                            .length,
                        ausenciasInjustificadas:
                            provider.ausenciasInjustificadasDe(p.id).length,
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
  final int ausenciasInjustificadas;
  final VoidCallback onTap;

  const _StudentItem({
    required this.practica,
    required this.isSelected,
    required this.pendientesCentro,
    required this.incidenciasAbiertas,
    required this.ausenciasInjustificadas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget badge;
    final alertaTotal = incidenciasAbiertas + ausenciasInjustificadas;
    if (alertaTotal > 0) {
      badge = _MiniPill(
          label: '!$alertaTotal',
          bg: NexusColors.dangerLight,
          textColor: NexusColors.dangerText);
    } else if (pendientesCentro > 0) {
      badge = _MiniPill(
          label: 'Rev.',
          bg: NexusColors.warningLight,
          textColor: NexusColors.warningText);
    } else {
      badge = _MiniPill(
          label: 'OK',
          bg: NexusColors.successLight,
          textColor: NexusColors.successText);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: isSelected ? NexusColors.primary : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: isSelected
                        ? NexusColors.primary.withAlpha(77)
                        : context.nxt.border,
                    width: NexusSizes.borderWidth)),
          ),
          child: Row(
            children: [
              NexusAvatar(
                userId: practica.alumnoId,
                nombre: practica.alumnoNombre,
                radius: 14,
                backgroundColor: isSelected ? Colors.white.withAlpha(51) : NexusColors.primaryLight,
                textColor: isSelected ? Colors.white : NexusColors.primaryText,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(practica.alumnoNombre,
                        style: NexusText.small.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : context.nxt.ink),
                        overflow: TextOverflow.ellipsis),
                    Text(practica.empresaNombre,
                        style: NexusText.caption.copyWith(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.white.withAlpha(179)
                                : context.nxt.inkSecondary),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              badge,
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String nombre) {
    final parts =
        nombre.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;
  const _MiniPill(
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
              fontSize: 10, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}

// ── Detail panel ───────────────────────────────────────────────────────────────

class _DetailPanel extends StatelessWidget {
  final TutorCentroProvider provider;
  final AuthProvider auth;
  final void Function(int) onValidar;
  final void Function(Incidencia) onCambiarEstadoIncidencia;
  final bool showBackButton;
  final VoidCallback? onBack;
  final VoidCallback? onChatTap;
  final VoidCallback? onChatTutoresTap;

  const _DetailPanel({
    required this.provider,
    required this.auth,
    required this.onValidar,
    required this.onCambiarEstadoIncidencia,
    this.showBackButton = false,
    this.onBack,
    this.onChatTap,
    this.onChatTutoresTap,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return _ErrorState(
          message: provider.error!,
          onRetry: () => context.read<TutorCentroProvider>().cargar());
    }

    final practica = provider.selectedPractica;
    if (practica == null) {
      return const _SelectPrompt();
    }

    final pendientes = provider.pendientesCentroDe(practica.id);
    final incidencias = provider.incidenciasDe(practica.id);
    final ausenciasInjustificadas = provider.ausenciasInjustificadasDe(practica.id);
    final horasCompletadas = provider.horasCompletadasDe(practica.id);
    final horasTotales = practica.horasTotales ?? 240;
    final progreso = horasTotales > 0
        ? (horasCompletadas / horasTotales).clamp(0.0, 1.0)
        : 0.0;
    final pct = (progreso * 100).round();

    return RefreshIndicator(
      onRefresh: () => context.read<TutorCentroProvider>().cargar(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Alumno header ─────────────────────────────────────────────
            Row(
              children: [
                if (showBackButton) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    onPressed: onBack,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(practica.alumnoNombre,
                          style: NexusText.heading2
                              .copyWith(letterSpacing: -0.3)),
                      const SizedBox(height: 2),
                      Text(
                        '${practica.empresaNombre} · ${practica.codigo}',
                        style: NexusText.body
                            .copyWith(color: context.nxt.inkSecondary),
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  label: practica.estado == 'ACTIVA'
                      ? 'En curso'
                      : practica.estado,
                  color: practica.estado == 'ACTIVA'
                      ? NexusColors.primary
                      : context.nxt.inkSecondary,
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Ver ficha completa',
                  child: IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FichaAlumnoScreen(practica: practica),
                      ),
                    ),
                    icon: Icon(Icons.open_in_new,
                        size: 18, color: context.nxt.inkSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Progreso FCT ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.nxt.surface,
                border: Border.all(
                    color: context.nxt.border,
                    width: NexusSizes.borderWidth),
                borderRadius:
                    BorderRadius.circular(NexusSizes.radiusMD),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progreso FCT',
                          style: NexusText.small
                              .copyWith(fontWeight: FontWeight.w600)),
                      Text('$horasCompletadas / ${horasTotales}h',
                          style: NexusText.small.copyWith(
                              color: context.nxt.inkSecondary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: context.nxt.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progreso,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                NexusColors.primary,
                                NexusColors.primary.withAlpha(179),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('$pct% completado',
                      style: NexusText.caption
                          .copyWith(color: context.nxt.inkSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Partes pendientes ─────────────────────────────────────────
            if (pendientes.isNotEmpty) ...[
              _SectionLabel(
                  label: 'PENDIENTE DE VALIDAR',
                  count: pendientes.length,
                  countColor: NexusColors.warning),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: context.nxt.surface,
                  border: Border.all(
                      color: context.nxt.border,
                      width: NexusSizes.borderWidth),
                  borderRadius:
                      BorderRadius.circular(NexusSizes.radiusMD),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
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
              const SizedBox(height: 16),
            ],

            // ── Incidencias abiertas ──────────────────────────────────────
            if (incidencias.where((i) => i.estaAbierta).isNotEmpty) ...[
              _SectionLabel(
                  label: 'INCIDENCIAS ABIERTAS',
                  count: incidencias.where((i) => i.estaAbierta).length,
                  countColor: NexusColors.danger),
              const SizedBox(height: 8),
              ...incidencias
                  .where((i) => i.estaAbierta)
                  .map((inc) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _IncidenciaDetailCard(
                          incidencia: inc,
                          onGestionar: () =>
                              onCambiarEstadoIncidencia(inc),
                        ),
                      )),
              const SizedBox(height: 6),
            ],

            // ── Ausencias injustificadas ──────────────────────────────────
            if (ausenciasInjustificadas.isNotEmpty) ...[
              _SectionLabel(
                  label: 'AUSENCIAS INJUSTIFICADAS',
                  count: ausenciasInjustificadas.length,
                  countColor: NexusColors.danger),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: context.nxt.surface,
                  border: Border.all(
                      color: context.nxt.border,
                      width: NexusSizes.borderWidth),
                  borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: ausenciasInjustificadas.asMap().entries.map((e) {
                    return _AusenciaInjustificadaRow(
                      ausencia: e.value,
                      isLast: e.key == ausenciasInjustificadas.length - 1,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Chat ──────────────────────────────────────────────────────
            _SectionLabel(label: 'COMUNICACIÓN'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onChatTap,
                    icon: const Icon(Icons.chat_bubble_outline, size: 15),
                    label: const Text('Chat alumno'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onChatTutoresTap,
                    icon: const Icon(Icons.supervisor_account_outlined, size: 15),
                    label: const Text('Chat empresa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NexusColors.success,
                      side: const BorderSide(color: NexusColors.success),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String nombre) {
    final parts =
        nombre.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ── All partes panel ───────────────────────────────────────────────────────────

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
        padding: const EdgeInsets.all(20),
        itemCount: pendientes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final s = pendientes[i];
          final practica = provider.practicaDe(s.practicaId);
          return _FullParteCard(
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

// ── All incidencias panel ──────────────────────────────────────────────────────

class _AllIncidenciasPanel extends StatelessWidget {
  final TutorCentroProvider provider;
  final void Function(Incidencia) onCambiarEstado;
  const _AllIncidenciasPanel(
      {required this.provider, required this.onCambiarEstado});

  static const _ordenEstados = ['ABIERTA', 'EN_PROCESO', 'RESUELTA', 'CERRADA'];
  static const _labelEstados = {
    'ABIERTA': 'Abiertas',
    'EN_PROCESO': 'En proceso',
    'RESUELTA': 'Resueltas',
    'CERRADA': 'Cerradas',
  };
  static const _colorEstados = {
    'ABIERTA': NexusColors.danger,
    'EN_PROCESO': NexusColors.primary,
    'RESUELTA': NexusColors.success,
    'CERRADA': NexusColors.inkTertiary,
  };

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final todas = provider.todasIncidencias;
    if (todas.isEmpty) {
      return _EmptyState(
        icon: Icons.shield_outlined,
        mensaje: 'Sin incidencias',
        detalle: 'No hay incidencias registradas.',
        iconColor: Color.fromRGBO(24, 95, 165, 0.4),
      );
    }

    // Agrupar por estado en el orden definido
    final grupos = <String, List<Incidencia>>{};
    for (final est in _ordenEstados) {
      final items = todas.where((i) => i.estado == est).toList();
      if (items.isNotEmpty) grupos[est] = items;
    }

    final abiertas = todas.where((i) => i.estaAbierta).length;

    return RefreshIndicator(
      onRefresh: () => context.read<TutorCentroProvider>().cargar(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Incidencias',
                          style: NexusText.heading2
                              .copyWith(letterSpacing: -0.3)),
                      Text('${todas.length} en total · $abiertas sin resolver',
                          style: NexusText.body
                              .copyWith(color: context.nxt.inkSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Grupos
            ...grupos.entries.map((entry) {
              final estado = entry.key;
              final items = entry.value;
              final color = _colorEstados[estado] ?? context.nxt.inkSecondary;
              final label = _labelEstados[estado] ?? estado;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiqueta de grupo
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label.toUpperCase(),
                        style: NexusText.label.copyWith(
                          color: color,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('${items.length}',
                          style: NexusText.label
                              .copyWith(color: context.nxt.inkTertiary)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Tabla/lista del grupo
                  Container(
                    decoration: BoxDecoration(
                      color: context.nxt.surface,
                      border: Border.all(
                          color: context.nxt.border,
                          width: NexusSizes.borderWidth),
                      borderRadius:
                          BorderRadius.circular(NexusSizes.radiusMD),
                    ),
                    child: Column(
                      children: items.asMap().entries.map((e) {
                        final isLast = e.key == items.length - 1;
                        final inc = e.value;
                        final practica =
                            provider.practicaDe(inc.practicaId);
                        return _IncidenciaRow(
                          incidencia: inc,
                          alumnoId: practica?.alumnoId ?? 0,
                          alumnoNombre:
                              practica?.alumnoNombre ?? 'Alumno',
                          accentColor: color,
                          isLast: isLast,
                          onGestionar: inc.estado == 'CERRADA'
                              ? null
                              : () => onCambiarEstado(inc),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Incidencia row (en vista de incidencias agrupadas) ────────────────────────

class _IncidenciaRow extends StatelessWidget {
  final Incidencia incidencia;
  final int alumnoId;
  final String alumnoNombre;
  final Color accentColor;
  final bool isLast;
  final VoidCallback? onGestionar;

  const _IncidenciaRow({
    required this.incidencia,
    required this.alumnoId,
    required this.alumnoNombre,
    required this.accentColor,
    required this.isLast,
    this.onGestionar,
  });

  @override
  Widget build(BuildContext context) {
    final fecha =
        DateFormat('d MMM', 'es_ES').format(incidencia.fechaCreacion);

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color: context.nxt.border,
                    width: NexusSizes.borderWidth)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dot de color
          Container(
            width: 3,
            height: 36,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          NexusAvatar(userId: alumnoId, nombre: alumnoNombre, radius: 14),
          const SizedBox(width: 10),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alumnoNombre,
                    style: NexusText.small
                        .copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text(
                  incidencia.descripcion,
                  style: NexusText.caption
                      .copyWith(color: context.nxt.inkSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Fecha + acción
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fecha,
                  style: NexusText.caption
                      .copyWith(color: context.nxt.inkTertiary, fontSize: 10)),
              if (onGestionar != null) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: onGestionar,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: context.nxt.border,
                          width: NexusSizes.borderWidth),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Gestionar',
                        style: NexusText.caption.copyWith(fontSize: 10)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Full parte card (en modo Partes) ──────────────────────────────────────────

class _FullParteCard extends StatelessWidget {
  final Seguimiento seguimiento;
  final String alumnoNombre;
  final String empresaNombre;
  final VoidCallback onValidar;

  const _FullParteCard({
    required this.seguimiento,
    required this.alumnoNombre,
    required this.empresaNombre,
    required this.onValidar,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('d MMM yyyy', 'es_ES')
        .format(seguimiento.fechaRegistro);

    return Container(
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border(left: BorderSide(color: NexusColors.primary, width: 3)),
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(alumnoNombre,
                      style: NexusText.small
                          .copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis)),
              nexusEstadoBadge('Pendiente centro',
                  bg: NexusColors.primaryLight,
                  textColor: NexusColors.primaryText),
            ],
          ),
          if (empresaNombre.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(empresaNombre,
                style: NexusText.caption
                    .copyWith(color: context.nxt.inkSecondary)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 13, color: context.nxt.inkTertiary),
              const SizedBox(width: 4),
              Text(fecha, style: NexusText.caption),
              const SizedBox(width: 14),
              Icon(Icons.access_time_outlined,
                  size: 13, color: context.nxt.inkTertiary),
              const SizedBox(width: 4),
              Text('${seguimiento.horasRealizadas} h',
                  style: NexusText.caption),
            ],
          ),
          if (seguimiento.descripcion != null &&
              seguimiento.descripcion!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(seguimiento.descripcion!,
                style: NexusText.body
                    .copyWith(color: context.nxt.inkSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onValidar,
              icon: const Icon(Icons.check, size: 15),
              label: const Text('Dar visto bueno',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              style: FilledButton.styleFrom(
                  backgroundColor: NexusColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full incidencia card ───────────────────────────────────────────────────────

class _FullIncidenciaCard extends StatelessWidget {
  final Incidencia incidencia;
  final String alumnoNombre;
  final VoidCallback? onCambiarEstado;

  const _FullIncidenciaCard({
    required this.incidencia,
    required this.alumnoNombre,
    this.onCambiarEstado,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('d MMM yyyy', 'es_ES')
        .format(incidencia.fechaCreacion);

    Color accentColor;
    Color bgColor;
    Color textColor;
    String label;

    switch (incidencia.estado) {
      case 'ABIERTA':
        accentColor = NexusColors.danger;
        bgColor = NexusColors.dangerLight;
        textColor = NexusColors.dangerText;
        label = 'Abierta';
        break;
      case 'EN_PROCESO':
        accentColor = NexusColors.primary;
        bgColor = NexusColors.primaryLight;
        textColor = NexusColors.primaryText;
        label = 'En proceso';
        break;
      case 'RESUELTA':
        accentColor = NexusColors.success;
        bgColor = NexusColors.successLight;
        textColor = NexusColors.successText;
        label = 'Resuelta';
        break;
      default:
        accentColor = NexusColors.inkSecondary;
        bgColor = context.nxt.surfaceAlt;
        textColor = NexusColors.neutralText;
        label = incidencia.estado;
    }

    return Container(
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border(left: BorderSide(color: accentColor, width: 3)),
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(alumnoNombre,
                      style: NexusText.small
                          .copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis)),
              nexusEstadoBadge(label, bg: bgColor, textColor: textColor),
            ],
          ),
          if (incidencia.tipo != null) ...[
            const SizedBox(height: 2),
            Text(incidencia.tipo!,
                style: NexusText.caption
                    .copyWith(color: context.nxt.inkSecondary)),
          ],
          const SizedBox(height: 8),
          Text(incidencia.descripcion,
              style: NexusText.body
                  .copyWith(color: context.nxt.inkSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(fecha,
              style: NexusText.caption
                  .copyWith(color: context.nxt.inkTertiary)),
          if (onCambiarEstado != null) ...[
            const SizedBox(height: 12),
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

// ── Parte row inline (en detail panel) ────────────────────────────────────────

class _ParteRow extends StatelessWidget {
  final Seguimiento seguimiento;
  final bool isLast;
  final VoidCallback onValidar;

  const _ParteRow({
    required this.seguimiento,
    required this.isLast,
    required this.onValidar,
  });

  @override
  Widget build(BuildContext context) {
    final fecha =
        DateFormat('d/MM', 'es_ES').format(seguimiento.fechaRegistro);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color: context.nxt.border,
                    width: NexusSizes.borderWidth)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: NexusColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
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
                      color: context.nxt.inkSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onValidar,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: NexusColors.primary,
              minimumSize: const Size(0, 30),
              textStyle: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500),
            ),
            child: const Text('Validar'),
          ),
        ],
      ),
    );
  }
}

// ── Incidencia card en detalle ─────────────────────────────────────────────────

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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border(
          left: const BorderSide(color: NexusColors.danger, width: 3),
          top: BorderSide(
              color: context.nxt.border, width: NexusSizes.borderWidth),
          right: BorderSide(
              color: context.nxt.border, width: NexusSizes.borderWidth),
          bottom: BorderSide(
              color: context.nxt.border, width: NexusSizes.borderWidth),
        ),
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 15, color: NexusColors.danger),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(incidencia.descripcion,
                      style: NexusText.small
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Reportada $fecha · Sin resolver',
              style: NexusText.caption
                  .copyWith(color: context.nxt.inkSecondary)),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onGestionar,
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

// ── Mobile bottom nav ──────────────────────────────────────────────────────────

class _MobileBottomNav extends StatelessWidget {
  final _Mode mode;
  final ValueChanged<_Mode> onChangeMode;
  final int pendientePartes;
  final int pendienteIncidencias;

  const _MobileBottomNav({
    required this.mode,
    required this.onChangeMode,
    required this.pendientePartes,
    required this.pendienteIncidencias,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border(
            top: BorderSide(
                color: context.nxt.border, width: NexusSizes.borderWidth)),
      ),
      child: Row(
        children: [
          _BottomItem(
            icon: Icons.people_outlined,
            activeIcon: Icons.people,
            label: 'Alumnos',
            isActive: mode == _Mode.alumnos,
            onTap: () => onChangeMode(_Mode.alumnos),
          ),
          _BottomItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            label: pendientePartes > 0 ? 'Partes ($pendientePartes)' : 'Partes',
            isActive: mode == _Mode.partes,
            onTap: () => onChangeMode(_Mode.partes),
          ),
          _BottomItem(
            icon: Icons.warning_amber_outlined,
            activeIcon: Icons.warning_amber,
            label: pendienteIncidencias > 0
                ? 'Incidencias ($pendienteIncidencias)'
                : 'Incidencias',
            isActive: mode == _Mode.incidencias,
            onTap: () => onChangeMode(_Mode.incidencias),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive
                    ? NexusColors.primary
                    : context.nxt.inkTertiary,
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: isActive
                          ? NexusColors.primary
                          : context.nxt.inkTertiary,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mobile header ──────────────────────────────────────────────────────────────

class _MobileHeader extends StatelessWidget {
  final AuthProvider auth;
  const _MobileHeader({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border(
            bottom: BorderSide(
                color: context.nxt.border, width: NexusSizes.borderWidth)),
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
            child: const Icon(Icons.star_outline,
                size: 12, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text('Tutor Centro',
                  style: NexusText.small
                      .copyWith(fontWeight: FontWeight.w600))),
          Builder(builder: (ctx) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            return IconButton(
              icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 20, color: context.nxt.inkSecondary),
              tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
              onPressed: () => ctx.read<ThemeProvider>().toggle(),
            );
          }),
          IconButton(
            icon: Icon(Icons.logout_outlined,
                size: 20, color: context.nxt.inkSecondary),
            tooltip: 'Cerrar sesión',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final int? count;
  final Color? countColor;

  const _SectionLabel({required this.label, this.count, this.countColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: NexusText.label.copyWith(
                color: context.nxt.inkTertiary, letterSpacing: 1.0)),
        if (count != null && count! > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: countColor?.withAlpha(26) ?? NexusColors.border,
              borderRadius: BorderRadius.circular(NexusSizes.radiusFull),
            ),
            child: Text('$count',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: countColor ?? context.nxt.inkSecondary)),
          ),
        ],
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color.withAlpha(77), width: 0.5),
        borderRadius: BorderRadius.circular(NexusSizes.radiusFull),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color)),
    );
  }
}

class _SelectPrompt extends StatelessWidget {
  const _SelectPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: NexusColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outlined,
                size: 30, color: NexusColors.primary),
          ),
          const SizedBox(height: 16),
          Text('Selecciona un alumno', style: NexusText.heading3),
          const SizedBox(height: 6),
          Text(
            'Elige un alumno de la lista para ver\nsu seguimiento y validar sus partes.',
            style: NexusText.body.copyWith(color: context.nxt.inkSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: NexusColors.danger),
          const SizedBox(height: NexusSizes.spaceLG),
          Text(message, style: NexusText.body),
          const SizedBox(height: NexusSizes.spaceLG),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

// ── Chat placeholder ───────────────────────────────────────────────────────────

class _ChatPlaceholder extends StatelessWidget {
  const _ChatPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: NexusColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline,
                size: 28, color: NexusColors.primary),
          ),
          const SizedBox(height: 16),
          Text('Chat', style: NexusText.heading3),
          const SizedBox(height: 6),
          Text(
            'El chat en tiempo real estará disponible\nen el Hito 4 con WebSocket/STOMP.',
            style: NexusText.body.copyWith(color: context.nxt.inkSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: NexusColors.primaryLight,
              border:
                  Border.all(color: const Color(0xFFB5D4F4), width: 0.5),
              borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: NexusColors.primaryText),
                const SizedBox(width: 8),
                Text(
                  'Pendiente: Hito 4',
                  style:
                      NexusText.small.copyWith(color: NexusColors.primaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ausencia injustificada row ─────────────────────────────────────────────────

class _AusenciaInjustificadaRow extends StatelessWidget {
  final Ausencia ausencia;
  final bool isLast;

  const _AusenciaInjustificadaRow({
    required this.ausencia,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('d/MM/yyyy', 'es_ES').format(ausencia.fecha);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color: context.nxt.border,
                    width: NexusSizes.borderWidth)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: NexusColors.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ausencia.motivo,
                  style: NexusText.small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$fecha · Revisada por ${ausencia.revisadaPorNombre ?? 'tutor empresa'}',
                  style: NexusText.caption.copyWith(
                      color: context.nxt.inkSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
                size: 64,
                color: iconColor ??
                    Color.fromRGBO(24, 95, 165, 0.4)),
            const SizedBox(height: NexusSizes.spaceLG),
            Text(mensaje, style: NexusText.heading2),
            const SizedBox(height: NexusSizes.spaceSM),
            Text(detalle,
                style: NexusText.body
                    .copyWith(color: context.nxt.inkSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Dashboard ──────────────────────────────────────────────────────────────────

class _VistaDashboard extends StatelessWidget {
  final TutorCentroProvider provider;
  const _VistaDashboard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final activas =
        provider.practicas.where((p) => p.estado == 'ACTIVA').length;
    final convenios =
        provider.practicas.map((p) => p.empresaNombre).toSet().length;
    final incAbiertas =
        provider.todasIncidencias.where((i) => i.estaAbierta).length;
    final partesValidar = provider.todosPendientesCentro.length;
    final incRecientes = provider.todasIncidencias.take(4).toList();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TutorCentroProvider>().cargar(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Panel del Centro Educativo',
                          style: NexusText.heading2
                              .copyWith(letterSpacing: -0.3)),
                      const SizedBox(height: 2),
                      Text(
                        'CampusFP · ${auth.user?.nombreCompleto ?? ''} · Tutor FCT',
                        style: NexusText.body
                            .copyWith(color: context.nxt.inkSecondary),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Las prácticas se crean desde el panel de administración'),
                      duration: Duration(seconds: 2),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Nueva práctica'),
                  style: OutlinedButton.styleFrom(
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stat cards
            Row(
              children: [
                _DashStatCard(
                    valor: activas,
                    label: 'Alumnos activos',
                    color: NexusColors.success),
                const SizedBox(width: 12),
                _DashStatCard(
                    valor: convenios,
                    label: 'Convenios activos',
                    color: NexusColors.primary),
                const SizedBox(width: 12),
                _DashStatCard(
                    valor: incAbiertas,
                    label: 'Incidencias abiertas',
                    color: NexusColors.danger),
                const SizedBox(width: 12),
                _DashStatCard(
                    valor: partesValidar,
                    label: 'Partes por validar',
                    color: NexusColors.warning),
              ],
            ),
            const SizedBox(height: 20),

            // Two-column layout
            LayoutBuilder(
              builder: (ctx, constraints) {
                if (constraints.maxWidth > 680) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 3,
                          child: _AlumnosYCarga(provider: provider)),
                      const SizedBox(width: 16),
                      Expanded(
                          flex: 2,
                          child: _IncidenciasRecientes(
                              incidencias: incRecientes,
                              provider: provider)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _AlumnosYCarga(provider: provider),
                    const SizedBox(height: 16),
                    _IncidenciasRecientes(
                        incidencias: incRecientes, provider: provider),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashStatCard extends StatelessWidget {
  final int valor;
  final String label;
  final Color color;
  const _DashStatCard(
      {required this.valor, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.nxt.surface,
          border: Border.all(
              color: context.nxt.border, width: NexusSizes.borderWidth),
          borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 4,
                offset: const Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$valor',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Text(label,
                style:
                    NexusText.caption.copyWith(color: context.nxt.inkSecondary),
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _AlumnosYCarga extends StatelessWidget {
  final TutorCentroProvider provider;
  const _AlumnosYCarga({required this.provider});

  @override
  Widget build(BuildContext context) {
    final practicas = provider.practicas;

    return Container(
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border.all(
            color: context.nxt.border, width: NexusSizes.borderWidth),
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Text('ALUMNOS Y CARGA',
                style: NexusText.label
                    .copyWith(color: context.nxt.inkTertiary, letterSpacing: 1.0)),
          ),
          Divider(
              height: 1,
              thickness: NexusSizes.borderWidth,
              color: context.nxt.border),
          if (practicas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Sin alumnos asignados',
                  style:
                      NexusText.body.copyWith(color: context.nxt.inkSecondary)),
            )
          else
            ...practicas.asMap().entries.map((e) {
              final p = e.value;
              final isLast = e.key == practicas.length - 1;
              final horas = provider.horasCompletadasDe(p.id);
              final total = p.horasTotales ?? 240;
              final progreso =
                  total > 0 ? (horas / total).clamp(0.0, 1.0) : 0.0;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(
                              color: context.nxt.border,
                              width: NexusSizes.borderWidth)),
                ),
                child: Row(
                  children: [
                    NexusAvatar(userId: p.alumnoId, nombre: p.alumnoNombre, radius: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.alumnoNombre,
                              style: NexusText.small
                                  .copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis),
                          Text(
                            '${p.empresaNombre} · ${horas}/${total}h',
                            style: NexusText.caption.copyWith(
                                color: context.nxt.inkSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: progreso,
                            backgroundColor: context.nxt.border,
                            color: progreso > 0.8
                                ? NexusColors.success
                                : NexusColors.primary,
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
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
}

class _IncidenciasRecientes extends StatelessWidget {
  final List<Incidencia> incidencias;
  final TutorCentroProvider provider;
  const _IncidenciasRecientes(
      {required this.incidencias, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.nxt.surface,
        border: Border.all(
            color: context.nxt.border, width: NexusSizes.borderWidth),
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Text('INCIDENCIAS RECIENTES',
                style: NexusText.label
                    .copyWith(color: context.nxt.inkTertiary, letterSpacing: 1.0)),
          ),
          Divider(
              height: 1,
              thickness: NexusSizes.borderWidth,
              color: context.nxt.border),
          if (incidencias.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Sin incidencias recientes',
                  style:
                      NexusText.body.copyWith(color: context.nxt.inkSecondary)),
            )
          else
            ...incidencias.asMap().entries.map((e) {
              final isLast = e.key == incidencias.length - 1;
              final inc = e.value;
              final practica = provider.practicaDe(inc.practicaId);
              final alumnoNombre = practica?.alumnoNombre ?? 'Alumno';
              final fecha =
                  DateFormat('d/MM', 'es_ES').format(inc.fechaCreacion);

              Color badgeBg;
              Color badgeText;
              String badgeLabel;
              switch (inc.estado) {
                case 'ABIERTA':
                  badgeBg = NexusColors.dangerLight;
                  badgeText = NexusColors.dangerText;
                  badgeLabel = 'Abierta';
                  break;
                case 'EN_PROCESO':
                  badgeBg = NexusColors.primaryLight;
                  badgeText = NexusColors.primaryText;
                  badgeLabel = 'Proceso';
                  break;
                case 'RESUELTA':
                  badgeBg = NexusColors.successLight;
                  badgeText = NexusColors.successText;
                  badgeLabel = 'Resuelta';
                  break;
                default:
                  badgeBg = const Color(0xFFF1EFE8);
                  badgeText = NexusColors.neutralText;
                  badgeLabel = 'Cerrada';
              }

              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(
                              color: context.nxt.border,
                              width: NexusSizes.borderWidth)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(top: 4, right: 10),
                      decoration: BoxDecoration(
                        color: inc.estaAbierta
                            ? NexusColors.danger
                            : NexusColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$alumnoNombre — ${inc.descripcion}',
                            style: NexusText.small
                                .copyWith(fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$fecha · ${practica?.tutorCentroNombre ?? ''}',
                            style: NexusText.caption.copyWith(
                                color: context.nxt.inkSecondary, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    nexusEstadoBadge(badgeLabel,
                        bg: badgeBg, textColor: badgeText),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
