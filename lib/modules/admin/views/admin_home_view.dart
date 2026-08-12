import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
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
        content: Row(children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(message, style: GoogleFonts.inter(color: Colors.white)),
        ]),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openDrawer(Widget drawerContent) {
    setState(() => _currentDrawer = drawerContent);
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<bool> _confirmDelete(BuildContext context, String itemName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.delete_outline, color: AppColors.danger, size: 22),
          ),
          const SizedBox(width: 12),
          Text('Konfirmasi Hapus', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        content: Text('Yakin hapus "$itemName"?\nData yang dihapus tidak dapat dikembalikan.', style: GoogleFonts.inter(color: AppColors.textSecondary, height: 1.5)),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Ya, Hapus', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return result ?? false;
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

    final tabTitles = ['Dashboard', 'Manajemen Dokter', 'Unit & Poliklinik', 'Spesialisasi'];

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _currentDrawer,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tabTitles[_currentIndex], style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('Panel Administrator', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.75))),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
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
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.white,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.medical_information_outlined), activeIcon: Icon(Icons.medical_information), label: 'Dokter'),
            BottomNavigationBarItem(icon: Icon(Icons.local_hospital_outlined), activeIcon: Icon(Icons.local_hospital), label: 'Unit Poli'),
            BottomNavigationBarItem(icon: Icon(Icons.category_outlined), activeIcon: Icon(Icons.category), label: 'Spesialis'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardOverviewTab(BuildContext context, MainViewModel provider) {
    final stats = [
      {'title': 'Total Dokter', 'count': '${provider.doctors.length}', 'icon': Icons.medical_information_rounded, 'color': const Color(0xFF1A73E8), 'bg': const Color(0xFFE8F0FE)},
      {'title': 'Unit Poliklinik', 'count': '${provider.units.length}', 'icon': Icons.local_hospital_rounded, 'color': const Color(0xFF0A7B6C), 'bg': const Color(0xFFE0F5F2)},
      {'title': 'Spesialisasi', 'count': '${provider.specialists.length}', 'icon': Icons.category_rounded, 'color': const Color(0xFFF57F17), 'bg': const Color(0xFFFFF8E1)},
      {'title': 'Total Antrean', 'count': '${provider.reservations.length}', 'icon': Icons.people_rounded, 'color': const Color(0xFF7B1FA2), 'bg': const Color(0xFFF3E5F5)},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Welcome header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selamat Datang', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                    Text('Super Admin', style: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    Text('Pelayanan Kesehatan', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text('Ringkasan Data', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.3),
          itemBuilder: (context, index) {
            final s = stats[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: s['bg'] as Color, borderRadius: BorderRadius.circular(10)),
                    child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 20),
                  ),
                  const Spacer(),
                  Text(s['count'] as String, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: s['color'] as Color)),
                  Text(s['title'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDoctorTab(BuildContext context, MainViewModel provider) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openDrawer(AddDoctorDrawer(provider: provider, onShowSnackBar: _showSnackBar)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tambah Dokter', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      body: provider.doctors.isEmpty
          ? _buildEmptyState('Belum ada data dokter', Icons.person_off_outlined)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: provider.doctors.length,
              itemBuilder: (context, index) {
                final doc = provider.doctors[index];
                final specName = provider.specialists.firstWhere((s) => s.id == doc.specialistId, orElse: () => SpecialistModel(id: '', name: 'Spesialis', description: '')).name;
                final unitName = provider.units.firstWhere((u) => u.id == doc.unitId, orElse: () => UnitModel(id: '', name: 'Unit', hospitalName: '', address: '', latitude: 0, longitude: 0)).name;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.15), AppColors.primaryLight.withOpacity(0.15)]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc.name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text(specName, style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              Text('$unitName · ${doc.schedule}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(Icons.edit_outlined, AppColors.secondary, () => _openDrawer(AddDoctorDrawer(provider: provider, onShowSnackBar: _showSnackBar, doctorToEdit: doc))),
                            const SizedBox(width: 4),
                            _buildActionButton(Icons.delete_outline, AppColors.danger, () async {
                              final confirmed = await _confirmDelete(context, doc.name);
                              if (confirmed) {
                                await provider.deleteDoctor(doc.id);
                                _showSnackBar('Data dokter berhasil dihapus');
                              }
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildUnitTab(BuildContext context, MainViewModel provider) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openDrawer(AddUnitDrawer(provider: provider, onShowSnackBar: _showSnackBar)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tambah Unit', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      body: provider.units.isEmpty
          ? _buildEmptyState('Belum ada data unit poliklinik', Icons.local_hospital_outlined)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: provider.units.length,
              itemBuilder: (context, index) {
                final unit = provider.units[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F5F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(unit.name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                              Text(unit.hospitalName, style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              Text(unit.address, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(Icons.edit_outlined, AppColors.secondary, () => _openDrawer(AddUnitDrawer(provider: provider, onShowSnackBar: _showSnackBar, unitToEdit: unit))),
                            const SizedBox(width: 4),
                            _buildActionButton(Icons.delete_outline, AppColors.danger, () async {
                              final confirmed = await _confirmDelete(context, unit.name);
                              if (confirmed) {
                                await provider.deleteUnit(unit.id);
                                _showSnackBar('Unit poliklinik berhasil dihapus');
                              }
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSpecialistTab(BuildContext context, MainViewModel provider) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openDrawer(AddSpecialistDrawer(provider: provider, onShowSnackBar: _showSnackBar)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tambah Spesialis', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      body: provider.specialists.isEmpty
          ? _buildEmptyState('Belum ada data spesialisasi', Icons.category_outlined)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: provider.specialists.length,
              itemBuilder: (context, index) {
                final spec = provider.specialists[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(color: Color(0xFFFFF8E1), shape: BoxShape.circle),
                          child: const Icon(Icons.category_rounded, color: Color(0xFFF57F17), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(spec.name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                              Text(spec.description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(Icons.edit_outlined, AppColors.secondary, () => _openDrawer(AddSpecialistDrawer(provider: provider, onShowSnackBar: _showSnackBar, specialistToEdit: spec))),
                            const SizedBox(width: 4),
                            _buildActionButton(Icons.delete_outline, AppColors.danger, () async {
                              final confirmed = await _confirmDelete(context, spec.name);
                              if (confirmed) {
                                await provider.deleteSpecialist(spec.id);
                                _showSnackBar('Data spesialisasi berhasil dihapus');
                              }
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: color),
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
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(icon, size: 48, color: AppColors.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
