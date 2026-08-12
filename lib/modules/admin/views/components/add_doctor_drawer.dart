import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../main.dart';
import '../../models/admin_models.dart';
import '../../../doctor/models/doctor_models.dart';
import '../../../../viewmodels/main_viewmodel.dart';

class AddDoctorDrawer extends StatefulWidget {
  final MainViewModel provider;
  final Function(String message, {bool isError}) onShowSnackBar;
  final DoctorModel? doctorToEdit;

  const AddDoctorDrawer({
    super.key,
    required this.provider,
    required this.onShowSnackBar,
    this.doctorToEdit,
  });

  @override
  State<AddDoctorDrawer> createState() => _AddDoctorDrawerState();
}

class _AddDoctorDrawerState extends State<AddDoctorDrawer> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController(text: 'dokter123');

  String startDay = 'Senin';
  String endDay = 'Jumat';
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 12, minute: 0);

  SpecialistModel? selectedSpecialist;
  UnitModel? selectedUnit;
  bool _isLoading = false;

  bool get isEdit => widget.doctorToEdit != null;

  final List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final doc = widget.doctorToEdit!;
      nameCtrl.text = doc.name;
      final emailName = doc.name.toLowerCase().replaceAll('dr.', '').replaceAll('sp.', '').replaceAll(' ', '').trim();
      emailCtrl.text = '$emailName@gmail.com';
      selectedSpecialist = widget.provider.specialists.firstWhere(
        (s) => s.id == doc.specialistId,
        orElse: () => widget.provider.specialists.isNotEmpty ? widget.provider.specialists.first : SpecialistModel(id: '', name: '', description: ''),
      );
      selectedUnit = widget.provider.units.firstWhere(
        (u) => u.id == doc.unitId,
        orElse: () => widget.provider.units.isNotEmpty ? widget.provider.units.first : UnitModel(id: '', name: '', hospitalName: '', address: '', latitude: 0, longitude: 0),
      );
    } else {
      selectedSpecialist = null;
      selectedUnit = null;
    }
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: startTime);
    if (picked != null) setState(() => startTime = picked);
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: endTime);
    if (picked != null) setState(() => endTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.88,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(isEdit ? Icons.edit_outlined : Icons.person_add_outlined, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEdit ? 'Edit Data Dokter' : 'Tambah Dokter Baru', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text(isEdit ? 'Perbarui informasi dokter' : 'Isi semua data dokter dengan benar', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nama Dokter (beserta Gelar)'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Contoh: dr. Budi Santoso, Sp.PD',
                        prefixIcon: Icon(Icons.person_outline, size: 20, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Email Login Dokter'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'dokter@rumahsakit.com',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.primary),
                        helperText: isEdit ? 'Email akun login terdaftar' : 'Email ini digunakan dokter untuk login',
                        helperStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (!isEdit) ...[
                      _buildLabel('Password Login Dokter'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Minimal 6 karakter',
                          prefixIcon: Icon(Icons.lock_outline, size: 20, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildSectionHeader('Spesialisasi Dokter', Icons.medical_information_outlined),
                    const SizedBox(height: 8),
                    Autocomplete<SpecialistModel>(
                      initialValue: TextEditingValue(text: selectedSpecialist?.name ?? ''),
                      displayStringForOption: (option) => option.name,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) return widget.provider.specialists;
                        return widget.provider.specialists.where((s) => s.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (SpecialistModel selection) {
                        setState(() => selectedSpecialist = selection);
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          style: GoogleFonts.inter(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Cari & pilih spesialisasi...',
                            prefixIcon: Icon(Icons.category_outlined, size: 20, color: AppColors.primary),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildSectionHeader('Unit / Poliklinik', Icons.local_hospital_outlined),
                    const SizedBox(height: 8),
                    Autocomplete<UnitModel>(
                      initialValue: TextEditingValue(text: selectedUnit?.name ?? ''),
                      displayStringForOption: (option) => option.name,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) return widget.provider.units;
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
                          style: GoogleFonts.inter(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Cari & pilih unit poliklinik...',
                            prefixIcon: Icon(Icons.local_hospital_outlined, size: 20, color: AppColors.primary),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildSectionHeader('Jadwal Praktek', Icons.schedule_outlined),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: startDay,
                            isExpanded: true,
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                            decoration: const InputDecoration(labelText: 'Dari Hari'),
                            items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (v) => setState(() => startDay = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: endDay,
                            isExpanded: true,
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                            decoration: const InputDecoration(labelText: 'Sampai Hari'),
                            items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (v) => setState(() => endDay = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickStartTime(context),
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Jam Buka', prefixIcon: Icon(Icons.access_time_outlined, size: 20, color: AppColors.primary)),
                              child: Text(startTime.format(context), style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickEndTime(context),
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Jam Tutup', prefixIcon: Icon(Icons.access_time_filled_outlined, size: 20, color: AppColors.primary)),
                              child: Text(endTime.format(context), style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                      : Icon(isEdit ? Icons.save_outlined : Icons.person_add_outlined, color: Colors.white),
                  label: Text(isEdit ? 'Perbarui Data Dokter' : 'Simpan Dokter Baru', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                  onPressed: _isLoading ? null : () async {
                    if (nameCtrl.text.isEmpty || selectedSpecialist == null || selectedUnit == null) {
                      widget.onShowSnackBar('Harap isi nama, pilih spesialis, dan unit poli!', isError: true);
                      return;
                    }
                    if (!isEdit && (emailCtrl.text.isEmpty || passCtrl.text.isEmpty)) {
                      widget.onShowSnackBar('Harap lengkapi Email dan Password login dokter!', isError: true);
                      return;
                    }

                    setState(() => _isLoading = true);
                    final scheduleStr = '$startDay - $endDay (${startTime.format(context)} - ${endTime.format(context)})';
                    bool ok;

                    if (isEdit) {
                      ok = await widget.provider.updateDoctor(
                        id: widget.doctorToEdit!.id,
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        specialistId: selectedSpecialist!.id,
                        unitId: selectedUnit!.id,
                        schedule: scheduleStr,
                      );
                    } else {
                      ok = await widget.provider.addDoctor(
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        password: passCtrl.text,
                        specialistId: selectedSpecialist!.id,
                        unitId: selectedUnit!.id,
                        schedule: scheduleStr,
                        imageUrl: 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                      );
                    }

                    if (mounted) setState(() => _isLoading = false);
                    if (context.mounted) Navigator.pop(context);
                    widget.onShowSnackBar(
                      ok
                          ? (isEdit ? 'Data Dokter berhasil diperbarui!' : 'Dokter berhasil ditambahkan!')
                          : 'Gagal menyimpan. Periksa koneksi dan hak akses.',
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

  Widget _buildSectionHeader(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ],
    );
  }
}
