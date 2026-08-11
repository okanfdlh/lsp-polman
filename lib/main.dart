import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/models.dart';
import 'providers/app_provider.dart';
import 'screens/app_screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://obtsgtsjbnpzgldzwzvz.supabase.co',
    publishableKey: 'sb_publishable_fcgYZH_yGoyB81rNXoe2Tw_-6A8enHN',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pelayanan Kesehatan RS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const RootRouter(),
    );
  }
}

class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;

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
