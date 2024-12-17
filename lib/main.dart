import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/constants.dart';
import 'utils/app_routes.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: Constants.supabaseUrl,
    anonKey: Constants.supabaseKey,
  );

  // Inisialisasi AuthController setelah Supabase
  Get.put(AuthController());

  // Periksa sesi saat aplikasi dimulai
  final session = Supabase.instance.client.auth.currentSession;
  final initialRoute = session != null ? AppRoutes.dashboard : AppRoutes.splash;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Manager App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: const Color(0xFF0066FF),
      ),
      initialRoute: initialRoute, // Rute awal berdasarkan sesi
      getPages: AppRoutes.pages,
    );
  }
}
