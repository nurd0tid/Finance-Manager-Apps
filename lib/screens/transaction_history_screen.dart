import 'package:finance_manager_apps/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final SupabaseService supabaseService = SupabaseService();
  bool isLoading = true;
  List<Map<String, dynamic>>? data;

  @override
  void initState() {
    super.initState();
    _loadTransactionHistory();
  }

  Future<void> _loadTransactionHistory() async {
    setState(() => isLoading = true);
    final dataTransactionHistory = await supabaseService.getUserTransactions();

    if (dataTransactionHistory != null) {
      setState(() {
        data = dataTransactionHistory;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  String _formatCurrencyDouble(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ');
    return formatter.format(amount);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF161622),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 16),
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
                  'Transaction',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : data == null || data!.isEmpty
                        ? Center(
                            child: Image.asset(
                              'assets/empty.png',
                              width: 100,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          )
                        : ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: data!.length,
                            itemBuilder: (context, index) {
                              final item = data![index];
                              bool isIncome = item['transaction_type'] == 'topup';
                              Color iconColor = isIncome ? Colors.green : Colors.red;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                                  width:
                                                      MediaQuery.of(context).size.width * 0.3, // Lebar untuk batas teks
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
                                                    overflow:
                                                        TextOverflow.ellipsis, // Truncate teks jika terlalu panjang
                                                    maxLines: 1, // Batasi hanya satu baris
                                                  ),
                                                ),
                                              ],
                                            )
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
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                          ))
          ],
        ),
      ),
    );
  }
}
