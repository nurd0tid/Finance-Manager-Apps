import 'package:finance_manager_apps/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentFailedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF161622), // Warna background gelap
      appBar: AppBar(
        backgroundColor: Color(0xFF161622), // Warna background
        automaticallyImplyLeading: false, // Menghilangkan tombol back
        centerTitle: true, // Membuat teks di tengah
        title: Text(
          'Transaction Failed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(), // Mendorong konten ke tengah vertikal
            // Gambar Payment Failed
            Image.asset(
              'assets/payment_failed.png',
              width: 126,
              height: 126,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 32),

            // Teks Keterangan
            const Text(
              'Please Try Again',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            Spacer(), // Mendorong tombol ke bagian bawah layar

            // Tombol Back to Payment
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi ke halaman Top-Up
                  Get.offAllNamed(AppRoutes.dashboard);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0066FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Jarak kecil dari bawah
          ],
        ),
      ),
    ),
    );
  }
}
