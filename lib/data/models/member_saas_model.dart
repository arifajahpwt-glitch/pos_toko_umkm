class MemberSaas {
  final String waToko;
  final String namaToko;
  final String? alamatToko;
  final String? password;
  final String statusAktif;
  final String paketLangganan;
  final DateTime expiredAt;
  final DateTime? createdAt;

  MemberSaas({
    required this.waToko,
    required this.namaToko,
    this.alamatToko,
    this.password,
    this.statusAktif = 'Aktif',
    this.paketLangganan = 'Trial',
    required this.expiredAt,
    this.createdAt,
  });

  // Convert dari JSON (Supabase)
  factory MemberSaas.fromJson(Map<String, dynamic> json) {
    return MemberSaas(
      waToko: json['wa_toko'] ?? '',
      namaToko: json['nama_toko'] ?? '',
      alamatToko: json['alamat_toko'],
      password: json['password'],
      statusAktif: json['status_aktif'] ?? 'Aktif',
      paketLangganan: json['paket_langganan'] ?? 'Trial',
      expiredAt: json['expired_at'] != null
          ? DateTime.parse(json['expired_at'].toString())
          : DateTime.now().add(const Duration(days: 30)),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
    );
  }

  // Convert ke JSON (untuk Supabase)
  Map<String, dynamic> toJson() {
    return {
      'wa_toko': waToko,
      'nama_toko': namaToko,
      'alamat_toko': alamatToko,
      'password': password,
      'status_aktif': statusAktif,
      'paket_langganan': paketLangganan,
      'expired_at': expiredAt.toIso8601String().split('T').first,
    };
  }

  // Copy with
  MemberSaas copyWith({
    String? waToko,
    String? namaToko,
    String? alamatToko,
    String? password,
    String? statusAktif,
    String? paketLangganan,
    DateTime? expiredAt,
    DateTime? createdAt,
  }) {
    return MemberSaas(
      waToko: waToko ?? this.waToko,
      namaToko: namaToko ?? this.namaToko,
      alamatToko: alamatToko ?? this.alamatToko,
      password: password ?? this.password,
      statusAktif: statusAktif ?? this.statusAktif,
      paketLangganan: paketLangganan ?? this.paketLangganan,
      expiredAt: expiredAt ?? this.expiredAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Check apakah subscription masih aktif
  bool isSubscriptionActive() {
    return statusAktif == 'Aktif' && DateTime.now().isBefore(expiredAt);
  }

  // Hitung sisa hari trial
  int getRemainingDays() {
    final now = DateTime.now();
    if (now.isAfter(expiredAt)) return 0;
    return expiredAt.difference(now).inDays;
  }
}
