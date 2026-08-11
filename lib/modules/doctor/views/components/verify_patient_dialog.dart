import 'package:flutter/material.dart';
import '../../../patient/models/patient_models.dart';
import '../../../../viewmodels/main_viewmodel.dart';

class VerifyPatientDialog extends StatelessWidget {
  final MainViewModel provider;
  final ReservationModel res;

  const VerifyPatientDialog({
    super.key,
    required this.provider,
    required this.res,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pasien: ${res.patientName} (${res.queueNumber})'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kode Barcode: ${res.barcodeCode}'),
          Text('Unit: ${res.unitName}'),
          const SizedBox(height: 12),
          Text('Status Saat Ini: ${res.status.name.toUpperCase()}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            provider.updateReservationStatus(res.id, ReservationStatus.completed);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pemeriksaan Selesai!')));
          },
          child: const Text('Tandai Selesai', style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}
