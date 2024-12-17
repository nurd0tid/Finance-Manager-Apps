import 'package:finance_manager_apps/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/xendit_service.dart';

class MyCardsScreen extends StatefulWidget {
  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  final SupabaseService supabaseService = SupabaseService();
  final XenditService xenditService = XenditService();

  bool isLoading = false;
  Map<String, dynamic>? userVA;
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
      print(userVA);

    if (userId != null) {
      final vaData = await supabaseService.getUserVA(userId);
      final fetchedName = await supabaseService.getUserName(userId);

      setState(() {
        userVA = vaData;
        userName = fetchedName ?? 'User';
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }



  Future<void> createVA() async {
    setState(() => isLoading = true);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    final fetchedName = await supabaseService.getUserName(userId!);

    if (userId != null && fetchedName != null) {
      try {
        final vaResponse = await xenditService.createVirtualAccount(userId, fetchedName);

        if (vaResponse.containsKey('account_number') && vaResponse.containsKey('bank_code')) {
          final expirationDate = DateTime.now().add(const Duration(days: 365));

          await supabaseService.updateUserVA(
            userId,
            vaResponse['account_number'],
            vaResponse['bank_code'],
            expirationDate,
            'user-$userId',
          );

          showCustomSnackbar(
            message: 'Virtual Account berhasil dibuat!',
            isSuccess: true,
          );

          await _loadUserData();
        }
      } catch (e) {
        showCustomSnackbar(
          message: 'Gagal membuat Virtual Account!',
          isSuccess: false,
        );
      }
    }
    setState(() => isLoading = false);
  }

  void showCustomSnackbar({required String message, required bool isSuccess}) {
    Get.snackbar(
      isSuccess ? 'Wohooo!' : 'Error',
      '',
      backgroundColor: Colors.grey[100],
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      titleText: Text(
        isSuccess ? 'Wohooo!' : 'Error',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          color: isSuccess ? Colors.green : Colors.red,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(fontSize: 14, fontFamily: 'Poppins', color: Colors.black),
      ),
    );
  }

  String _formatExpiryDate(String? timestamp) {
    if (timestamp == null) return '00/0000';
    final date = DateTime.parse(timestamp);
    return DateFormat('MM/yyyy').format(date);
  }

  String _formatVirtualAccount(String? va) {
    if (va == null) return '';
    return va.replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161622),
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Arrow dan Judul
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
                  'My Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Kartu
            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : userVA == null
                      ? GestureDetector(
                          onTap: createVA,
                          child: Image.asset(
                            'assets/card.png',
                            width: MediaQuery.of(context).size.width - 32,
                            height: 220,
                            fit: BoxFit.fill,
                          ),
                        )
                      : Stack(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width - 32,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    image: const DecorationImage(
                                      image: AssetImage('assets/uiCard.png'),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 24,
                                  left: 24,
                                  right: 24,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset(
                                        'assets/signCard.png',
                                        width: 29,
                                        height: 25,
                                      ),
                                      Image.asset(
                                        'assets/union.png',
                                        width: 29,
                                        height: 25,
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 65,
                                  left: 24,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatVirtualAccount(userVA?['virtual_account']),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        userName ?? 'User',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 24,
                                  right: 24,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Expiry Date',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFA2A2A7),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatExpiryDate(userVA?['va_expired_at']),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Image.asset(
                                        'assets/masterCard.png',
                                        width: 80,
                                        height: 80,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
