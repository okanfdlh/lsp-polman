import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/main_viewmodel.dart';

class AuthLogic {
  static Future<bool> handleLogin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final viewModel = Provider.of<MainViewModel>(context, listen: false);
    return await viewModel.login(email, password);
  }

  static Future<bool> handleRegister({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
  }) async {
    final viewModel = Provider.of<MainViewModel>(context, listen: false);
    return await viewModel.registerPatient(name, email, password);
  }
}
