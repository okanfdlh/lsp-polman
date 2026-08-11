import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../viewmodels/main_viewmodel.dart';
import '../modules/auth/auth_screens.dart';
import '../modules/patient/patient_home_screen.dart';
import '../modules/doctor/doctor_home_screen.dart';
import '../modules/admin/admin_home_screen.dart';

class AppRoutes {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String patientHome = '/patient-home';
  static const String doctorHome = '/doctor-home';
  static const String adminHome = '/admin-home';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        patientHome: (context) => const PatientHomeScreen(),
        doctorHome: (context) => const DoctorHomeScreen(),
        adminHome: (context) => const AdminHomeScreen(),
      };
}

class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);
    final user = viewModel.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    switch (user.role) {
      case UserRole.patient:
        return const PatientHomeScreen();
      case UserRole.doctor:
        return const DoctorHomeScreen();
      case UserRole.admin:
        return const AdminHomeScreen();
    }
  }
}
