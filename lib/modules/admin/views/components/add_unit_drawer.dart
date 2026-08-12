import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../main.dart';
import '../../models/admin_models.dart';
import '../../../../viewmodels/main_viewmodel.dart';
import '../../../../services/map/location_service.dart';
import '../../logic/admin_logic.dart';

class AddUnitDrawer extends StatefulWidget {
  final MainViewModel provider;
  final Function(String message, {bool isError}) onShowSnackBar;
  final UnitModel? unitToEdit;

  const AddUnitDrawer({
    super.key,
    required this.provider,
    required this.onShowSnackBar,
    this.unitToEdit,
  });

  @override
  State<AddUnitDrawer> createState() => _AddUnitDrawerState();
}

class _AddUnitDrawerState extends State<AddUnitDrawer> {
  final nameCtrl = TextEditingController();
  final hospitalCtrl = TextEditingController(text: 'RS Sehat Sejahtera');
  final addressCtrl = TextEditingController();
  final searchCtrl = TextEditingController();
  final latCtrl = TextEditingController(text: '-6.208800');
  final lngCtrl = TextEditingController(text: '106.845600');

  final MapController _mapController = MapController();
  LatLng _selectedLatLng = const LatLng(-6.208800, 106.845600);

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLocatingUser = false;
  bool _isLoading = false;

  bool get isEdit => widget.unitToEdit != null;

  final List<Map<String, dynamic>> _presetPlaces = [
    {'display_name': 'Puskesmas Sungailiat, Kab. Bangka, Kepulauan Bangka Belitung', 'lat': -1.856611, 'lon': 106.115456},
    {'display_name': 'RSUD Depati Bahrin Sungailiat, Kab. Bangka', 'lat': -1.862400, 'lon': 106.118900},
    {'display_name': 'RS Medika Stania Sungailiat, Kab. Bangka', 'lat': -1.854200, 'lon': 106.112100},
    {'display_name': 'RS Sehat Sejahtera (Pusat), Jakarta Pusat', 'lat': -6.208800, 'lon': 106.845600},
  ];

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final unit = widget.unitToEdit!;
      nameCtrl.text = unit.name;
      hospitalCtrl.text = unit.hospitalName;
      addressCtrl.text = unit.address;
      latCtrl.text = unit.latitude.toStringAsFixed(6);
      lngCtrl.text = unit.longitude.toStringAsFixed(6);
      _selectedLatLng = LatLng(unit.latitude, unit.longitude);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    hospitalCtrl.dispose();
    addressCtrl.dispose();
    searchCtrl.dispose();
    latCtrl.dispose();
    lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    final localMatches = _presetPlaces.where((p) {
      final name = p['display_name'].toString().toLowerCase();
      return name.contains(q);
    }).toList();

    final apiResults = await AdminLogic.searchOSMPlaces(q);

