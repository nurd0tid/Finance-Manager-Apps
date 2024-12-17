import 'package:finance_manager_apps/services/supabase_service.dart';
import 'package:finance_manager_apps/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final SupabaseService supabaseService = SupabaseService();
  bool isLoading = true;
  List<Map<String, dynamic>>? data;

  @override
  void initState() {
    super.initState();
    _loadExploreData();
  }

  Future<void> _loadExploreData() async {
    setState(() => isLoading = true);
    final dataExplore = await supabaseService.getExploreData();

    if (dataExplore != null) {
      print(dataExplore);
      setState(() {
        data = dataExplore;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  String _formatCurrency(num value) {
    final formatter = NumberFormat("#,##0", "id_ID");
    return 'Rp. ${formatter.format(value)}';
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
                  'Explore',
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
                              'assets/empty-explore.png',
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
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                       Get.toNamed(
                                        AppRoutes.paidExplore,
                                        arguments: {
                                          'amount': item['price'],
                                          'image': item['image'],
                                          'title': item['title'],
                                          'sub_title': item['sub_title'],
                                          'id': item['id'],
                                        },
                                      );
                                    },
                                    child: Container(
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
                                                  item['image'],
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
                                                    item['title'],
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Poppins',
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    item['sub_title'],
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
                                            _formatCurrency(item['price']),
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
