import 'package:finance_manager_apps/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentSuccessScreen extends StatelessWidget {
  // Fungsi untuk memformat currency ke format Rp (contoh: Rp.20,000)
  String _formatCurrency(int value) {
    return 'Rp.${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (match) => '${match[1]},')}';
  }

  // Fungsi untuk mendapatkan teks sesuai tipe transaksi
  String _getTransactionVerb(String type) {
    switch (type) {
      case 'withdraw':
        return 'withdrawn';
      case 'explore':
        return 'paid';
      default:
        return 'topped';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil arguments dari Get.toNamed
    final arguments = Get.arguments as Map<String, dynamic>;
    final int amount = arguments['amount'] ?? 0;
    final String userName = arguments['userName'] ?? 'User';
    final String type = arguments['type'] ?? 'topup';

    return Scaffold(
      backgroundColor: Color(0xFF161622), // Warna background gelap
      appBar: AppBar(
        backgroundColor: Color(0xFF161622),
        automaticallyImplyLeading: false, // Hilangkan tombol back
        centerTitle: true,
        title: Text(
          'Payment Success',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Spacer(), // Dorong ke tengah layar secara vertikal
            Center(
              child: Column(
                children: [
                  // Gambar Payment Success
                  Image.asset(
                    'assets/payment_success.png',
                    width: 126,
                    height: 126,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 32),

                  // Teks Payment Amount dan Nama User
                  Text(
                    '${_formatCurrency(amount)} has been\n${_getTransactionVerb(type)} to $userName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(), // Dorong tombol ke bagian bawah layar

            // Tombol Close
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Kembali ke halaman sebelumnya
                    Get.toNamed(AppRoutes.statistic);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0066FF), // Warna tombol biru
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