    if (mounted) {
      setState(() {
        _searchResults = [...localMatches, ...apiResults];
        _isSearching = false;
      });
    }
  }

  void _onLocationSelected(LatLng latLng, {String? displayName}) async {
    setState(() {
      _selectedLatLng = latLng;
      latCtrl.text = latLng.latitude.toStringAsFixed(6);
      lngCtrl.text = latLng.longitude.toStringAsFixed(6);
      _searchResults = [];
    });
    _mapController.move(latLng, 16.0);

    if (displayName != null) {
      addressCtrl.text = displayName;
      searchCtrl.text = displayName;
    } else {
      final address = await AdminLogic.reverseGeocode(latLng);
      if (address != null && mounted) {
        setState(() {
          addressCtrl.text = address;
          searchCtrl.text = address;
        });
      }
    }
  }

  Future<void> _getUserLocation() async {
    setState(() => _isLocatingUser = true);
    final userPos = await LocationService.getCurrentLocation(context);
    setState(() => _isLocatingUser = false);
    if (userPos != null) {
      _onLocationSelected(userPos);
      widget.onShowSnackBar('Lokasi perangkat Anda berhasil ditemukan!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.92,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(isEdit ? Icons.edit_location_outlined : Icons.add_location_outlined, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEdit ? 'Edit Unit / Poli' : 'Tambah Unit / Poli Baru', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Atur lokasi unit di peta interaktif', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    _buildLabel('Nama Poliklinik / Unit'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Poli Penyakit Dalam',
                        prefixIcon: Icon(Icons.local_hospital_outlined, size: 20, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Nama Rumah Sakit / Faskes'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: hospitalCtrl,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Contoh: RS Sehat Sejahtera',
                        prefixIcon: Icon(Icons.business_outlined, size: 20, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // GPS Location button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isLocatingUser
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                            : const Icon(Icons.my_location, color: AppColors.primary, size: 18),
                        label: Text(
                          _isLocatingUser ? 'Mencari lokasi...' : 'Gunakan Lokasi GPS Perangkat',
                          style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        onPressed: _isLocatingUser ? null : _getUserLocation,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Search field
                    Row(
                      children: [
                        const Icon(Icons.search, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('Cari Lokasi di Peta', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: searchCtrl,
                      onChanged: (val) => _performSearch(val),
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ketik nama lokasi (Puskesmas, RS...)',
                        prefixIcon: const Icon(Icons.place_outlined, size: 20, color: AppColors.primary),
                        suffixIcon: _isSearching
                            ? const Padding(padding: EdgeInsets.all(10.0), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
                            : IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                                onPressed: () {
                                  searchCtrl.clear();
                                  setState(() => _searchResults = []);
                                },
                              ),
                      ),
                    ),

                    // Search results dropdown
                    if (_searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        constraints: const BoxConstraints(maxHeight: 190),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              leading: const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                              title: Text(
                                item['display_name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary),
                              ),
                              onTap: () {
                                final newPos = LatLng(item['lat'], item['lon']);
                                _onLocationSelected(newPos, displayName: item['display_name']);
                                widget.onShowSnackBar('Lokasi ditemukan & peta diperbarui!');
                              },
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 14),

                    // Map label with coordinates
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.map_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('Peta Interaktif', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFE0F5F2), borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            '${_selectedLatLng.latitude.toStringAsFixed(4)}, ${_selectedLatLng.longitude.toStringAsFixed(4)}',
                            style: GoogleFonts.inter(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Interactive Map
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 220,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _selectedLatLng,
                            initialZoom: 15.0,
                            onTap: (tapPosition, point) => _onLocationSelected(point),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.lsp',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLatLng,
                                  width: 44,
                                  height: 44,
                                  child: const Icon(Icons.location_on, color: Color(0xFFE53935), size: 44),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '* Ketuk titik di peta untuk memindahkan pin & koordinat otomatis terisi',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 14),

                    // Address field
                    _buildLabel('Alamat Lengkap'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressCtrl,
                      maxLines: 2,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Alamat lengkap unit / gedung RS...',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lat/Lng display
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: latCtrl,
                            readOnly: true,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              prefixIcon: Icon(Icons.my_location_outlined, size: 18, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: lngCtrl,
                            readOnly: true,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              prefixIcon: Icon(Icons.explore_outlined, size: 18, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Icon(isEdit ? Icons.save_outlined : Icons.add_location_alt_outlined, color: Colors.white),
                  label: Text(isEdit ? 'Perbarui Unit Poli' : 'Simpan Unit Poli', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                  onPressed: _isLoading ? null : () async {
                    if (nameCtrl.text.isEmpty || addressCtrl.text.isEmpty) {
                      widget.onShowSnackBar('Harap lengkapi nama poli dan alamat!', isError: true);
                      return;
                    }
                    setState(() => _isLoading = true);
                    bool ok;
                    if (isEdit) {
                      ok = await widget.provider.updateUnit(
                        id: widget.unitToEdit!.id,
                        name: nameCtrl.text.trim(),
                        hospitalName: hospitalCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                        latitude: double.tryParse(latCtrl.text) ?? _selectedLatLng.latitude,
                        longitude: double.tryParse(lngCtrl.text) ?? _selectedLatLng.longitude,
                      );
                    } else {
                      ok = await widget.provider.addUnit(
                        name: nameCtrl.text.trim(),
                        hospitalName: hospitalCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                        latitude: double.tryParse(latCtrl.text) ?? _selectedLatLng.latitude,
                        longitude: double.tryParse(lngCtrl.text) ?? _selectedLatLng.longitude,
                      );
                    }
                    if (mounted) setState(() => _isLoading = false);
                    if (context.mounted) Navigator.pop(context);
                    widget.onShowSnackBar(
                      ok ? (isEdit ? 'Unit poli berhasil diperbarui!' : 'Unit poli berhasil ditambahkan!') : 'Gagal menyimpan. Periksa koneksi.',
                      isError: !ok,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }
}
