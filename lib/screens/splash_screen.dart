import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentIndex = 0;

  final List<Map<String, String>> splashData = [
    {
      "image": "assets/splash1.png",
      "title": "Manage Your Finances Wisely",
      "subtitle": "Track your expenses and income effortlessly, helping you achieve your financial goals.",
    },
    {
      "image": "assets/splash2.png",
      "title": "Secure and Reliable Budgeting",
      "subtitle": "Your data is encrypted and protected, ensuring a safe financial planning experience.",
    },
    {
      "image": "assets/splash3.png",
      "title": "Take Control of Your Spending",
      "subtitle": "Gain insights into your spending habits and make smarter financial decisions.",
    },
  ];

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      Get.offAllNamed('/dashboard');
    } else {
      final prefs = await SharedPreferences.getInstance();
      final bool hasSeenSplash = prefs.getBool('hasSeenSplash') ?? false;

      if (hasSeenSplash) {
        Get.offAllNamed('/login');
      } else {
        await prefs.setBool('hasSeenSplash', true);
      }
    }
  }

  void nextPage() {
    if (currentIndex < splashData.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Get.offAllNamed('/login'); // Pindah ke halaman login
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = splashData[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF161622),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset(
              data["image"]!,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              data["title"]!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              data["subtitle"]!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Color(0xFF7E848D),
                fontFamily: 'Poppins',
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                splashData.length,
                (index) => buildDot(index: index),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                fixedSize: const Size(335, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget buildDot({required int index}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: currentIndex == index ? 24 : 8,
      decoration: BoxDecoration(
        color: currentIndex == index ? const Color(0xFF0066FF) : Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
