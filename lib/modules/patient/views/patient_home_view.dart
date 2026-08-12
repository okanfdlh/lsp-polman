import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../admin/models/admin_models.dart';
import '../../auth/models/auth_models.dart';
import '../../patient/models/patient_models.dart';
import '../../../viewmodels/main_viewmodel.dart';
import '../../../services/map/location_service.dart';
import '../logic/patient_logic.dart';
import 'components/ticket_card.dart';
import 'components/reservation_picker_dialog.dart';

class PatientHomeView extends StatefulWidget {
  const PatientHomeView({super.key});

  @override
  State<PatientHomeView> createState() => _PatientHomeViewState();
}

class _PatientHomeViewState extends State<PatientHomeView> {
  int _currentIndex = 0;
  final MapController _mapController = MapController();
  LatLng? _userGpsLocation;
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;

  final List<Map<String, String>> _promoBanners = [
    {
      'title': 'Layanan Reservasi 24/7',
      'subtitle': 'Daftar antrean dokter online tanpa perlu antre di rumah sakit',
      'tag': 'RESERVASI CEPAT',
      'icon': 'local_hospital',
    },
    {
      'title': 'Cek Peta Sebaran Unit',
      'subtitle': 'Temukan lokasi Poliklinik terdekat lengkap dengan rute GPS',
      'tag': 'NAVIGASI MAPS',
      'icon': 'map',
    },
    {
      'title': 'Tiket Antrean Barcode',
      'subtitle': 'Tunjukkan QR Code tiket Anda ke dokter untuk verifikasi instan',
      'tag': 'VERIFIKASI BARCODE',
      'icon': 'qr_code',
    },
  ];

