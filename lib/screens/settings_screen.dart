import 'package:finance_manager_apps/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SupabaseService supabaseService = SupabaseService();
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final fetchedName = await supabaseService.getUserName(userId);
      setState(() {
        userName = fetchedName ?? 'User'; // Default nama jika tidak ditemukan
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161622),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 16),

            // Back Arrow dan Title
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    print('Can Pop: ${Navigator.canPop(context)}'); // Log apakah bisa pop
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Get.offAllNamed(AppRoutes.dashboard); // Navigasi ke dashboard
                    }
                  },
                  child: Center(
                    child: Image.asset(
                      'assets/arrow-back.png',
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Avatar dan Nama User
            Center(
              child: Column(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/avatar.jpg',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userName ?? 'Loading...', // Default jika nama belum selesai di-fetch
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Menu Items
            _buildMenuItem(
              iconPath: 'assets/icons/personal.svg',
              title: 'Personal Information',
              onTap: () {
                Get.toNamed(AppRoutes.personalInformation);
              },
            ),
            const Divider(
              color: Color.fromARGB(255, 228, 228, 230),
              thickness: 1,
              height: 1,
            ),
            _buildMenuItem(
              iconPath: 'assets/icons/banks.svg',
              title: 'Banks and Cards',
              onTap: () {
                Get.toNamed(AppRoutes.myCard);
              },
            ),
            const Divider(
              color: Color.fromARGB(255, 228, 228, 230),
              thickness: 1,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                  color: Color(0xFFA2A2A7),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFA2A2A7),
            ),
          ],
        ),
      ),
    );
  }
}
