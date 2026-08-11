import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../admin/models/admin_models.dart';
import '../../../viewmodels/main_viewmodel.dart';
import '../logic/patient_logic.dart';
import 'components/ticket_card.dart';

class PatientHomeView extends StatefulWidget {
  const PatientHomeView({super.key});

  @override
  State<PatientHomeView> createState() => _PatientHomeViewState();
}

class _PatientHomeViewState extends State<PatientHomeView> {
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
        final specialist = provider.specialists.firstWhere((s) => s.id == doc.specialistId, orElse: () => SpecialistModel(id: '', name: 'Spesialis', description: ''));
        final unit = provider.units.firstWhere((u) => u.id == doc.unitId, orElse: () => UnitModel(id: '', name: 'Unit RS', hospitalName: 'RS', address: '', latitude: 0, longitude: 0));

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
                        onPressed: () => PatientLogic.openMap(unit.latitude, unit.longitude),
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
        return TicketCard(ticket: ticket);
      },
    );
  }
}
