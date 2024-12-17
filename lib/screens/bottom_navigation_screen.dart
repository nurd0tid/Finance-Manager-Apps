import 'package:finance_manager_apps/screens/my_card_screen.dart';
import 'package:finance_manager_apps/screens/settings_screen.dart';
import 'package:finance_manager_apps/screens/statitics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dashboard_screen.dart'; // Dashboard Screen yang sudah dibuat

class BottomNavigation extends StatefulWidget {
  final int initialIndex; // Tambahkan parameter untuk index awal
  BottomNavigation({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late int _currentIndex; // Index tab aktif

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Set tab awal berdasarkan initialIndex
  }

  // Daftar halaman
  final List<Widget> _pages = [
    DashboardScreen(), // Home
    MyCardsScreen(), // My Cards
    StatisticsScreen(), // Statistics
    SettingsScreen(), // Settings
  ];

  // Gaya bottom navigation bar
  final List<Map<String, dynamic>> _bottomNavItems = [
    {'icon': 'assets/icons/home.svg', 'label': 'Home'},
    {'icon': 'assets/icons/myCards.svg', 'label': 'My Cards'},
    {'icon': 'assets/icons/statistics.svg', 'label': 'Statistics'},
    {'icon': 'assets/icons/settings.svg', 'label': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Tampilkan halaman sesuai tab aktif
      bottomNavigationBar: Container(
        height: 86,
        decoration: const BoxDecoration(
          color: Color(0xFF27273A), // Warna background bottom navigation
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _bottomNavItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = index; // Ubah tab aktif
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    item['icon'],
                    color: _currentIndex == index
                        ? const Color(0xFF0066FF) // Warna aktif
                        : const Color(0xFF8B8B94), // Warna tidak aktif
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['label'],
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: _currentIndex == index ? FontWeight.w500 : FontWeight.w400,
                      color: _currentIndex == index ? const Color(0xFF0066FF) : const Color(0xFF8B8B94),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


// Placeholder Screen tanpa AppBar
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title Page',
        style: const TextStyle(
          fontSize: 18,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E1E2D),
        ),
      ),
    );
  }
}
