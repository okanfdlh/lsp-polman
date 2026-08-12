import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../main.dart';
import '../../../patient/models/patient_models.dart';
import '../../../../viewmodels/main_viewmodel.dart';

class VerifyPatientDialog extends StatefulWidget {
  final MainViewModel provider;
  final ReservationModel res;

  const VerifyPatientDialog({
    super.key,
    required this.provider,
    required this.res,
  });

  @override
  State<VerifyPatientDialog> createState() => _VerifyPatientDialogState();
}

class _VerifyPatientDialogState extends State<VerifyPatientDialog> {
  late ReservationStatus _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.res.status;
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.waiting: return AppColors.warning;
      case ReservationStatus.inProgress: return AppColors.secondary;
      case ReservationStatus.completed: return AppColors.success;
      case ReservationStatus.cancelled: return AppColors.danger;
    }
  }

  IconData _getStatusIcon(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.waiting: return Icons.hourglass_empty;
      case ReservationStatus.inProgress: return Icons.play_circle_outline;
      case ReservationStatus.completed: return Icons.check_circle_outline;
      case ReservationStatus.cancelled: return Icons.cancel_outlined;
    }
  }

  String _getStatusLabel(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.waiting: return 'Menunggu';
      case ReservationStatus.inProgress: return 'Sedang Periksa';
      case ReservationStatus.completed: return 'Selesai';
      case ReservationStatus.cancelled: return 'Dibatalkan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.qr_code_2, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 10),
                  Text('Verifikasi Tiket Pasien', style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 2),
                  Text(widget.res.patientName, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),

            // Patient Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Queue number badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F5F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.confirmation_number_outlined, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text('Nomor Antrean: ', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                          Text(widget.res.queueNumber, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Detail info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF8FFFE), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.qr_code_outlined, 'Kode Tiket', widget.res.barcodeCode),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.medical_information_outlined, 'Spesialisasi', widget.res.specialistName),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.local_hospital_outlined, 'Unit / Poli', widget.res.unitName),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status updater
                  Text('Perbarui Status Antrean', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _getStatusColor(_selectedStatus).withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(12),
                      color: _getStatusColor(_selectedStatus).withValues(alpha: 0.05),
                    ),
                    child: DropdownButtonFormField<ReservationStatus>(
                      value: _selectedStatus,
                      isExpanded: true,
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4)),
                      dropdownColor: Colors.white,
                      items: ReservationStatus.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Icon(_getStatusIcon(s), color: _getStatusColor(s), size: 18),
                              const SizedBox(width: 8),
                              Text(_getStatusLabel(s), style: GoogleFonts.inter(fontSize: 14, color: _getStatusColor(s), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: _isLoading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.save_outlined, color: Colors.white, size: 18),
                          label: Text(_isLoading ? 'Menyimpan...' : 'Update Status', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                          onPressed: _isLoading ? null : () async {
                            setState(() => _isLoading = true);
                            await widget.provider.updateReservationStatus(widget.res.id, _selectedStatus);
                            if (mounted) setState(() => _isLoading = false);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(children: [
                                    const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('Status ${widget.res.patientName} → ${_getStatusLabel(_selectedStatus)}', style: GoogleFonts.inter(color: Colors.white))),
                                  ]),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
