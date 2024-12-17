import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    restoreSession(); // Pulihkan sesi saat controller diinisialisasi
  }

  Future<void> restoreSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      // Tunda navigasi hingga GetMaterialApp siap
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.offAllNamed('/dashboard');
      });
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading(true);
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        Get.offAllNamed('/dashboard'); // Navigate to dashboard
        return true;
      } else {
        return false; // Login failed
      }
    } catch (e) {
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await Supabase.instance.client.from('users').insert({
          'id': response.user!.id,
          'name': fullName,
          'email': email,
        });
        return true; // Registrasi berhasil
      } else {
        return false; // Registrasi gagal
      }
    } catch (e) {
      return false; // Error pada proses registrasi
    }
  }


  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    Get.offAllNamed('/login');
  }
}
