import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../viewmodels/main_viewmodel.dart';

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
