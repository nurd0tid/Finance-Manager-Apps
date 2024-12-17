import 'package:finance_manager_apps/utils/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late int selectedMonthIndex;
  late List<String> months;
  String? selectedTab = null;
  bool isLoading = true; // Add loading state
  Map<String, dynamic>? statisticsData;

  final SupabaseService supabaseService = SupabaseService();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    months = _generateLastSixMonths();
    selectedMonthIndex = months.indexOf(_getCurrentMonthName());
    _loadStatistics(selectedTab);
  }

  List<String> _generateLastSixMonths() {
    final now = DateTime.now();
    final formatter = DateFormat('MMM');
    return List.generate(
      6,
      (index) => formatter.format(DateTime(now.year, now.month - index, 1)),
    ).reversed.toList();
  }

  String _getCurrentMonthName() {
    final now = DateTime.now();
    final formatter = DateFormat('MMM');
    return formatter.format(now);
  }

  Future<void> _loadStatistics(String? typeTransaction) async {
    setState(() {
      isLoading = true; // Set loading state to true when fetching data
    });

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final data = await supabaseService.getUserStatistics(userId, typeTransaction: typeTransaction);
      setState(() {
        statisticsData = data;
        isLoading = false; // Set loading state to false once data is fetched
      });
    }
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ');
    return formatter.format(amount);
  }

  String _formatCurrencyString(String value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(double.tryParse(value) ?? 0.0);
  }



  List<FlSpot> _generateChartData() {
    List<FlSpot> spots = [];

    // Pastikan data chart sudah ada
    if (statisticsData != null && statisticsData!['chart_data'] != null) {
      var chartData = statisticsData!['chart_data'];

      // Loop untuk memeriksa setiap bulan dan memastikan datanya benar
      for (int i = 0; i < chartData.length; i++) {
        final monthData = chartData[i]; // Ambil data per bulan
        final amount = monthData['amount']; // Ambil amount untuk bulan tersebut

        // Cek apakah amount benar dan konversikan jika perlu
        final validAmount = (amount is num) ? amount.toDouble() : 0.0;

        spots.add(FlSpot(i.toDouble(), validAmount)); // Menambahkan ke FlSpot
      }
    }

    return spots; // Kembalikan data chart
  }

  String _formatCurrencyDouble(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ');
    return formatter.format(amount);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161622),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 16),
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
                      'Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Current Balance
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        child: Column(
                          children: [
                            Text(
                              'Current Balance',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                color: Color(0xFFA2A2A7),
                              ),
                            ),
                            Text(
                              _formatCurrency(statisticsData!['balance']),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 16),

                // Chart
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AspectRatio(
                      aspectRatio: 2,
                      child: LineChart(
                        LineChartData(
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            verticalInterval: 1,
                            drawHorizontalLine: false,
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: const Color(0xFF8B8B94),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(show: false),
                          
                          // Tambahkan ini
                          lineTouchData: LineTouchData(
                            enabled: true, // Aktifkan fitur sentuh
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Colors.black87, // Warna background tooltip
                              fitInsideHorizontally: true,
                              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((spot) {
                                  return LineTooltipItem(
                                     _formatCurrencyString(
                                          spot.y.toStringAsFixed(2)), // Tampilkan nilai y dengan 2 desimal
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),

                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              spots: _generateChartData(),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0066FF), Color(0xFF0066FF)],
                              ),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  if (index == selectedMonthIndex) {
                                    return FlDotCirclePainter(
                                      radius: 6,
                                      color: const Color(0xFF0066FF),
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  } else {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: Colors.grey,
                                      strokeWidth: 1,
                                      strokeColor: Colors.white,
                                    );
                                  }
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color.fromARGB(255, 70, 168, 248).withOpacity(0.4),
                                    const Color.fromARGB(0, 121, 189, 252),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                // Months
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: months.asMap().entries.map((entry) {
                    final index = entry.key;
                    final month = entry.value;
                    final isActive = index == selectedMonthIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMonthIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF0066FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          month,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            color: isActive ? Colors.white : const Color(0xFFA2A2A7),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Scrollable Transactions
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Income and Expenses Tabs
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTab('assets/income.svg'),
                              const SizedBox(width: 10),
                              _buildTab('assets/expanses.svg'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Transactions Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Transaction',
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
                                child: Text(
                                  'See All',
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
                          const SizedBox(height: 16),
                           // If loading is true, show loading indicator
                          if (isLoading) const Center(child: CircularProgressIndicator()),

                          // If transactions are empty or null, show empty image
                          if (!isLoading &&
                            (statisticsData == null ||
                                statisticsData!['transactions'] == null ||
                                statisticsData!['transactions'].isEmpty))
                          Image.asset(
                            'assets/empty.png',
                            width: 120,
                            height: 120,
                          ),

                          if (!isLoading &&
                              statisticsData != null &&
                              statisticsData!['transactions'] != null &&
                              statisticsData!['transactions'].isNotEmpty)
                            Column(
                              children: List.generate(
                                statisticsData!['transactions'].length,
                                (index) {
                                  final transaction = statisticsData!['transactions'][index];
                                  bool isIncome = transaction['transaction_type'] == 'topup';
                                  IconData icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;
                                  Color iconColor = isIncome ? Colors.green : Colors.red;

                                  return Container(
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
                                              child: transaction['transaction_type'] == 'topup'
                                                  ? Image.asset(
                                                      'assets/inc.png', // Gambar untuk topup
                                                      width: 42,
                                                      height: 42,
                                                      fit: BoxFit.fill,
                                                    )
                                                  : transaction['transaction_type'] == 'withdraw'
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
                                                            transaction['image'],
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
                                                  transaction['transaction_type'] == 'explore'
                                                      ? transaction['title'] ??
                                                          '' // Gunakan title jika transaction_type == 'explore'
                                                      : transaction['transaction_type'][0].toUpperCase() +
                                                          transaction['transaction_type'].substring(1),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                // Description with elipsis
                                                Container(
                                                  width:
                                                      MediaQuery.of(context).size.width * 0.3, // Lebar untuk batas teks
                                                  child: Text(
                                                    // Ternary operator untuk kondisi transaction_type
                                                    transaction['transaction_type'] == 'explore'
                                                        ? transaction['sub_title'] ?? ''
                                                        : transaction['description'] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      fontWeight: FontWeight.w400,
                                                      color: Color(0xFFA2A2A7),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis, // Truncate teks jika terlalu panjang
                                                    maxLines: 1, // Batasi hanya satu baris
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          _formatCurrencyDouble(transaction['amount']), // Format double ke currency
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String asset) {
    final isActive = selectedTab == asset; // Ganti title dengan asset
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = asset; // Ganti title dengan asset
          _loadStatistics(selectedTab == 'assets/income.svg' ? 'income' : 'expenses');
        });
      },
      child: Container(
        width: 161,
        height: 54,
        decoration: BoxDecoration(
          border: isActive ? Border.all(color: const Color(0xFF0066FF), width: 2) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          asset,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
