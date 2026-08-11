import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/patient_models.dart';

class TicketCard extends StatelessWidget {
  final ReservationModel ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Nomor Antrean: ${ticket.queueNumber}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 16),
            QrImageView(
              data: ticket.barcodeCode,
              version: QrVersions.auto,
              size: 160.0,
            ),
            const SizedBox(height: 8),
            Text(ticket.barcodeCode, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const Divider(height: 24),
            ListTile(
              dense: true,
              title: Text(ticket.doctorName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${ticket.specialistName}\n${ticket.unitName}'),
              trailing: Chip(
                label: Text(
                  ticket.status.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                backgroundColor: ticket.status == ReservationStatus.waiting
                    ? Colors.orange
                    : ticket.status == ReservationStatus.completed
                        ? Colors.green
                        : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
