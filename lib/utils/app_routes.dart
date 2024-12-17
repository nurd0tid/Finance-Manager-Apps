import 'package:finance_manager_apps/screens/bottom_navigation_screen.dart';
import 'package:finance_manager_apps/screens/explore_screen.dart';
import 'package:finance_manager_apps/screens/paid_explore_screen.dart';
import 'package:finance_manager_apps/screens/payment_failed_screen.dart';
import 'package:finance_manager_apps/screens/payment_success_screen.dart';
import 'package:finance_manager_apps/screens/personal_information_screen.dart';
import 'package:finance_manager_apps/screens/statitics_screen.dart';
import 'package:finance_manager_apps/screens/top_up_screen.dart';
import 'package:finance_manager_apps/screens/transaction_history_screen.dart';
import 'package:finance_manager_apps/screens/withdraw_screen.dart';
import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String topUp = '/top-up';
  static const String withdraw = '/withdraw';
  static const String explore = '/explore';
  static const String paidExplore = '/paid-explore';
  static const String paymentSuccess = '/payment-success';
  static const String paymentFailed = '/payment-failed';
  static const String statistic = '/statistic';
  static const String personalInformation = '/personal-information';
  static const String transactionHistory = '/transaction-history';
  static const String myCard = '/my-card';

  // Daftar halaman aplikasi
  static final pages = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(name: dashboard, page: () => BottomNavigation()),
    GetPage(name: topUp, page: () => TopUpScreen()),
    GetPage(name: withdraw, page: () => WithDrawScreen()),
    GetPage(name: transactionHistory, page: () => TransactionHistoryScreen()),
    GetPage(name: explore, page: () => ExploreScreen()),
    GetPage(name: paidExplore, page: () => PaidExploreScreen()),
    GetPage(name: paymentSuccess, page: () => PaymentSuccessScreen()),
    GetPage(name: paymentFailed, page: () => PaymentFailedScreen()),
    GetPage(name: personalInformation, page: () => PersonalInformationScreen()),
    GetPage(name: statistic, page: () => BottomNavigation(initialIndex: 2)),
    GetPage(name: myCard, page: () => BottomNavigation(initialIndex: 1)),
  ];
}
