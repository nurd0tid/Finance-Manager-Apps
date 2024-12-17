import 'package:finance_manager_apps/services/xendit_service.dart';
import 'package:finance_manager_apps/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseService supabaseService = SupabaseService();
  final XenditService xenditService = XenditService();
  final AuthController authController = Get.find<AuthController>();

  String? userName;
  Map<String, dynamic>? userVA;
  List<Map<String, dynamic>>? data;
  bool isLoading = false;

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId != null) {
      final fetchedName = await supabaseService.getUserName(userId);
      final vaData = await supabaseService.getUserVA(userId);
      final fetchedTransaction = await supabaseService.getUserTransactionsLimit(userId!);

      setState(() {
        userName = fetchedName ?? 'User';
        userVA = vaData;
        data = fetchedTransaction;
        isLoading = false;
      });
    }
  }

  Future<void> createVA() async {
    setState(() => isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final fetchedName = await supabaseService.getUserName(userId!);

    if (userId != null && fetchedName != null) {
      try {
        final vaResponse = await xenditService.createVirtualAccount(userId, fetchedName);

        if (vaResponse.containsKey('account_number')) {
          final expirationDate = DateTime.now().add(const Duration(days: 365));

          await supabaseService.updateUserVA(
            userId,
            vaResponse['account_number'],
            vaResponse['bank_code'],
            expirationDate,
            'user-$userId',
          );

          showCustomSnackbar(message: 'Virtual Account berhasil dibuat!', isSuccess: true);
          await _loadUserData();
        }
      } catch (e) {
        print(e);
        showCustomSnackbar(message: 'Gagal membuat Virtual Account!', isSuccess: false);
      }
    }
    setState(() => isLoading = false);
  }

  String _formatVirtualAccount(String? va) {
    if (va == null) return '';
    return va.replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ');
  }

  String _formatExpiryDate(String? timestamp) {
    if (timestamp == null) return '00/0000';
    final date = DateTime.parse(timestamp);
    return DateFormat('MM/yyyy').format(date);
  }

  String _formatCurrencyDouble(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF161622),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar dan Welcome Text
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/avatar.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Welcome Text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back,",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF7E848D),
                            ),
                          ),
                          Text(
                            userName ?? 'Loading...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Logout Button
                  GestureDetector(
                    onTap: () async {
                      await authController.logout(); // Gunakan fungsi logout dari AuthController
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1E2D),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.logout, // Ikon logout
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card Section
            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                      onTap: () {
                        if (userVA == null) createVA();
                      },
                      child: userVA == null
                          ? Image.asset(
                              'assets/card.png',
                              width: screenWidth - 32,
                              height: 220,
                              fit: BoxFit.fill,
                            )
                          : Stack(
                              children: [
                                Container(
                                  width: screenWidth - 32,
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
            ),
            const SizedBox(height: 16),

            // Action Buttons (Top up, Explore, Withdraw)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton('assets/top-up.png', AppRoutes.topUp),
                  _buildActionButton('assets/explore.png', AppRoutes.explore),
                  _buildActionButton('assets/withdraw.png', AppRoutes.withdraw),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transaction Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Transaction",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.transactionHistory);
                    },
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0066FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scrollable Transactions Section
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Empty Transaction

                    if (isLoading) ...[
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                    ] else if (data == null || data!.isEmpty) ...[
                      Center(
                        child: Image.asset(
                          'assets/empty.png',
                          width: 120,
                          height: 120,
                        ),
                      ),
                    ] else ...[
                      Column(
                        children: List.generate(
                          data!.length,
                          (index) {
                            final item = data![index];
                            bool isIncome = item['transaction_type'] == 'topup';
                            IconData icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;
                            Color iconColor = isIncome ? Colors.green : Colors.red;

                            return Container(
                              height: 42,
                              width: MediaQuery.of(context).size.width - 32,
                              margin: EdgeInsets.only(bottom: 40, left: 16, right: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 42,
                                        width: 42,
                                        child: item['transaction_type'] == 'topup'
                                            ? Image.asset(
                                                'assets/inc.png', // Gambar untuk topup
                                                width: 42,
                                                height: 42,
                                                fit: BoxFit.fill,
                                              )
                                            : item['transaction_type'] == 'withdraw'
                                                ? Image.asset(
                                                    'assets/exp.png', // Gambar untuk withdraw
                                                    width: 42,
                                                    height: 42,
                                                    fit: BoxFit.fill,
                                                  )
                                                : Container(
                                                    // Gambar default untuk jenis transaksi lainnya
                                                    height: 42,
                                                    width: 42,
                                                    child: Image.network(
                                                      item['image'],
                                                      width: 42,
                                                      height: 42,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Capitalize transaction_type
                                          Text(
                                            // Kondisi untuk transaction_type
                                            item['transaction_type'] == 'explore'
                                                ? item['title'] ??
                                                    '' // Gunakan title jika transaction_type == 'explore'
                                                : item['transaction_type'][0].toUpperCase() +
                                                    item['transaction_type'].substring(1),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                          // Description with elipsis
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.3, // Lebar untuk batas teks
                                            child: Text(
                                              // Ternary operator untuk kondisi transaction_type
                                              item['transaction_type'] == 'explore'
                                                  ? item['sub_title'] ?? ''
                                                  : item['description'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFFA2A2A7),
                                              ),
                                              overflow: TextOverflow.ellipsis, // Truncate teks jika terlalu panjang
                                              maxLines: 1, // Batasi hanya satu baris
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _formatCurrencyDouble(item['amount']), // Format double ke currency
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      color: iconColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk membuat action button
  Widget _buildActionButton(String asset, String page) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Get.toNamed(page);
          },
          child: Container(
            width: 103,
            height: 75,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(asset), // Ganti dengan path gambar Anda
                fit: BoxFit.fill, // Menyesuaikan gambar agar memenuhi container
              ),
            ),
          ),
        ),
      ],
    );
  }
}
