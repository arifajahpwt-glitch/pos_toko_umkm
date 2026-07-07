import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/member_saas_model.dart';
import '../models/user_kasir_model.dart';
import '../../utils/constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  late SupabaseClient _client;

  SupabaseClient get client => _client;

  // Initialize Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  // ============ MEMBER SAAS AUTH ============

  // Login Owner
  Future<MemberSaas?> loginOwner(String waToko, String password) async {
    try {
      final response = await _client
          .from('member_saas')
          .select()
          .eq('wa_toko', waToko)
          .maybeSingle();

      if (response == null) {
        throw Exception('Pengguna tidak ditemukan');
      }

      // Cek password
      if (response['password'] != password) {
        throw Exception('Password salah');
      }

      // Cek status aktif
      if (response['status_aktif'] != 'Aktif') {
        throw Exception('Akun Anda tidak aktif');
      }

      return MemberSaas.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Register Owner (Daftar Toko)
  Future<MemberSaas> registerOwner({
    required String waToko,
    required String namaToko,
    required String alamatToko,
    required String password,
  }) async {
    try {
      // Cek apakah nomor WA sudah terdaftar
      final existing = await _client
          .from('member_saas')
          .select()
          .eq('wa_toko', waToko)
          .maybeSingle();

      if (existing != null) {
        throw Exception('Nomor WhatsApp sudah terdaftar');
      }

      // Set expired_at = 30 hari dari sekarang
      final expiredAt = DateTime.now().add(const Duration(days: 30));

      final response = await _client.from('member_saas').insert({
        'wa_toko': waToko,
        'nama_toko': namaToko,
        'alamat_toko': alamatToko,
        'password': password,
        'status_aktif': 'Aktif',
        'paket_langganan': 'Trial',
        'expired_at': expiredAt.toIso8601String().split('T').first,
      }).select().single();

      return MemberSaas.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get Member by WA
  Future<MemberSaas?> getMemberByWa(String waToko) async {
    try {
      final response = await _client
          .from('member_saas')
          .select()
          .eq('wa_toko', waToko)
          .maybeSingle();

      return response != null ? MemberSaas.fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }

  // Update Member
  Future<void> updateMember(String waToko, Map<String, dynamic> data) async {
    try {
      await _client.from('member_saas').update(data).eq('wa_toko', waToko);
    } catch (e) {
      rethrow;
    }
  }

  // ============ USER KASIR ============

  // Login Kasir
  Future<UserKasir?> loginKasir(String username, String password) async {
    try {
      final response = await _client
          .from('user_kasir')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) {
        throw Exception('Pengguna tidak ditemukan');
      }

      // Cek password
      if (response['password'] != password) {
        throw Exception('Password salah');
      }

      return UserKasir.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get Kasir by Owner
  Future<List<UserKasir>> getKasirByOwner(String waOwner) async {
    try {
      final response = await _client
          .from('user_kasir')
          .select()
          .eq('wa_owner', waOwner);

      return (response as List)
          .map((e) => UserKasir.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Create Kasir
  Future<UserKasir> createKasir({
    required String waOwner,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _client.from('user_kasir').insert({
        'wa_owner': waOwner,
        'username': username,
        'password': password,
        'role': 'Kasir',
      }).select().single();

      return UserKasir.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // ============ HELPER FUNCTIONS ============

  // Reset Password (Update password via WA verification)
  Future<void> resetPassword(String waToko, String newPassword) async {
    try {
      await updateMember(waToko, {'password': newPassword});
    } catch (e) {
      rethrow;
    }
  }

  // Check subscription status
  Future<bool> isSubscriptionActive(String waToko) async {
    try {
      final member = await getMemberByWa(waToko);
      if (member == null) return false;
      return member.isSubscriptionActive();
    } catch (e) {
      return false;
    }
  }
}
