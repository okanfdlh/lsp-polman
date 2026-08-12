import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../main.dart';
import '../../models/patient_models.dart';

class TicketCard extends StatelessWidget {
  final ReservationModel ticket;

  const TicketCard({super.key, required this.ticket});

  Color get _statusColor {
    switch (ticket.status) {
      case ReservationStatus.waiting: return AppColors.warning;
      case ReservationStatus.inProgress: return AppColors.secondary;
      case ReservationStatus.completed: return AppColors.success;
      case ReservationStatus.cancelled: return AppColors.danger;
    }
  }

  String get _statusLabel {
    switch (ticket.status) {
      case ReservationStatus.waiting: return 'MENUNGGU';
      case ReservationStatus.inProgress: return 'DIPANGGIL';
      case ReservationStatus.completed: return 'SELESAI';
      case ReservationStatus.cancelled: return 'DIBATALKAN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          // Header gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NOMOR ANTREAN', style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                    const SizedBox(height: 2),
                    Text(ticket.queueNumber, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: Text(_statusLabel, style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),

          // Divider with dashes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                ),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        (constraints.constrainWidth() / 12).floor(),
                        (index) => Container(width: 6, height: 1.5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(1))),
                      ),
                    );
                  }),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                ),
              ],
            ),
          ),

          // QR Code section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: QrImageView(
                      data: ticket.barcodeCode,
                      version: QrVersions.auto,
                      size: 150.0,
                      eyeStyle: const QrEyeStyle(color: AppColors.primaryDark, eyeShape: QrEyeShape.square),
                      dataModuleStyle: const QrDataModuleStyle(color: AppColors.textPrimary, dataModuleShape: QrDataModuleShape.square),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFF0F9F7), borderRadius: BorderRadius.circular(8)),
                  child: Text(ticket.barcodeCode, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1.5, color: AppColors.primaryDark)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF8FFFE), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.person_outline, 'Dokter', ticket.doctorName),
                      const SizedBox(height: 6),
                      _buildInfoRow(Icons.medical_information_outlined, 'Spesialisasi', ticket.specialistName),
                      const SizedBox(height: 6),
                      _buildInfoRow(Icons.local_hospital_outlined, 'Unit/Poli', ticket.unitName),
                      const SizedBox(height: 6),
                      _buildInfoRow(Icons.calendar_today_outlined, 'Tanggal', '${ticket.date.day}/${ticket.date.month}/${ticket.date.year}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label:', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(width: 4),
        Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
