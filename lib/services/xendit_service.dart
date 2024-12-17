import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class XenditService {
  final String _baseUrl = 'https://api.xendit.co';

  Future<Map<String, dynamic>> createVirtualAccount(String userId, String userName) async {
    final url = Uri.parse('$_baseUrl/callback_virtual_accounts');

    // Hitung tanggal expired (1 tahun dari sekarang)
    final expirationDate = DateTime.now().add(const Duration(days: 365)).toIso8601String();

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('${Constants.xenditApiKey}:'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'external_id': 'user-$userId',
          'bank_code': 'BCA',
          'name': userName,
          'is_closed': false,
          'expiration_date': expirationDate,
        }),
      );

      // Validasi status code dari respons HTTP
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Validasi apakah respons memiliki data yang diperlukan
        if (responseBody.containsKey('account_number') && responseBody.containsKey('bank_code')) {
          return responseBody;
        } else {
          throw Exception('Respons tidak memiliki data VA yang lengkap.');
        }
      } else {
        // Tangani kesalahan jika status code bukan 200
        final errorBody = jsonDecode(response.body);
        throw Exception('Error dari Xendit: ${errorBody['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Gagal membuat Virtual Account: ${e.toString()}');
    }
  }

  Future<bool> simulatePayment(String externalId, int amount) async {
    final url = 'https://api.xendit.co/callback_virtual_accounts/external_id=$externalId/simulate_payment';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('${Constants.xenditApiKey}:'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
        }),
      );
      if (response.statusCode != 200) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
