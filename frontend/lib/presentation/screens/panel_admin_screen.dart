import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/usuario_model.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';

class PanelAdminScreen extends StatefulWidget {
  const PanelAdminScreen({super.key});

  @override
  State<PanelAdminScreen> createState() => _PanelAdminScreenState();
}

class _PanelAdminScreenState extends State<PanelAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().cargarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final esWeb = constraints.maxWidth > 600;
      return Scaffold(
        backgroundColor: NexusColors.surfaceAlt,
        body: esWeb ? _layoutWeb() : _layoutMovil(),
      );
    });
  }

  Widget _layoutWeb() {
    return Row(
      children: [
        _Sidebar(),
        Expanded(child: _Contenido()),
      ],
    );
  }

  Widget _layoutMovil() {
    return _Contenido();
  }
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      color: NexusColors.ink,
      child: Column(
        children: [
          const SizedBox(height: NexusSizes.space2XL),
          _IconSidebar(icon: Icons.people_alt_outlined, activo: true),
          const Spacer(),
          _IconSidebar(
            icon: Icons.logout,
            onTap: () => context.read<AuthProvider>().logout(),
          ),
          const SizedBox(height: NexusSizes.spaceLG),
        ],
      ),
    );
  }
}

class _IconSidebar extends StatelessWidget {
  final IconData icon;
  final bool activo;
  final VoidCallback? onTap;

  const _IconSidebar({required this.icon, this.activo = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 48,
        color: activo ? NexusColors.primary.withOpacity(0.25) : Colors.transparent,
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(),
        Expanded(child: _ListaUsuarios()),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: NexusColors.surface,
      padding: const EdgeInsets.symmetric(
          horizontal: NexusSizes.space3XL, vertical: NexusSizes.spaceLG),
      child: Row(
        children: [
          const Text('Gestión de Usuarios', style: NexusText.heading2),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => _mostrarDialogCrear(context),
            icon: const Icon(Icons.person_add_outlined, size: 16),
            label: const Text('Nuevo usuario'),
            style: FilledButton.styleFrom(
              backgroundColor: NexusColors.primary,
              padding: const EdgeInsets.symmetric(
                  horizontal: NexusSizes.spaceLG, vertical: NexusSizes.spaceMD),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogCrear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AdminProvider>(),
        child: const _DialogCrearUsuario(),
      ),
    );
  }
}

class _ListaUsuarios extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(builder: (context, admin, _) {
      if (admin.cargando) {
        return const Center(child: CircularProgressIndicator());
      }
      if (admin.error != null && admin.usuarios.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined,
                  size: 40, color: NexusColors.inkTertiary),
              const SizedBox(height: NexusSizes.spaceMD),
              Text(admin.error!, style: const TextStyle(color: NexusColors.inkSecondary)),
              const SizedBox(height: NexusSizes.spaceLG),
              OutlinedButton(
                  onPressed: () => admin.cargarUsuarios(),
                  child: const Text('Reintentar')),
            ],
          ),
        );
      }
      if (admin.usuarios.isEmpty) {
        return const Center(
          child: Text('No hay usuarios registrados.',
              style: TextStyle(color: NexusColors.inkSecondary)),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(NexusSizes.space2XL),
        itemCount: admin.usuarios.length,
        separatorBuilder: (_, __) => const SizedBox(height: NexusSizes.spaceSM),
        itemBuilder: (_, i) => _UsuarioCard(usuario: admin.usuarios[i]),
      );
    });
  }
}

class _UsuarioCard extends StatelessWidget {
  final UsuarioModel usuario;

  const _UsuarioCard({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NexusColors.surface,
        border: Border.all(color: NexusColors.border, width: NexusSizes.borderWidth),
        borderRadius: BorderRadius.circular(NexusSizes.radiusMD),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: NexusSizes.spaceLG, vertical: NexusSizes.spaceMD),
      child: Row(
        children: [
          _AvatarIniciales(nombre: usuario.nombreCompleto),
          const SizedBox(width: NexusSizes.spaceLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(usuario.nombreCompleto,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: NexusColors.ink)),
                const SizedBox(height: 2),
                Text(usuario.email,
                    style: const TextStyle(
                        fontSize: 12, color: NexusColors.inkSecondary)),
                Text(usuario.dni,
                    style: const TextStyle(
                        fontSize: 11, color: NexusColors.inkTertiary)),
              ],
            ),
          ),
          _ChipRol(rol: usuario.rolPrincipal),
          const SizedBox(width: NexusSizes.spaceMD),
          _ChipEstado(activo: usuario.activo),
          const SizedBox(width: NexusSizes.spaceMD),
          IconButton(
            icon: Icon(
              usuario.activo ? Icons.toggle_on : Icons.toggle_off,
              color: usuario.activo ? NexusColors.success : NexusColors.inkTertiary,
              size: 28,
            ),
            tooltip: usuario.activo ? 'Desactivar cuenta' : 'Activar cuenta',
            onPressed: () =>
                context.read<AdminProvider>().toggleActivo(usuario.id),
          ),
        ],
      ),
    );
  }
}

