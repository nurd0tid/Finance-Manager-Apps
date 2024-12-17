import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Mendapatkan nama pengguna berdasarkan ID
  Future<String?> getUserName(String userId) async {
    final response = await _client.from('users').select('name').eq('id', userId).maybeSingle();

    if (response != null && response['name'] != null) {
      return response['name'];
    }
    return null;
  }

  Future<Map<String, dynamic>?> getProfileInformation(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('created_at, name, email') // Ambil kolom created_at, name, dan email
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return {
          'created_at': response['created_at'],
          'name': response['name'],
          'email': response['email'],
        };
      }
      return null; // Jika tidak ada data ditemukan
    } catch (e) {
      print('Error fetching profile information: $e');
      return null;
    }
  }
  // Mendapatkan saldo pengguna berdasarkan ID
  Future<int> getUserBalance(String userId) async {
    try {
      final response = await _client.from('users').select('balance').eq('id', userId).maybeSingle();

      if (response != null && response['balance'] != null) {
        return response['balance'];
      }
      return 0;
    } catch (e) {
      print('Error fetching balance: $e');
      return 0;
    }
  }

  // Mendapatkan data Virtual Account pengguna berdasarkan ID
  Future<Map<String, dynamic>?> getUserVA(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('virtual_account, bank_code, va_expired_at')
          .eq('id', userId)
          .maybeSingle();

      print('Supabase VA Response: $response');

      // Jika respons kosong atau kunci tidak ada, kembalikan null
      if (response == null ||
          response['virtual_account'] == null ||
          response['bank_code'] == null ||
          response['va_expired_at'] == null) {
        return null;
      }

      // Return data jika valid
      return {
        'virtual_account': response['virtual_account'],
        'bank_code': response['bank_code'],
        'va_expired_at': response['va_expired_at'],
      };
    } catch (e) {
      return null; // Kembalikan null jika terjadi error
    }
  }

  Future<List<Map<String, dynamic>>?> getExploreData() async {
    try {
      final response = await _client.from('explore').select('*');

      print('Supabase VA Response: $response');

      // Jika respons kosong atau kunci tidak ada, kembalikan null
      if (response == null || response.isEmpty) {
        return null;
      }

      // Return data jika valid
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return null; // Kembalikan null jika terjadi error
    }
  }

  Future<void> updateUserVA(
      String userId, String virtualAccount, String bankCode, DateTime expiredAt, String externalId) async {
    try {
      print('Updating VA for User ID: $userId');
      print('VA Details: { virtualAccount: $virtualAccount, bankCode: $bankCode, expiredAt: $expiredAt }');

      final response = await _client
          .from('users')
          .update({
            'virtual_account': virtualAccount,
            'bank_code': bankCode,
            'va_expired_at': expiredAt.toIso8601String(),
            'external_id': externalId,
          })
          .eq('id', userId)
          .select(); // Meminta data yang diperbarui untuk dikembalikan

      print('Supabase Update Response: $response');

      // Tangani jika respons kosong
      if (response == null || (response as List).isEmpty) {
        throw Exception('Supabase response is null or empty. Update failed.');
      }
    } catch (e) {
      print('Exception caught in updateUserVA(): $e');
      throw Exception('Error updating VA in Supabase: ${e.toString()}');
    }
  }

  Future<String?> getExternalId(String userId) async {
    final response = await _client.from('users').select('external_id').eq('id', userId).maybeSingle();

    return response != null ? response['external_id'] : null;
  }

  Future<List<Map<String, dynamic>>?> getUserTransactionsLimit(String userId) async {
    final response = await Supabase.instance.client.rpc(
      'get_user_transactions_limit',
      params: {'p_user_id': userId, 'p_limit': 5},
    );

    if (response != null) {
      return List<Map<String, dynamic>>.from(response);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>?> getUserTransactions() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final response = await Supabase.instance.client.rpc(
        'get_user_transactions_all',
        params: {'p_user_id': userId},
      );

      // Jika respons kosong atau kunci tidak ada, kembalikan null
      if (response == null || response.isEmpty) {
        return null;
      }

      // Return data jika valid
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return null; // Kembalikan null jika terjadi error
    }
  }

  Future<bool> withdraw(String userId, int amount, String description) async {
    try {
      final response = await _client.rpc('process_withdrawal', params: {
        'user_id_param': userId,
        'amount': amount,
        'description': description,
      });

      // Tangani jika RPC gagal
      if (response is String) {
        if (response.toLowerCase().contains('success')) {
          return true; // Jika ada kata "success", anggap pembayaran berhasil
        } else {
          print('Error A: $response'); // Tangani jika tidak mengandung success
          return false;
        }
      }

      // Jika RPC mengembalikan objek lain yang memiliki error
      if (response?.error != null) {
        print('Error A: ${response?.error}');
        return false;
      }
      return true; 
    } catch (e) {
      return false;
    }
  }

Future<bool> paidExplore(String userId, String exploreId, int amount, String description) async {
    try {
      final response = await _client.rpc('process_payment', params: {
        'user_id_param': userId,
        'amount': amount,
        'description': description,
        'explore_id_param': exploreId,
      });

      print('gua ke response $response');

      // Cek jika respons berupa string yang menunjukkan sukses
      if (response is String) {
        if (response.toLowerCase().contains('success')) {
          return true; // Jika ada kata "success", anggap pembayaran berhasil
        } else {
          print('Error A: $response'); // Tangani jika tidak mengandung success
          return false;
        }
      }

      // Jika RPC mengembalikan objek lain yang memiliki error
      if (response?.error != null) {
        print('Error A: ${response?.error}');
        return false;
      }

      return true; // Default sukses
    } catch (e) {
      print('Error B: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserStatistics(String userId, {String? typeTransaction}) async {
    try {
      // Panggil RPC get_user_statistics
      final response = await _client.rpc('get_user_statistics', params: {
        'p_user_id': userId,
        'p_type_transaction': typeTransaction, // Null jika tidak ada filter
      });

      print('id gue $userId} ${typeTransaction}');

      // Validasi respons
      if (response == null) {
        print('RPC response is null.');
        return null;
      }

      print('User Statistics RPC Response: $response');

      // Kembalikan hasil sebagai Map
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      print('Error fetching user statistics: $e');
      return null; // Jika terjadi error, kembalikan null
    }
  }
}
