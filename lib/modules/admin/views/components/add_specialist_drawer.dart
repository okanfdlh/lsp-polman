import 'package:flutter/material.dart';
import '../../../../viewmodels/main_viewmodel.dart';

class AddSpecialistDrawer extends StatefulWidget {
  final MainViewModel provider;
  final Function(String message, {bool isError}) onShowSnackBar;

  const AddSpecialistDrawer({
    super.key,
    required this.provider,
    required this.onShowSnackBar,
  });

  @override
  State<AddSpecialistDrawer> createState() => _AddSpecialistDrawerState();
}

class _AddSpecialistDrawerState extends State<AddSpecialistDrawer> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

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
                  const Text('Tambah Spesialisasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Spesialis', border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi Singkat', border: OutlineInputBorder())),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size.fromHeight(50)),
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty) {
                    final ok = await widget.provider.addSpecialist(nameCtrl.text.trim(), descCtrl.text.trim());
                    if (context.mounted) Navigator.pop(context);
                    if (ok) {
                      widget.onShowSnackBar('Spesialisasi berhasil ditambahkan');
                    } else {
                      widget.onShowSnackBar('Gagal menambah spesialisasi. Periksa hak akses database RLS.', isError: true);
                    }
                  }
                },
                child: const Text('Simpan Spesialis', style: TextStyle(color: Colors.white, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
