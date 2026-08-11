import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modules/auth/models/auth_models.dart';
import '../viewmodels/main_viewmodel.dart';
import '../modules/splash/splash_screen.dart';
import '../modules/auth/views/auth_views.dart';
import '../modules/patient/views/patient_home_view.dart';
import '../modules/doctor/views/doctor_home_view.dart';
import '../modules/admin/views/admin_home_view.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String patientHome = '/patient-home';
  static const String doctorHome = '/doctor-home';
  static const String adminHome = '/admin-home';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginView(),
        register: (context) => const RegisterView(),
        patientHome: (context) => const PatientHomeView(),
        doctorHome: (context) => const DoctorHomeView(),
        adminHome: (context) => const AdminHomeView(),
      };
}

class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);
    final user = viewModel.currentUser;

    if (user == null) {
      return const LoginView();
    }

    switch (user.role) {
      case UserRole.patient:
        return const PatientHomeView();
      case UserRole.doctor:
        return const DoctorHomeView();
      case UserRole.admin:
        return const AdminHomeView();
    }
  }
}
