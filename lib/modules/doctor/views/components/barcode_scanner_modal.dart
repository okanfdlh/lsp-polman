import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../main.dart';
import '../../../../viewmodels/main_viewmodel.dart';
import 'verify_patient_dialog.dart';

class BarcodeScannerModal extends StatefulWidget {
  final MainViewModel provider;

  const BarcodeScannerModal({
    super.key,
    required this.provider,
  });

  @override
  State<BarcodeScannerModal> createState() => _BarcodeScannerModalState();
}

class _BarcodeScannerModalState extends State<BarcodeScannerModal> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() => _hasScanned = true);
        _scannerController.stop();

        final res = widget.provider.findReservationByBarcode(code.trim());
        if (res != null) {
          if (mounted) {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => VerifyPatientDialog(provider: widget.provider, res: res),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Kode "$code" tidak ditemukan!', style: GoogleFonts.inter(color: Colors.white))),
                ]),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() => _hasScanned = false);
                _scannerController.start();
              }
            });
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scan Tiket Pasien', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('Arahkan ke barcode/QR Code', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _torchOn ? Colors.amber.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_torchOn ? Icons.flash_on : Icons.flash_off, size: 18, color: Colors.white),
            ),
            onPressed: () {
              _scannerController.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.cameraswitch_outlined, size: 18, color: Colors.white),
            ),
            onPressed: () => _scannerController.switchCamera(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // Dark overlay with cutout effect
          ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
            child: Stack(
              children: [
                Container(color: Colors.black.withValues(alpha: 0.5), width: double.infinity, height: double.infinity),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scan frame corners
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [
                  // Top-left corner
                  Positioned(top: 0, left: 0, child: _buildCorner(true, true)),
                  // Top-right corner
                  Positioned(top: 0, right: 0, child: _buildCorner(true, false)),
                  // Bottom-left corner
                  Positioned(bottom: 0, left: 0, child: _buildCorner(false, true)),
                  // Bottom-right corner
                  Positioned(bottom: 0, right: 0, child: _buildCorner(false, false)),
                ],
              ),
            ),
          ),

          // Status indicator
          if (_hasScanned)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.9), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
            ),

          // Bottom hint
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner, color: AppColors.primaryLight, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Posisikan barcode / QR Code tiket di dalam bingkai untuk verifikasi otomatis',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool top, bool left) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: AppColors.primaryLight, width: 3) : BorderSide.none,
          bottom: !top ? const BorderSide(color: AppColors.primaryLight, width: 3) : BorderSide.none,
          left: left ? const BorderSide(color: AppColors.primaryLight, width: 3) : BorderSide.none,
          right: !left ? const BorderSide(color: AppColors.primaryLight, width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}
