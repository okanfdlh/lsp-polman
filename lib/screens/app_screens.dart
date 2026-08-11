import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../viewmodels/main_viewmodel.dart';

// --- AUTH SCREENS ---

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'pasien@mail.com');
  final _passwordController = TextEditingController(text: '123');

  void _login() async {
    final provider = Provider.of<MainViewModel>(context, listen: false);
    final success = await provider.login(_emailController.text, _passwordController.text);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Gagal! Email atau Password salah.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_hospital_rounded, size: 80, color: Colors.teal),
                const SizedBox(height: 16),
                const Text(
                  'Pelayanan Kesehatan RS',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 8),
                const Text('Silakan login untuk melanjutkannya'),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('LOGIN', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Belum punya akun? Registrasi Pasien Baru'),
                ),
                const Divider(height: 40),
                const Text('Demo Quick Fill:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Pasien'),
                      onPressed: () {
                        _emailController.text = 'pasien@mail.com';
                        _passwordController.text = '123';
                      },
                    ),
                    ActionChip(
                      label: const Text('Dokter'),
                      onPressed: () {
                        _emailController.text = 'dokter@mail.com';
                        _passwordController.text = '123';
                      },
                    ),
                    ActionChip(
                      label: const Text('Super Admin'),
                      onPressed: () {
                        _emailController.text = 'admin@mail.com';
                        _passwordController.text = '123';
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua data!')));
      return;
    }
    final provider = Provider.of<MainViewModel>(context, listen: false);
    final ok = await provider.registerPatient(_nameController.text, _emailController.text, _passwordController.text);
    if (ok && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email sudah terdaftar atau gagal registrasi!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Pasien Baru')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('DAFTAR SEKARANG', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

// --- PASIEN (USER) SCREENS ---

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainViewModel>(context);
    final user = provider.currentUser!;

    final pages = [
      _buildDoctorListTab(context, provider),
      _buildMyTicketsTab(context, provider, user.id),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${user.name}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => provider.logout(),
          )
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Cari Dokter'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Tiket Antrean'),
        ],
      ),
    );
  }

  Widget _buildDoctorListTab(BuildContext context, MainViewModel provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.doctors.length,
      itemBuilder: (context, index) {
        final doc = provider.doctors[index];
        final specialist = provider.specialists.firstWhere((s) => s.id == doc.specialistId);
        final unit = provider.units.firstWhere((u) => u.id == doc.unitId);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal.shade100,
                      child: const Icon(Icons.person, size: 40, color: Colors.teal),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(specialist.name, style: TextStyle(color: Colors.teal.shade700)),
                          Text(unit.name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Jadwal: ${doc.schedule}', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.navigation, size: 16),
                        label: const Text('Lokasi Unit'),
                        onPressed: () => _openMap(unit.latitude, unit.longitude),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        onPressed: () async {
                          final res = await provider.createReservation(doc, DateTime.now());
                          if (res != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Reservasi berhasil! No Antrean: ${res.queueNumber}')),
                            );
                            setState(() => _currentIndex = 1);
                          }
                        },
                        child: const Text('Reservasi', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyTicketsTab(BuildContext context, MainViewModel provider, String patientId) {
    final tickets = provider.reservations.where((r) => r.patientId == patientId).toList();

    if (tickets.isEmpty) {
      return const Center(child: Text('Belum ada tiket reservasi antrean.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Nomor Antrean: ${ticket.queueNumber}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),
                const SizedBox(height: 16),
                QrImageView(
                  data: ticket.barcodeCode,
                  version: QrVersions.auto,
                  size: 160.0,
                ),
                const SizedBox(height: 8),
                Text(ticket.barcodeCode, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const Divider(height: 24),
                ListTile(
                  dense: true,
                  title: Text(ticket.doctorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${ticket.specialistName}\n${ticket.unitName}'),
                  trailing: Chip(
                    label: Text(
                      ticket.status.name.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: ticket.status == ReservationStatus.waiting
                        ? Colors.orange
                        : ticket.status == ReservationStatus.completed
                            ? Colors.green
                            : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openMap(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}

// --- DOKTER SCREENS ---

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final _searchBarcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainViewModel>(context);
    final user = provider.currentUser!;

    final doctorReservations = provider.reservations.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Dokter: ${user.name}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => provider.logout())
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scan / Verifikasi Antrean Pasien', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchBarcodeController,
                    decoration: const InputDecoration(
                      hintText: 'Input / Scan Barcode Kode (Contoh: RES-...)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: const Size(60, 50)),
                  onPressed: () {
                    final res = provider.findReservationByBarcode(_searchBarcodeController.text.trim());
                    if (res != null) {
                      _showPatientDialog(context, provider, res);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Barcode Antrean Tidak Ditemukan!')));
                    }
                  },
                  child: const Icon(Icons.search, color: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text('Daftar Antrean Pasien', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: doctorReservations.isEmpty
                  ? const Center(child: Text('Belum ada pasien terdaftar hari ini.'))
                  : ListView.builder(
                      itemCount: doctorReservations.length,
                      itemBuilder: (context, index) {
                        final res = doctorReservations[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: Text(res.queueNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(res.patientName),
                            subtitle: Text('Kode: ${res.barcodeCode}'),
                            trailing: DropdownButton<ReservationStatus>(
                              value: res.status,
                              onChanged: (newStatus) {
                                if (newStatus != null) {
                                  provider.updateReservationStatus(res.id, newStatus);
                                }
                              },
                              items: ReservationStatus.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(s.name),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  void _showPatientDialog(BuildContext context, MainViewModel provider, ReservationModel res) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pasien: ${res.patientName} (${res.queueNumber})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kode Barcode: ${res.barcodeCode}'),
            Text('Unit: ${res.unitName}'),
            const SizedBox(height: 12),
            Text('Status Saat Ini: ${res.status.name.toUpperCase()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              provider.updateReservationStatus(res.id, ReservationStatus.completed);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pemeriksaan Selesai!')));
            },
            child: const Text('Tandai Selesai', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

// --- SUPER ADMIN SCREENS ---

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
