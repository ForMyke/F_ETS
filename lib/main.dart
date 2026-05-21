import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETS App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    EstudiantesPage(),
    PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Estudiantes'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ── Dashboard ─────────────────────────────────────────────────────────
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ETS — Sistema Escolar'),
        backgroundColor: color.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Bienvenido',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Sistema de gestión escolar',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),

            // Tarjetas de estadísticas
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _StatCard(
                    label: 'Estudiantes',
                    value: '248',
                    icon: Icons.people,
                    color: Colors.blue),
                _StatCard(
                    label: 'Materias',
                    value: '12',
                    icon: Icons.book,
                    color: Colors.purple),
                _StatCard(
                    label: 'Docentes',
                    value: '18',
                    icon: Icons.school,
                    color: Colors.teal),
                _StatCard(
                    label: 'Grupos',
                    value: '6',
                    icon: Icons.group_work,
                    color: Colors.orange),
              ],
            ),

            const SizedBox(height: 24),
            Text('Actividad reciente',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            _ActividadItem(
                icon: Icons.check_circle,
                color: Colors.green,
                texto: 'Lista de asistencia actualizada',
                hora: 'Hace 5 min'),
            _ActividadItem(
                icon: Icons.assignment,
                color: Colors.blue,
                texto: 'Nueva tarea publicada en Cálculo',
                hora: 'Hace 20 min'),
            _ActividadItem(
                icon: Icons.notification_important,
                color: Colors.orange,
                texto: 'Examen parcial programado',
                hora: 'Hace 1 hora'),
            _ActividadItem(
                icon: Icons.person_add,
                color: Colors.purple,
                texto: 'Nuevo estudiante inscrito',
                hora: 'Hace 2 horas'),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActividadItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String texto;
  final String hora;

  const _ActividadItem(
      {required this.icon,
      required this.color,
      required this.texto,
      required this.hora});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20)),
      title: Text(texto, style: const TextStyle(fontSize: 14)),
      subtitle:
          Text(hora, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
    );
  }
}

// ── Estudiantes ────────────────────────────────────────────────────────
class EstudiantesPage extends StatelessWidget {
  const EstudiantesPage({super.key});

  static const _estudiantes = [
    {'nombre': 'Ana García', 'materia': 'Cálculo II', 'promedio': '9.2'},
    {'nombre': 'Luis Martínez', 'materia': 'Física I', 'promedio': '8.5'},
    {'nombre': 'María López', 'materia': 'Programación', 'promedio': '9.8'},
    {'nombre': 'Carlos Pérez', 'materia': 'Álgebra', 'promedio': '7.4'},
    {'nombre': 'Sofía Hernández', 'materia': 'Cálculo II', 'promedio': '8.9'},
    {'nombre': 'Diego Ramírez', 'materia': 'Física I', 'promedio': '6.8'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estudiantes')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _estudiantes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final e = _estudiantes[i];
          final promedio = double.parse(e['promedio']!);
          final color = promedio >= 9
              ? Colors.green
              : promedio >= 8
                  ? Colors.blue
                  : promedio >= 7
                      ? Colors.orange
                      : Colors.red;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                child: Text(e['nombre']![0],
                    style: const TextStyle(
                        color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
              ),
              title: Text(e['nombre']!),
              subtitle: Text(e['materia']!),
              trailing: Chip(
                label: Text(e['promedio']!,
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.bold)),
                backgroundColor: color.withOpacity(0.1),
                side: BorderSide.none,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Perfil ─────────────────────────────────────────────────────────────
class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 48,
              backgroundColor: color.primary,
              child: const Text('AD',
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            const Text('Admin Docente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('admin@ets.edu.mx', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 32),
            _InfoTile(
                icon: Icons.school,
                label: 'Institución',
                value: 'Instituto ETS'),
            _InfoTile(icon: Icons.badge, label: 'Rol', value: 'Administrador'),
            _InfoTile(
                icon: Icons.calendar_today,
                label: 'Ciclo',
                value: '2025 - Primavera'),
            _InfoTile(
                icon: Icons.email, label: 'Correo', value: 'admin@ets.edu.mx'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title:
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }
}
