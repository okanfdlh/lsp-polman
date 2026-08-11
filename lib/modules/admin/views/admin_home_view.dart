import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/admin_models.dart';
import '../../../../viewmodels/main_viewmodel.dart';
import 'components/add_doctor_drawer.dart';
import 'components/add_unit_drawer.dart';
import 'components/add_specialist_drawer.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget? _currentDrawer;

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openDrawer(Widget drawerContent) {
    setState(() {
      _currentDrawer = drawerContent;
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainViewModel>(context);

    final pages = [
      _buildDashboardOverviewTab(context, provider),
      _buildDoctorTab(context, provider),
      _buildUnitTab(context, provider),
      _buildSpecialistTab(context, provider),
    ];

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _currentDrawer,
      appBar: AppBar(
        title: const Text('Super Admin Panel'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => provider.logout())
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_information), label: 'Dokter'),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Unit Poli'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Spesialis'),
        ],
      ),
    );
  }

  Widget _buildDashboardOverviewTab(BuildContext context, MainViewModel provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Statistik Master Data & Antrean', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildStatCard('Total Dokter', '${provider.doctors.length}', Icons.medical_information, Colors.blue),
        _buildStatCard('Total Unit / Poli', '${provider.units.length}', Icons.local_hospital, Colors.green),
        _buildStatCard('Total Spesialisasi', '${provider.specialists.length}', Icons.category, Colors.orange),
        _buildStatCard('Total Antrean Pasien', '${provider.reservations.length}', Icons.people, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.2), child: Icon(icon, color: color)),
        title: Text(title),
        trailing: Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDoctorTab(BuildContext context, MainViewModel provider) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        onPressed: () => _openDrawer(AddDoctorDrawer(provider: provider, onShowSnackBar: _showSnackBar)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Dokter', style: TextStyle(color: Colors.white)),
      ),
      body: provider.doctors.isEmpty
          ? const Center(child: Text('Belum ada data dokter.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.doctors.length,
              itemBuilder: (context, index) {
                final doc = provider.doctors[index];
                final specName = provider.specialists.firstWhere((s) => s.id == doc.specialistId, orElse: () => SpecialistModel(id: '', name: 'Spesialis', description: '')).name;
                final unitName = provider.units.firstWhere((u) => u.id == doc.unitId, orElse: () => UnitModel(id: '', name: 'Unit', hospitalName: '', address: '', latitude: 0, longitude: 0)).name;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepOrange.shade100,
                      child: const Icon(Icons.person, color: Colors.deepOrange),
                    ),
                    title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('$specName\n$unitName | ${doc.schedule}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await provider.deleteDoctor(doc.id);
                        _showSnackBar('Data dokter berhasil dihapus');
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildUnitTab(BuildContext context, MainViewModel provider) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        onPressed: () => _openDrawer(AddUnitDrawer(provider: provider, onShowSnackBar: _showSnackBar)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Unit / Poli', style: TextStyle(color: Colors.white)),
      ),
      body: provider.units.isEmpty
          ? const Center(child: Text('Belum ada data unit poliklinik.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.units.length,
              itemBuilder: (context, index) {
                final unit = provider.units[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: const Icon(Icons.local_hospital, color: Colors.teal),
                    ),
                    title: Text(unit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${unit.hospitalName} - ${unit.address}\nLat: ${unit.latitude}, Lng: ${unit.longitude}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await provider.deleteUnit(unit.id);
                        _showSnackBar('Unit poliklinik berhasil dihapus');
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSpecialistTab(BuildContext context, MainViewModel provider) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        onPressed: () => _openDrawer(AddSpecialistDrawer(provider: provider, onShowSnackBar: _showSnackBar)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Spesialis', style: TextStyle(color: Colors.white)),
      ),
      body: provider.specialists.isEmpty
          ? const Center(child: Text('Belum ada data spesialisasi.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.specialists.length,
              itemBuilder: (context, index) {
                final spec = provider.specialists[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: const Icon(Icons.category, color: Colors.orange),
                    ),
                    title: Text(spec.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(spec.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await provider.deleteSpecialist(spec.id);
                        _showSnackBar('Data spesialisasi berhasil dihapus');
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
