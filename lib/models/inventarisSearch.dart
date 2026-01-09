import 'package:simda_mobile/const.dart';

class InventarisSearch {
  final int id;
  final String jenisBarang;
  final String ruangan;
  final String? gambar;
  final String keadaan; // 👈 BARU

  InventarisSearch({
    required this.id,
    required this.jenisBarang,
    required this.ruangan,
    this.gambar,
    required this.keadaan,
  });

  factory InventarisSearch.fromJson(Map<String, dynamic> json) {
    return InventarisSearch(
      id: json['id'],
      jenisBarang: json['jenis_barang'],
      ruangan: json['ruangan'],
      gambar: json['gambar'],
      keadaan: json['keadaan'] ?? 'Tidak diketahui', // aman
    );
  }

  String? get imageUrl {
    if (gambar == null || gambar!.isEmpty) return null;
    return '$BASE_URL/gambar_barang/$gambar';
  }
}
