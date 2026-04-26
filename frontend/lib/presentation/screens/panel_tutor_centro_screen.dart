import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// Placeholder del panel del tutor del centro.
/// Implementación completa en el Bloque 4 (Hito 3).
class PanelTutorCentroScreen extends StatelessWidget {
  const PanelTutorCentroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: NexusColors.surfaceAlt,
      appBar: AppBar(
        title: const Text('Panel Tutor del Centro'),
        actions: [
          TextButton.icon(
            onPressed: () => auth.logout(),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Salir'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.supervisor_account_outlined,
                size: 64, color: Color.fromRGBO(24, 95, 165, 0.5)),
            const SizedBox(height: NexusSizes.spaceLG),
            Text('Panel en construcción', style: NexusText.heading2),
            const SizedBox(height: NexusSizes.spaceSM),
            Text(
              'Segunda validación, incidencias y chat — Bloque 4',
              style: NexusText.body.copyWith(color: NexusColors.inkSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
