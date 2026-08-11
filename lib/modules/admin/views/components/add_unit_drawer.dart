import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../viewmodels/main_viewmodel.dart';
import '../../logic/admin_logic.dart';

class AddUnitDrawer extends StatefulWidget {
  final MainViewModel provider;
  final Function(String message, {bool isError}) onShowSnackBar;

  const AddUnitDrawer({
    super.key,
    required this.provider,
    required this.onShowSnackBar,
  });

  @override
  State<AddUnitDrawer> createState() => _AddUnitDrawerState();
}

class _AddUnitDrawerState extends State<AddUnitDrawer> {
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final latCtrl = TextEditingController(text: '-6.208800');
  final lngCtrl = TextEditingController(text: '106.845600');

  final MapController _mapController = MapController();
  LatLng _selectedLatLng = const LatLng(-6.208800, 106.845600);

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  Future<void> _performSearch(String query) async {
    if (query.trim().length < 3) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await AdminLogic.searchOSMPlaces(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
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
    } else {
      final address = await AdminLogic.reverseGeocode(latLng);
      if (address != null && mounted) {
        setState(() => addressCtrl.text = address);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.90,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tambah Unit / Poli', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Poliklinik',
                          prefixIcon: Icon(Icons.local_hospital),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // INPUT PENCARIAN REAL LOKASI (OPENSTREETMAP NOMINATIM LIVE SEARCH)
                      const Text(
                        'Cari Lokasi Real (Contoh: Puskesmas Sungailiat):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.deepOrange),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        onChanged: (val) => _performSearch(val),
                        decoration: InputDecoration(
                          hintText: 'Ketik lokasi (misal: Puskesmas Sungailiat)...',
                          prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                          suffixIcon: _isSearching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : null,
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      // HASIL LIST PENCARIAN REAL-TIME
                      if (_searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 180),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.deepOrange),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final item = _searchResults[index];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.location_on, color: Colors.deepOrange, size: 20),
                                title: Text(
                                  item['display_name'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onTap: () {
                                  final newPos = LatLng(item['lat'], item['lon']);
                                  _onLocationSelected(newPos, displayName: item['display_name']);
                                  widget.onShowSnackBar('Lokasi ditemukan & peta telah diperbarui!');
                                },
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 16),

                      // INTERACTIVE MAP CONTAINER (FLUTTER_MAP)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Peta Interaktif (Tap Lokasi):',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.deepOrange),
                          ),
                          Text(
                            '${_selectedLatLng.latitude.toStringAsFixed(4)}, ${_selectedLatLng.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.deepOrange, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _selectedLatLng,
                              initialZoom: 15.0,
                              onTap: (tapPosition, point) {
                                _onLocationSelected(point);
                              },
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
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '* Ketuk titik di peta untuk memindahkan pin lokasi & koordinat otomatis',
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                      ),

                      const SizedBox(height: 16),
                      TextField(
                        controller: addressCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Lengkap / Lokasi Gedung',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: latCtrl,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                prefixIcon: Icon(Icons.my_location),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: lngCtrl,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                prefixIcon: Icon(Icons.explore),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Simpan Unit Poliklinik', style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty && addressCtrl.text.isNotEmpty) {
                    final ok = await widget.provider.addUnit(
                      name: nameCtrl.text.trim(),
                      hospitalName: 'RS Sehat Sejahtera',
                      address: addressCtrl.text.trim(),
                      latitude: double.tryParse(latCtrl.text) ?? _selectedLatLng.latitude,
                      longitude: double.tryParse(lngCtrl.text) ?? _selectedLatLng.longitude,
                    );
                    if (context.mounted) Navigator.pop(context);
                    if (ok) {
                      widget.onShowSnackBar('Unit poliklinik berhasil ditambahkan!');
                    } else {
                      widget.onShowSnackBar('Gagal menambah unit. Periksa hak akses database RLS.', isError: true);
                    }
                  } else {
                    widget.onShowSnackBar('Harap lengkapi nama poli dan alamat!', isError: true);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
