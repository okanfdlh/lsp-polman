import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../viewmodels/main_viewmodel.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Panel'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => provider.logout())
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.medical_information), text: 'Dokter'),
            Tab(icon: Icon(Icons.local_hospital), text: 'Unit / Poli'),
            Tab(icon: Icon(Icons.category), text: 'Spesialis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDoctorTab(context, provider),
          _buildUnitTab(context, provider),
          _buildSpecialistTab(context, provider),
        ],
      ),
    );
  }

  // --- DOKTER TAB & CRUD DIALOG ---
  Widget _buildDoctorTab(BuildContext context, MainViewModel provider) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        onPressed: () => _showAddDoctorDialog(context, provider),
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
                      onPressed: () => provider.deleteDoctor(doc.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddDoctorDialog(BuildContext context, MainViewModel provider) {
    final nameCtrl = TextEditingController();
    final scheduleCtrl = TextEditingController(text: 'Senin - Jumat (08:00 - 12:00)');
    String? selectedSpecId = provider.specialists.isNotEmpty ? provider.specialists.first.id : null;
    String? selectedUnitId = provider.units.isNotEmpty ? provider.units.first.id : null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Data Dokter'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Dokter (beserta Gelar)')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedSpecId,
                  decoration: const InputDecoration(labelText: 'Spesialisasi'),
                  items: provider.specialists.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                  onChanged: (val) => setDialogState(() => selectedSpecId = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedUnitId,
                  decoration: const InputDecoration(labelText: 'Unit / Poliklinik'),
                  items: provider.units.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name))).toList(),
                  onChanged: (val) => setDialogState(() => selectedUnitId = val),
                ),
                const SizedBox(height: 12),
                TextField(controller: scheduleCtrl, decoration: const InputDecoration(labelText: 'Jadwal Praktek')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty && selectedSpecId != null && selectedUnitId != null) {
                  final ok = await provider.addDoctor(
                    name: nameCtrl.text.trim(),
                    specialistId: selectedSpecId!,
                    unitId: selectedUnitId!,
                    schedule: scheduleCtrl.text.trim(),
                    imageUrl: 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                  );
                  if (ok && context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- UNIT / POLI TAB & CRUD DIALOG ---
  Widget _buildUnitTab(BuildContext context, MainViewModel provider) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        onPressed: () => _showAddUnitDialog(context, provider),
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
                      onPressed: () => provider.deleteUnit(unit.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddUnitDialog(BuildContext context, MainViewModel provider) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final latCtrl = TextEditingController(text: '-6.2088');
    final lngCtrl = TextEditingController(text: '106.8456');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Unit / Poliklinik'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Poliklinik (Contoh: Poli Mata)')),
              const SizedBox(height: 12),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Alamat / Lokasi Gedung')),
              const SizedBox(height: 12),
              TextField(controller: latCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Latitude')),
              const SizedBox(height: 12),
              TextField(controller: lngCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Longitude')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && addressCtrl.text.isNotEmpty) {
                final ok = await provider.addUnit(
                  name: nameCtrl.text.trim(),
                  hospitalName: 'RS Sehat Sejahtera',
                  address: addressCtrl.text.trim(),
                  latitude: double.tryParse(latCtrl.text) ?? -6.2088,
                  longitude: double.tryParse(lngCtrl.text) ?? 106.8456,
                );
                if (ok && context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- SPESIALIS TAB & CRUD DIALOG ---
  Widget _buildSpecialistTab(BuildContext context, MainViewModel provider) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        onPressed: () => _showAddSpecialistDialog(context, provider),
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
                      onPressed: () => provider.deleteSpecialist(spec.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddSpecialistDialog(BuildContext context, MainViewModel provider) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Spesialisasi Medis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Spesialis (Contoh: Spesialis Mata)')),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi singkat')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                final ok = await provider.addSpecialist(nameCtrl.text.trim(), descCtrl.text.trim());
                if (ok && context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