  final List<Map<String, dynamic>> _healthArticles = [
    {
      'title': '5 Tips Menjaga Kesehatan Jantung di Usia Muda',
      'category': 'Edukasi Kesehatan',
      'readTime': '3 mnt baca',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFE53935),
    },
    {
      'title': 'Pentingnya Imunisasi Rutin untuk Anak',
      'category': 'Kesehatan Anak',
      'readTime': '4 mnt baca',
      'icon': Icons.child_care_rounded,
      'color': Color(0xFF1A73E8),
    },
    {
      'title': 'Pola Makan Sehat Cegah Diabetes Mellingus',
      'category': 'Gizi & Nutrisi',
      'readTime': '5 mnt baca',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFF2E7D32),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserGpsLocation();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserGpsLocation() async {
    final pos = await LocationService.getCurrentLocation(context);
    if (pos != null && mounted) {
      setState(() => _userGpsLocation = pos);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            _mapController.move(pos, 14.0);
          } catch (_) {}
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainViewModel>(context);
    final user = provider.currentUser!;

    final pages = [
      _buildDashboardHomeTab(context, provider, user),
      _buildDoctorListTab(context, provider, user),
      _buildUnitsMapTab(context, provider),
      _buildMyTicketsTab(context, provider, user.id),
      _buildPatientProfileTab(context, provider, user),
    ];

    final tabTitles = ['Beranda', 'Cari Dokter', 'Peta Sebaran Unit', 'Tiket Antrean', 'Profil Saya'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tabTitles[_currentIndex], style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('Pelayanan Kesehatan Online', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
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
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.medical_services_outlined), activeIcon: Icon(Icons.medical_services), label: 'Dokter'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map_rounded), label: 'Peta'),
            BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), activeIcon: Icon(Icons.confirmation_number), label: 'Tiket'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  // ================= TAB 0: BERANDA (HOME DASHBOARD USER) =================
  Widget _buildDashboardHomeTab(BuildContext context, MainViewModel provider, UserModel user) {
    final patientName = user.name;
    final activeTickets = provider.reservations.where((r) =>
      (r.patientId == user.id || (r.patientName.isNotEmpty && r.patientName == patientName)) &&
      r.status != ReservationStatus.completed &&
      r.status != ReservationStatus.cancelled
    ).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. GREETING HERO BANNER
          Container(
            width: double.infinity,
            color: AppColors.primaryDark,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selamat Datang, 👋', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                          Text(user.name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accent.withValues(alpha: 0.5))),
                      child: Text('PASIEN', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.15))),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.accent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Layanan Kesehatan Online RS Terpercaya & Real-time',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. SLIDER BANNER PROMO / INFORMASI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Informasi & Layanan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Row(
                  children: List.generate(
                    _promoBanners.length,
                    (idx) => Container(
                      width: _bannerIndex == idx ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: _bannerIndex == idx ? AppColors.primary : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (idx) => setState(() => _bannerIndex = idx),
              itemCount: _promoBanners.length,
              itemBuilder: (context, index) {
                final b = _promoBanners[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                              child: Text(b['tag']!, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                            ),
                            const SizedBox(height: 6),
                            Text(b['title']!, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text(b['subtitle']!, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.85)), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                        child: Icon(
                          index == 0 ? Icons.local_hospital_rounded : (index == 1 ? Icons.map_rounded : Icons.qr_code_rounded),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 3. MENU UTAMA QUICK ACCESS (GRID MENU)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Menu Utama', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickMenuItem(
                  icon: Icons.medical_services_rounded,
                  label: 'Cari Dokter',
                  color: AppColors.primary,
                  bgColor: const Color(0xFFE0F5F2),
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _buildQuickMenuItem(
                  icon: Icons.map_rounded,
                  label: 'Peta Unit',
                  color: AppColors.secondary,
                  bgColor: const Color(0xFFE8F0FE),
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _buildQuickMenuItem(
                  icon: Icons.confirmation_number_rounded,
                  label: 'Tiket Antrean',
                  color: AppColors.warning,
                  bgColor: const Color(0xFFFFF8E1),
                  badgeCount: activeTickets.length,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                _buildQuickMenuItem(
                  icon: Icons.person_rounded,
                  label: 'Profil Saya',
                  color: const Color(0xFF7B1FA2),
                  bgColor: const Color(0xFFF3E5F5),
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. ACTIVE TIKET ANTREAN PREVIEW (JIKA ADA TIKET AKTIF)
          if (activeTickets.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text('Tiket Aktif Anda', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    ],
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 3),
                    child: Text('Lihat Semua', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TicketCard(ticket: activeTickets.first),
            ),
            const SizedBox(height: 12),
          ],

          // 5. INFO-INFO EDUKASI KESEHATAN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Info & Artikel Kesehatan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _healthArticles.length,
            itemBuilder: (context, index) {
              final a = _healthArticles[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: (a['color'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                      child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                            child: Text(a['category'] as String, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 4),
                          Text(a['title'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(a['readTime'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuickMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                    child: Text('$badgeCount', style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  // ================= TAB 1: CARI DOKTER =================
  Widget _buildDoctorListTab(BuildContext context, MainViewModel provider, UserModel user) {
    return Column(
      children: [
        // Hero banner
        Container(
          color: AppColors.primaryDark,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, ${user.name.split(' ').first}! 👋', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('${provider.doctors.length} dokter tersedia hari ini', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.search, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),

        Expanded(
          child: provider.doctors.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle), child: Icon(Icons.person_off_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.5))),
                    const SizedBox(height: 16),
                    Text('Belum ada dokter terdaftar', style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  itemCount: provider.doctors.length,
                  itemBuilder: (context, index) {
                    final doc = provider.doctors[index];
                    final specialist = provider.specialists.firstWhere((s) => s.id == doc.specialistId, orElse: () => SpecialistModel(id: '', name: 'Spesialis', description: ''));
                    final unit = provider.units.firstWhere((u) => u.id == doc.unitId, orElse: () => UnitModel(id: '', name: 'Unit RS', hospitalName: 'RS', address: '', latitude: 0, longitude: 0));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.primaryLight.withValues(alpha: 0.1)]),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: doc.image.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.network(doc.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 32, color: AppColors.primary)),
                                        )
                                      : const Icon(Icons.person, size: 32, color: AppColors.primary),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(doc.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                        child: Text(specialist.name, style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(unit.name, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: const Color(0xFFE0F5F2), borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  const Icon(Icons.schedule, size: 15, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text('Jadwal: ${doc.schedule}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.navigation_outlined, size: 15),
                                    label: Text('Lokasi', style: GoogleFonts.inter(fontSize: 13)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.primary),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => PatientLogic.openMap(unit.latitude, unit.longitude, context: context),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 15),
                                    label: Text('Buat Reservasi', style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                    onPressed: () async {
                                      final res = await showDialog(context: context, builder: (_) => ReservationPickerDialog(doctor: doc, provider: provider));
                                      if (res != null && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(children: [const Icon(Icons.check_circle, color: Colors.white, size: 18), const SizedBox(width: 8), Text('Reservasi berhasil! No: ${res.queueNumber}', style: GoogleFonts.inter(color: Colors.white))]),
                                            backgroundColor: AppColors.success,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        );
                                        setState(() => _currentIndex = 3);
                                      }
                                    },
                                  ),
                                ),
                              ],
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

  // ================= TAB 2: PETA SEBARAN UNIT =================
  Widget _buildUnitsMapTab(BuildContext context, MainViewModel provider) {
    LatLng centerPos = _userGpsLocation ?? const LatLng(-6.208800, 106.845600);
    if (_userGpsLocation == null && provider.units.isNotEmpty) {
      centerPos = LatLng(provider.units.first.latitude, provider.units.first.longitude);
    }

    final markers = provider.units.map((unit) {
      return Marker(
        point: LatLng(unit.latitude, unit.longitude),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (ctx) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(unit.name, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.business_outlined, unit.hospitalName),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.location_on_outlined, unit.address),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        icon: const Icon(Icons.navigation_rounded, color: Colors.white),
                        label: Text('Buka Navigasi Google Maps', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          PatientLogic.openMap(unit.latitude, unit.longitude, context: context);
                        },
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(ctx).padding.bottom + 4),
                  ],
                ),
              ),
            );
          },
          child: const Icon(Icons.location_on, color: Color(0xFFE53935), size: 44),
        ),
      );
    }).toList();

    if (_userGpsLocation != null) {
      markers.add(
        Marker(
          point: _userGpsLocation!,
          width: 44,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.4), blurRadius: 10)],
            ),
            child: const Icon(Icons.my_location, color: Colors.white, size: 20),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: AppColors.primaryDark,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Peta Sebaran ${provider.units.length} Unit Poli', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(_userGpsLocation != null ? '📍 Berpusat di lokasi GPS Anda' : 'Ketuk pin untuk lihat detail & rute', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _fetchUserGpsLocation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.my_location, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: centerPos, initialZoom: 14.0),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.lsp'),
              MarkerLayer(markers: markers),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary))),
      ],
    );
  }

  // ================= TAB 3: TIKET ANTREAN =================
  Widget _buildMyTicketsTab(BuildContext context, MainViewModel provider, String patientId) {
    final patientName = provider.currentUser?.name ?? '';
    final activeTickets = provider.reservations.where((r) =>
      (r.patientId == patientId || (r.patientName.isNotEmpty && r.patientName == patientName)) &&
      r.status != ReservationStatus.completed &&
      r.status != ReservationStatus.cancelled
    ).toList();
    final historyTickets = provider.reservations.where((r) =>
      (r.patientId == patientId || (r.patientName.isNotEmpty && r.patientName == patientName)) &&
      (r.status == ReservationStatus.completed || r.status == ReservationStatus.cancelled)
    ).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppColors.primaryDark,
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
              tabs: const [Tab(text: 'Tiket Aktif'), Tab(text: 'Histori Reservasi')],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Tiket Aktif
                activeTickets.isEmpty
                    ? Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle), child: Icon(Icons.confirmation_number_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.5))),
                          const SizedBox(height: 16),
                          Text('Belum ada tiket aktif', style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text('Buat reservasi dokter di tab Cari Dokter', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary.withValues(alpha: 0.7))),
                        ]),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: activeTickets.length,
                        itemBuilder: (context, index) => TicketCard(ticket: activeTickets[index]),
                      ),

                // Histori Reservasi
                historyTickets.isEmpty
                    ? Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle), child: Icon(Icons.history, size: 48, color: AppColors.primary.withValues(alpha: 0.5))),
                          const SizedBox(height: 16),
                          Text('Belum ada riwayat reservasi', style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
                        ]),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: historyTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = historyTickets[index];
                          final isCompleted = ticket.status == ReservationStatus.completed;
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
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(color: (isCompleted ? AppColors.success : AppColors.danger).withValues(alpha: 0.1), shape: BoxShape.circle),
                                    child: Icon(isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined, color: isCompleted ? AppColors.success : AppColors.danger, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Dr. ${ticket.doctorName}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                                        Text('No. ${ticket.queueNumber} · ${ticket.date.day}/${ticket.date.month}/${ticket.date.year}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                                        Text('Kode: ${ticket.barcodeCode}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isCompleted ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(isCompleted ? 'SELESAI' : 'BATAL', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: isCompleted ? AppColors.success : AppColors.danger)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 4: PROFIL SAYA =================
  Widget _buildPatientProfileTab(BuildContext context, MainViewModel provider, UserModel user) {
    final totalReservations = provider.reservations.where((r) => r.patientId == user.id || r.patientName == user.name).length;
    final completedCount = provider.reservations.where((r) => (r.patientId == user.id || r.patientName == user.name) && r.status == ReservationStatus.completed).length;
    final pendingCount = totalReservations - completedCount;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
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
                  child: const Icon(Icons.person, size: 46, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(user.name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 2),
                Text(user.email, style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                  child: Text('Pasien Terdaftar', style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
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
                    Expanded(child: _buildStatCard('Total Reservasi', '$totalReservations', Icons.calendar_today, AppColors.secondary)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Selesai Berobat', '$completedCount', Icons.check_circle, AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Menunggu', '$pendingCount', Icons.hourglass_top, AppColors.warning)),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                  child: Column(
                    children: [
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.badge_outlined, color: AppColors.primary, size: 20)),
                        title: Text('Nomor ID Pasien', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(user.id.length >= 8 ? user.id.substring(0, 8).toUpperCase() : user.id, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade100),
                      ListTile(
                        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.verified_outlined, color: AppColors.success, size: 20)),
                        title: Text('Status Akun', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text('AKTIF', style: GoogleFonts.inter(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: () => provider.logout(),
                    icon: const Icon(Icons.logout_outlined, color: Colors.white, size: 20),
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 16)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
