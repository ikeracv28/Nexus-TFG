import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/practica_provider.dart';
import '../../data/models/practica_model.dart';

/**
 * Pantalla principal para el Alumno.
 * Muestra el resumen de su práctica actual y accesos directos.
 */
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Cargamos las prácticas al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        Provider.of<PracticaProvider>(context, listen: false)
            .cargarPracticas(auth.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final practicaProvider = Provider.of<PracticaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexus Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => practicaProvider.cargarPracticas(authProvider.user!.id),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, ${authProvider.user?.nombreCompleto ?? 'Usuario'}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Aquí tienes el estado de tu formación práctica.'),
              const SizedBox(height: 24),
              
              if (practicaProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (practicaProvider.practicaActiva != null)
                _buildPracticaCard(practicaProvider.practicaActiva!)
              else
                _buildEmptyState(),
                
              const SizedBox(height: 24),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPracticaCard(Practica practica) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    practica.empresaNombre,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(practica.estado).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(practica.estado)),
                  ),
                  child: Text(
                    practica.estado,
                    style: TextStyle(
                      color: _getStatusColor(practica.estado),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.tag, 'Código', practica.codigo),
            _buildInfoRow(Icons.person, 'Tutor Centro', practica.tutorCentroNombre),
            _buildInfoRow(Icons.business_center, 'Tutor Empresa', practica.tutorEmpresaNombre),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Horas Totales', '${practica.horasTotales ?? 0}h'),
                _buildStat('Progreso', '0h'), // TODO: Vincular con seguimientos
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No tienes prácticas asignadas actualmente.'),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Navegar a pantalla de nuevo seguimiento
            },
            icon: const Icon(Icons.add),
            label: const Text('Registrar Seguimiento Diario'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'ACTIVA': return Colors.green;
      case 'BORRADOR': return Colors.orange;
      case 'FINALIZADA': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
