import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../auth/models/auth_models.dart';
import '../../patient/models/patient_models.dart';
import '../../../viewmodels/main_viewmodel.dart';
import 'components/verify_patient_dialog.dart';
import 'components/barcode_scanner_modal.dart';

class DoctorHomeView extends StatefulWidget {
  const DoctorHomeView({super.key});

  @override
  State<DoctorHomeView> createState() => _DoctorHomeViewState();
}

class _DoctorHomeViewState extends State<DoctorHomeView> {
  int _currentIndex = 0;
  final _searchBarcodeController = TextEditingController();

  @override
  void dispose() {
    _searchBarcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainViewModel>(context);
    final user = provider.currentUser!;

    final pages = [
      _buildQueueTab(context, provider, user),
      _buildDoctorHistoryTab(context, provider, user),
      _buildScanBarcodeTab(context, provider, user),
      _buildDoctorProfileTab(context, provider, user),
    ];

    final titles = ['Antrean Pasien', 'Histori Pemeriksaan', 'Scan & Verifikasi', 'Profil Dokter'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titles[_currentIndex], style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(user.name, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.logout_outlined, size: 18, color: Colors.white),
            ),
            onPressed: () => provider.logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Antrean'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Histori'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_outlined), activeIcon: Icon(Icons.qr_code_scanner), label: 'Scan'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  // TAB 1: ANTREAN PASIEN
  Widget _buildQueueTab(BuildContext context, MainViewModel provider, UserModel user) {
    final activeReservations = provider.reservations.where((r) => r.status != ReservationStatus.completed && r.status != ReservationStatus.cancelled).toList();

    return Column(
      children: [
        // Top banner header
        Container(
          width: double.infinity,
          color: AppColors.primaryDark,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Antrean Aktif Hari Ini', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('${activeReservations.length} pasien menunggu giliran', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BarcodeScannerModal(provider: provider))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_scanner, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text('Scan Kamera', style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: activeReservations.isEmpty
              ? _buildEmptyState('Belum ada antrean pasien aktif', Icons.people_outline)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeReservations.length,
                  itemBuilder: (context, index) {
                    final res = activeReservations[index];
                    return _buildQueueCard(context, provider, res);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQueueCard(BuildContext context, MainViewModel provider, ReservationModel res) {
    Color statusColor = AppColors.warning;
    if (res.status == ReservationStatus.inProgress) statusColor = AppColors.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.primaryLight.withValues(alpha: 0.1)]),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(res.queueNumber, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(res.patientName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Kode: ${res.barcodeCode}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            DropdownButton<ReservationStatus>(
              value: res.status,
              underline: const SizedBox(),
              isDense: true,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
              onChanged: (newStatus) {
                if (newStatus != null) provider.updateReservationStatus(res.id, newStatus);
              },
              items: ReservationStatus.values.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.name.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 2: HISTORI PEMERIKSAAN (Konsisten Header & Layout Card dengan Home Tab)
  Widget _buildDoctorHistoryTab(BuildContext context, MainViewModel provider, UserModel user) {
    final historyReservations = provider.reservations.where((r) => r.status == ReservationStatus.completed || r.status == ReservationStatus.cancelled).toList();

    return Column(
      children: [
        // Top banner header (Sama persis dengan Tab Home Antrean)
        Container(
          width: double.infinity,
          color: AppColors.primaryDark,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Riwayat Pemeriksaan Pasien', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 2),
              Text('${historyReservations.length} total riwayat selesai / dibatalkan', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
            ],
          ),
        ),

        Expanded(
          child: historyReservations.isEmpty
              ? _buildEmptyState('Belum ada histori pemeriksaan pasien', Icons.history)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyReservations.length,
                  itemBuilder: (context, index) {
                    final res = historyReservations[index];
                    final isCompleted = res.status == ReservationStatus.completed;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (isCompleted ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined, color: isCompleted ? AppColors.success : AppColors.danger, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(res.patientName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text('Antrean: ${res.queueNumber} · ${res.date.day}/${res.date.month}/${res.date.year}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                  Text('Kode Tiket: ${res.barcodeCode}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary.withValues(alpha: 0.8))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: (isCompleted ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isCompleted ? 'SELESAI' : 'BATAL',
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: isCompleted ? AppColors.success : AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // TAB 3: SCAN & VERIFIKASI BARCODE (Konsisten Header & Single View)
  Widget _buildScanBarcodeTab(BuildContext context, MainViewModel provider, UserModel user) {
    return Column(
      children: [
        // Top banner header (Sama persis dengan Tab Home Antrean)
        Container(
          width: double.infinity,
          color: AppColors.primaryDark,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Scan & Verifikasi Tiket Pasien', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 2),
              Text('Pindai kamera atau input kode tiket manual', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.qr_code_scanner, size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 18),
                      Text('Scan Live Barcode Tiket', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Text('Arahkan kamera ke Barcode / QR Code tiket pasien untuk verifikasi otomatis', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                          label: Text('Buka Kamera Scanner', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BarcodeScannerModal(provider: provider))),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('ATAU INPUT KODE MANUAL', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _searchBarcodeController,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan kode barcode (contoh: RES-...)',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.search, color: AppColors.primary, size: 18),
                    label: Text('Cek & Verifikasi Tiket', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary)),
                    onPressed: () {
                      final code = _searchBarcodeController.text.trim();
                      if (code.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Harap masukkan kode barcode!', style: GoogleFonts.inter()),
                            backgroundColor: AppColors.warning,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      final res = provider.findReservationByBarcode(code);
                      if (res != null) {
                        showDialog(context: context, builder: (_) => VerifyPatientDialog(provider: provider, res: res));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Barcode "$code" tidak ditemukan!', style: GoogleFonts.inter()),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 4: PROFIL DOKTER
  Widget _buildDoctorProfileTab(BuildContext context, MainViewModel provider, UserModel user) {
    final completedCount = provider.reservations.where((r) => r.status == ReservationStatus.completed).length;
    final totalPatients = provider.reservations.length;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                  ),
                  child: const Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(user.name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(user.email, style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                  child: Text('Dokter Praktek RS', style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildProfileStatCard('Pasien Ditangani', '$totalPatients', Icons.people, AppColors.secondary)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildProfileStatCard('Selesai Berobat', '$completedCount', Icons.check_circle, AppColors.success)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.verified, color: AppColors.primary, size: 20)),
                    title: Text('Status Akun Dokter', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text('AKTIF', style: GoogleFonts.inter(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () => provider.logout(),
                    icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                    label: Text('KELUAR AKUN', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(icon, size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
