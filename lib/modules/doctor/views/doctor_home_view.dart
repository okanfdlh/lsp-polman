import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/models/auth_models.dart';
import '../../patient/models/patient_models.dart';
import '../../../viewmodels/main_viewmodel.dart';
import 'components/verify_patient_dialog.dart';

class DoctorHomeView extends StatefulWidget {
  const DoctorHomeView({super.key});

  @override
  State<DoctorHomeView> createState() => _DoctorHomeViewState();
}

class _DoctorHomeViewState extends State<DoctorHomeView> {
  int _currentIndex = 0;
  final _searchBarcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainViewModel>(context);
    final user = provider.currentUser!;

    final pages = [
      _buildQueueTab(context, provider),
      _buildScanBarcodeTab(context, provider),
      _buildDoctorProfileTab(context, provider, user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Dokter: ${user.name}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => provider.logout())
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Antrean Pasien'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan Barcode'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil Saya'),
        ],
      ),
    );
  }

  Widget _buildQueueTab(BuildContext context, MainViewModel provider) {
    final doctorReservations = provider.reservations.toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daftar Antrean Pasien Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
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
    );
  }

  Widget _buildScanBarcodeTab(BuildContext context, MainViewModel provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner, size: 100, color: Colors.indigo),
          const SizedBox(height: 16),
          const Text('Verifikasi Antrean Pasien', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Masukkan atau scan kode barcode pada tiket pasien', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          TextField(
            controller: _searchBarcodeController,
            decoration: const InputDecoration(
              hintText: 'Input Kode Barcode (Contoh: RES-...)',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () {
              final res = provider.findReservationByBarcode(_searchBarcodeController.text.trim());
              if (res != null) {
                showDialog(
                  context: context,
                  builder: (_) => VerifyPatientDialog(provider: provider, res: res),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Barcode Antrean Tidak Ditemukan!')),
                );
              }
            },
            child: const Text('Cek Barcode', style: TextStyle(color: Colors.white, fontSize: 16)),
          )
        ],
      ),
    );
  }

  Widget _buildDoctorProfileTab(BuildContext context, MainViewModel provider, UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.indigo,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(user.email, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          const Card(
            child: ListTile(
              leading: Icon(Icons.verified, color: Colors.indigo),
              title: Text('Role Akses'),
              subtitle: Text('Dokter Praktek RS'),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size.fromHeight(50)),
            onPressed: () => provider.logout(),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('LOGOUT AKUN', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