class _AvatarIniciales extends StatelessWidget {
  final String nombre;

  const _AvatarIniciales({required this.nombre});

  String get _iniciales {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: NexusColors.primaryLight,
      child: Text(_iniciales,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: NexusColors.primaryText)),
    );
  }
}

class _ChipRol extends StatelessWidget {
  final String rol;

  const _ChipRol({required this.rol});

  Color get _color {
    switch (rol) {
      case 'Admin':
        return NexusColors.danger;
      case 'Tutor Centro':
        return NexusColors.primary;
      case 'Tutor Empresa':
        return NexusColors.warning;
      default:
        return NexusColors.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: NexusSizes.spaceSM, vertical: NexusSizes.spaceXS),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(NexusSizes.radiusFull),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(rol,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: _color)),
    );
  }
}

class _ChipEstado extends StatelessWidget {
  final bool activo;

  const _ChipEstado({required this.activo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: NexusSizes.spaceSM, vertical: NexusSizes.spaceXS),
      decoration: BoxDecoration(
        color: activo ? NexusColors.successLight : NexusColors.neutralLight,
        borderRadius: BorderRadius.circular(NexusSizes.radiusFull),
      ),
      child: Text(
        activo ? 'Activo' : 'Inactivo',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: activo ? NexusColors.successText : NexusColors.neutralText),
      ),
    );
  }
}

// ---- Dialog de creación ----

class _DialogCrearUsuario extends StatefulWidget {
  const _DialogCrearUsuario();

  @override
  State<_DialogCrearUsuario> createState() => _DialogCrearUsuarioState();
}

class _DialogCrearUsuarioState extends State<_DialogCrearUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _dniCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _rolSeleccionado = 'ROLE_ALUMNO';
  bool _enviando = false;
  String? _error;

  static const _roles = [
    ('ROLE_ALUMNO', 'Alumno'),
    ('ROLE_TUTOR_CENTRO', 'Tutor Centro'),
    ('ROLE_TUTOR_EMPRESA', 'Tutor Empresa'),
    ('ROLE_ADMIN', 'Administrador'),
  ];

  @override
  void dispose() {
    _dniCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _error = null;
    });
    final ok = await context.read<AdminProvider>().crearUsuario(
          dni: _dniCtrl.text.trim(),
          nombre: _nombreCtrl.text.trim(),
          apellidos: _apellidosCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          rolNombre: _rolSeleccionado,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario creado correctamente'),
          backgroundColor: NexusColors.success,
        ),
      );
    } else {
      setState(() {
        _error = context.read<AdminProvider>().error;
        _enviando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo usuario', style: NexusText.heading3),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(NexusSizes.spaceMD),
                  decoration: BoxDecoration(
                    color: NexusColors.dangerLight,
                    borderRadius: BorderRadius.circular(NexusSizes.radiusSM),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(
                          color: NexusColors.dangerText, fontSize: 13)),
                ),
                const SizedBox(height: NexusSizes.spaceMD),
              ],
              Row(
                children: [
                  Expanded(child: _Campo(_nombreCtrl, 'Nombre', required: true)),
                  const SizedBox(width: NexusSizes.spaceMD),
                  Expanded(
                      child: _Campo(_apellidosCtrl, 'Apellidos', required: true)),
                ],
              ),
              const SizedBox(height: NexusSizes.spaceMD),
              Row(
                children: [
                  Expanded(child: _Campo(_dniCtrl, 'DNI', required: true)),
                  const SizedBox(width: NexusSizes.spaceMD),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _rolSeleccionado,
                      decoration: _inputDecoration('Rol'),
                      items: _roles
                          .map((r) => DropdownMenuItem(
                              value: r.$1, child: Text(r.$2)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _rolSeleccionado = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NexusSizes.spaceMD),
              _Campo(_emailCtrl, 'Email', keyboardType: TextInputType.emailAddress,
                  required: true,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Email inválido'
                      : null),
              const SizedBox(height: NexusSizes.spaceMD),
              _Campo(_passwordCtrl, 'Contraseña temporal',
                  obscure: true, required: true,
                  validator: (v) => (v == null || v.length < 8)
                      ? 'Mínimo 8 caracteres'
                      : null),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _enviando ? null : _enviar,
          style: FilledButton.styleFrom(backgroundColor: NexusColors.primary),
          child: _enviando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Crear usuario'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: NexusSizes.spaceMD, vertical: NexusSizes.spaceMD),
        isDense: true,
      );

  Widget _Campo(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label),
      validator: validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null
              : null),
    );
  }
}
