import 'package:finance_manager_apps/services/xendit_service.dart';
import 'package:finance_manager_apps/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

class TopUpScreen extends StatefulWidget {
  @override
  _TopUpScreenState createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final SupabaseService supabaseService = SupabaseService();
   final XenditService xenditService = XenditService();
  bool isLoading = true;
  bool isFinished = false; 
  Map<String, dynamic>? userVA;
  String? userName;

    // Untuk Selection dan Input
  final TextEditingController _amountController = TextEditingController();
  String selectedAmount = '';
  final List<String> amounts = ['10k', '100k', '150k', '200k', '250k', '300k', '450k', '500k'];

  @override
  void initState() {
    super.initState();
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

      setState(() {
        userVA = vaData;
        userName = fetchedName ?? 'User';
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

  Future<void> handleTopUp() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    // Validasi input nominal
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      showCustomSnackbar(
        message: 'Please enter a valid top-up amount.',
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
      final externalId = await supabaseService.getExternalId(userId);
      if (externalId == null) {
        showCustomSnackbar(
          message: 'Failed to fetch External ID.',
          isSuccess: false,
        );
        return;
      }

      // Gunakan XenditService untuk simulate payment
      final success = await xenditService.simulatePayment(externalId, amount);

      if (success) {
        // Navigasi ke halaman sukses
       Get.toNamed(
          AppRoutes.paymentSuccess,
          arguments: {
            'amount': amount,
            'userName': userName!,
            'type': 'topup'
          },
        );
      } else {
        // Navigasi ke halaman gagal
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

   void _selectAmount(String amount) {
    setState(() {
      selectedAmount = amount;
      _amountController.text = amount.replaceAll('k', '000');
    });
  }

  String _formatCurrency(String value) {
    final formatter = NumberFormat("#,##0", "id_ID");
    return 'RP. ${formatter.format(int.parse(value.isEmpty ? '0' : value))}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF161622), // Background gelap
      body: Padding(
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
                  'Top Up',
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
                                Center(
                                  child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: amounts.map((amount) {
                                    return GestureDetector(
                                      onTap: () => _selectAmount(amount),
                                      child: Container(
                                        width: 80,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: selectedAmount == amount ? Colors.blue : Colors.transparent,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: AssetImage('assets/$amount.png'),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  ),
                                ),
                                SizedBox(height: 32),
                                Center(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  onChanged: (value) => setState(() {}),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 32,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF232533),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 32),
                              Text(
                                'm-Banking Transfer Instructions',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '1. Choose m-Transfer > BCA Virtual Account.\n'
                                '2. Enter the Virtual Account number ${userVA?['virtual_account']} and select Send.\n'
                                '3. Check the information on the screen.\n'
                                '4. Enter your m-BCA PIN and select OK.\n'
                                '5. If the notification “Transaction Failed” appears, try using KlikBCA or ATM.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFA2A2A7),
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
                await handleTopUp();
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
