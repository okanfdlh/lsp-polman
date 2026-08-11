import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../patient/models/patient_models.dart';
import '../../../viewmodels/main_viewmodel.dart';

class DoctorLogic {
  static ReservationModel? verifyBarcode(BuildContext context, String barcode) {
    final viewModel = Provider.of<MainViewModel>(context, listen: false);
    return viewModel.findReservationByBarcode(barcode.trim());
  }
}
