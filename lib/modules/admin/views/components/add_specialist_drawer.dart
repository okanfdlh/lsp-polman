import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../main.dart';
import '../../models/admin_models.dart';
import '../../../../viewmodels/main_viewmodel.dart';

class AddSpecialistDrawer extends StatefulWidget {
  final MainViewModel provider;
  final Function(String message, {bool isError}) onShowSnackBar;
  final SpecialistModel? specialistToEdit;

  const AddSpecialistDrawer({
    super.key,
    required this.provider,
    required this.onShowSnackBar,
    this.specialistToEdit,
  });

  @override
  State<AddSpecialistDrawer> createState() => _AddSpecialistDrawerState();
}

class _AddSpecialistDrawerState extends State<AddSpecialistDrawer> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  bool _isLoading = false;

  bool get isEdit => widget.specialistToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      nameCtrl.text = widget.specialistToEdit!.name;
      descCtrl.text = widget.specialistToEdit!.description;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
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
                    child: Icon(isEdit ? Icons.edit_outlined : Icons.add_circle_outline, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEdit ? 'Edit Spesialisasi' : 'Tambah Spesialisasi', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Bidang spesialisasi medis dokter', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
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
                    const SizedBox(height: 4),
                    Text('Nama Spesialisasi', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Spesialis Penyakit Dalam',
                        prefixIcon: Icon(Icons.category_outlined, size: 20, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Deskripsi Singkat', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Deskripsi bidang spesialisasi ini...',
                        prefixIcon: Icon(Icons.description_outlined, size: 20, color: AppColors.primary),
                      ),
                    ),
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
                      : Icon(isEdit ? Icons.save_outlined : Icons.add, color: Colors.white),
                  label: Text(isEdit ? 'Perbarui Spesialisasi' : 'Simpan Spesialisasi', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                  onPressed: _isLoading ? null : () async {
                    if (nameCtrl.text.isEmpty) {
                      widget.onShowSnackBar('Nama spesialisasi tidak boleh kosong!', isError: true);
                      return;
                    }
                    setState(() => _isLoading = true);
                    bool ok;
                    if (isEdit) {
                      ok = await widget.provider.updateSpecialist(widget.specialistToEdit!.id, nameCtrl.text.trim(), descCtrl.text.trim());
                    } else {
                      ok = await widget.provider.addSpecialist(nameCtrl.text.trim(), descCtrl.text.trim());
                    }
                    if (mounted) setState(() => _isLoading = false);
                    if (context.mounted) Navigator.pop(context);
                    widget.onShowSnackBar(
                      ok ? (isEdit ? 'Spesialisasi berhasil diperbarui!' : 'Spesialisasi berhasil ditambahkan!') : 'Gagal menyimpan. Periksa koneksi.',
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
}
