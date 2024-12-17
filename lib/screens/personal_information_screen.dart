import 'package:finance_manager_apps/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PersonalInformationScreen extends StatefulWidget {
  @override
  _PersonalInformationScreenState createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final SupabaseService supabaseService = SupabaseService();
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final fetchedInfo = await supabaseService.getProfileInformation(userId);
      setState(() {
        userInfo = fetchedInfo ??
            {
              'created_at': '2024-12-01T00:00:00.000Z',
              'name': 'User',
              'email': 'N/A',
            }; // Default data jika tidak ditemukan
      });
    }
  }

  String _formatJoinDate(String createdAt) {
    try {
      final DateTime parsedDate = DateTime.parse(createdAt);
      return DateFormat('d MMM y').format(parsedDate);
    } catch (e) {
      return 'N/A';
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
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Get.offAllNamed(AppRoutes.dashboard);
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
                  'Personal Information',
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
                    userInfo?['name'] ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Joined ${_formatJoinDate(userInfo?['created_at'] ?? '')}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                      color: Color(0xFF7E848D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Full Name Label dan Value
            const Text(
              'Full Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                color: Color(0xFFA2A2A7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userInfo?['name'] ?? 'Loading...',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
            const Divider(
              color: Color.fromARGB(118, 208, 216, 230),
              thickness: 1,
              height: 32,
            ),
            const SizedBox(height: 24),

            // Email Address Label dan Value
            const Text(
              'Email Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                color: Color(0xFFA2A2A7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userInfo?['email'] ?? 'Loading...',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
            const Divider(
              color: Color.fromARGB(118, 208, 216, 230),
              thickness: 1,
              height: 32,
            ),
          ],
        ),
      ),
    );
  }
}
