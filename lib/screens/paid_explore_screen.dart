import 'package:finance_manager_apps/services/xendit_service.dart';
import 'package:finance_manager_apps/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

class PaidExploreScreen extends StatefulWidget {
  @override
  _PaidExploreScreenState createState() => _PaidExploreScreenState();
}

class _PaidExploreScreenState extends State<PaidExploreScreen> {
  final SupabaseService supabaseService = SupabaseService();
  final XenditService xenditService = XenditService();
  bool isLoading = true;
  bool isFinished = false;
  Map<String, dynamic>? userVA;
  String? userName;
  bool isArgumentsLoading = true; 
  int? balanceData;

  // Untuk Selection dan Input
  final TextEditingController _readOnlyAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadArguments();
  }

  Future<void> _loadArguments() async {
    setState(() {
      isArgumentsLoading = true;
    });

    await Future.delayed(Duration(milliseconds: 300)); // Simulasi loading
    final arguments = Get.arguments as Map<String, dynamic>;
    _readOnlyAmountController.text = arguments['amount'].toString();

    setState(() {
      isArgumentsLoading = false;
    });

    _loadUserData();
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

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId != null) {
      final vaData = await supabaseService.getUserVA(userId);
      final fetchedName = await supabaseService.getUserName(userId);
      final balance = await supabaseService.getUserBalance(userId);

      setState(() {
        userVA = vaData;
        userName = fetchedName ?? 'User';
        balanceData = balance;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  String _formatExpiryDate(String? timestamp) {
    if (timestamp == null) return '00/0000';
    final date = DateTime.parse(timestamp);
    return DateFormat('MM/yyyy').format(date);
  }

  Future<void> handlePaid() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    final arguments = Get.arguments as Map<String, dynamic>;
    final String exploreId = arguments['id'];
    final int amount = int.parse(_readOnlyAmountController.text);

    if (amount == null || amount <= 0) {
      showCustomSnackbar(
        message: 'Please enter a valid paid amount.',
        isSuccess: false,
      );
      return;
    }

    // Validasi saldo tidak mencukupi
    if (balanceData != null && amount > balanceData!) {
      showCustomSnackbar(
        message: 'Not enough balance.',
        isSuccess: false,
      );
      return;
    }

    if (userId == null) {
      showCustomSnackbar(
        message: 'User not logged in.',
        isSuccess: false,
      );
      return;
    }

    try {
      // Panggil paid di Supabase Service
      final success = await supabaseService.paidExplore(userId, exploreId, amount, 'Paid Explore');

      if (success) {
        // Navigasi ke halaman sukses
        Get.toNamed(
          AppRoutes.paymentSuccess,
          arguments: {'amount': amount, 'userName': userName ?? 'User', 'type': 'paid'},
        );
      } else {
        Get.toNamed(AppRoutes.paymentFailed);
      }
    } catch (e) {
      showCustomSnackbar(
        message: 'An error occurred: $e',
        isSuccess: false,
      );
    }
  }

  String _formatVirtualAccount(String? va) {
    if (va == null) return '';
    return va.replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ');
  }

  String _formatCurrency(String value) {
    final formatter = NumberFormat("#,##0", "id_ID");
    return 'RP. ${formatter.format(int.parse(value.isEmpty ? '0' : value))}';
  }

  String _formatSaldo(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'RP. ');
    return formatter.format(amount);
  }

  String _formatCurrencyNum(num value) {
    final formatter = NumberFormat("#,##0", "id_ID");
    return 'Rp. ${formatter.format(value)}';
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    final num amount = arguments['amount'] ?? 0; // Default amount jadi 0
    final String image = arguments['image'] ?? 'https://via.placeholder.com/150'; // Placeholder image 150x150
    final String title = arguments['title'] ?? 'Judul Placeholder'; // Judul placeholder
    final String sub_title = arguments['sub_title'] ?? 'Sub Judul Placeholder'; // Sub judul placeholder
    final String id = arguments['id'] ?? '000000'; // ID placeholder


    return Scaffold(
      backgroundColor: Color(0xFF161622), // Background gelap
      body: isArgumentsLoading ?
      const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ) :
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 16),
            // Back Arrow dan Title
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
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
                  'Payment',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // Content
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : userVA == null
                      ? Center(
                          child: Image.asset(
                            'assets/empty-setup.png',
                            width: 280,
                            height: 278,
                            fit: BoxFit.contain,
                          ),
                        )
                      : SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 32),
                              // Contoh konten jika VA sudah ada
                              Stack(
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
                              SizedBox(height: 32),
                              const Text(
                                "Your Saldo",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF9CB1D1),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                _formatSaldo(balanceData!),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 32),
                              const Text(
                                "Your Feature",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF9CB1D1),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 42,
                                width: MediaQuery.of(context).size.width - 32,
                                margin: EdgeInsets.only(bottom: 40),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 42,
                                          width: 42,
                                          child: Image.network(
                                            image,
                                            width: 42,
                                            height: 42,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              sub_title,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFFA2A2A7),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    Text(
                                      _formatCurrencyNum(amount),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Center(
                                child: TextField(
                                  controller: _readOnlyAmountController,
                                  keyboardType: TextInputType.number,
                                  readOnly: true,
                                  cursorColor: Colors.transparent, // Menghilangkan kursor
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600], // Warna teks disabled
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 32,
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF232533),
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF232533),
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF232533), // Tetap gunakan warna border
                                        width: 2,
                                      ),
                                    ),
                                    disabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF232533), // Border tetap ada meskipun disabled
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
            SwipeableButtonView(
              buttonText: isFinished ? "Success Payment" : "Slide To Payment",
              buttonWidget: Container(
                child: Icon(
                  isFinished ? Icons.check : Icons.arrow_forward_ios,
                  color: Color(0xFF0066FF),
                ),
              ),
              activeColor: Color(0xFF25253B), // Warna aktif swipe
              isFinished: isFinished,
              onWaitingProcess: () async {
                await handlePaid();
                setState(() {
                  isFinished = true;
                });
              },
              onFinish: () {
                setState(() {
                  isFinished = false;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
