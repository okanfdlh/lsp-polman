import 'package:flutter/material.dart';
import '../../models/admin_models.dart';
import '../../../../viewmodels/main_viewmodel.dart';

class AddDoctorDrawer extends StatefulWidget {
  final MainViewModel provider;
  final Function(String message, {bool isError}) onShowSnackBar;

  const AddDoctorDrawer({
    super.key,
    required this.provider,
    required this.onShowSnackBar,
  });

  @override
  State<AddDoctorDrawer> createState() => _AddDoctorDrawerState();
}

class _AddDoctorDrawerState extends State<AddDoctorDrawer> {
  final nameCtrl = TextEditingController();
  final scheduleCtrl = TextEditingController(text: 'Senin - Jumat (08:00 - 12:00)');
  SpecialistModel? selectedSpecialist;
  UnitModel? selectedUnit;

  @override
  void initState() {
    super.initState();
    selectedSpecialist = widget.provider.specialists.isNotEmpty ? widget.provider.specialists.first : null;
    selectedUnit = widget.provider.units.isNotEmpty ? widget.provider.units.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tambah Data Dokter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Dokter (beserta Gelar)',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // DROPDOWN SEARCH / AUTOCOMPLETE SPESIALISASI
                      const Text(
                        'Pilih Spesialisasi (Searchable):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.deepOrange),
                      ),
                      const SizedBox(height: 6),
                      Autocomplete<SpecialistModel>(
                        initialValue: TextEditingValue(text: selectedSpecialist?.name ?? ''),
                        displayStringForOption: (option) => option.name,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return widget.provider.specialists;
                          }
                          return widget.provider.specialists.where((s) =>
                              s.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (SpecialistModel selection) {
                          setState(() => selectedSpecialist = selection);
                        },
                        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            decoration: const InputDecoration(
                              labelText: 'Cari & Pilih Spesialisasi...',
                              prefixIcon: Icon(Icons.category, color: Colors.deepOrange),
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // DROPDOWN SEARCH / AUTOCOMPLETE UNIT / POLIKLINIK
                      const Text(
                        'Pilih Unit / Poliklinik (Searchable):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.deepOrange),
                      ),
                      const SizedBox(height: 6),
                      Autocomplete<UnitModel>(
                        initialValue: TextEditingValue(text: selectedUnit?.name ?? ''),
                        displayStringForOption: (option) => option.name,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return widget.provider.units;
                          }
                          return widget.provider.units.where((u) =>
                              u.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                              u.hospitalName.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (UnitModel selection) {
                          setState(() => selectedUnit = selection);
                        },
                        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            decoration: const InputDecoration(
                              labelText: 'Cari & Pilih Unit / Poliklinik...',
                              prefixIcon: Icon(Icons.local_hospital, color: Colors.deepOrange),
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      TextField(
                        controller: scheduleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Jadwal Praktek',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Simpan Data Dokter', style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty && selectedSpecialist != null && selectedUnit != null) {
                    final ok = await widget.provider.addDoctor(
                      name: nameCtrl.text.trim(),
                      specialistId: selectedSpecialist!.id,
                      unitId: selectedUnit!.id,
                      schedule: scheduleCtrl.text.trim(),
                      imageUrl: 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                    );
                    if (context.mounted) Navigator.pop(context);
                    if (ok) {
                      widget.onShowSnackBar('Dokter berhasil ditambahkan!');
                    } else {
                      widget.onShowSnackBar('Gagal menambah dokter. Periksa hak akses database RLS.', isError: true);
                    }
                  } else {
                    widget.onShowSnackBar('Harap isi nama, pilih spesialis, dan unit poli!', isError: true);
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
