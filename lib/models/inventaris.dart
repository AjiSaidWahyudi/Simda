import 'package:simda_mobile/models/inventarisImages.dart';

class Inventaris {
  final int id;
  final int kartuRuangId;
  final String ruangan;
  final String kodeBarang;
  final String kodeRegister;
  final String jenisBarang;
  final String namaPemegang;
  final String merekTipe;
  final String noSeri;
  final String bahan;
  final String caraPerolehan;
  final String tahunBeli;
  final String ukuran;
  final String satuan;
  final String keadaan;
  final String jumlah;
  final int harga;
  final String keterangan;
  final List<InventarisImage> images;

  Inventaris({
    required this.id,
    required this.kartuRuangId,
    required this.ruangan,
    required this.kodeBarang,
    required this.kodeRegister,
    required this.jenisBarang,
    required this.namaPemegang,
    required this.merekTipe,
    required this.noSeri,
    required this.bahan,
    required this.caraPerolehan,
    required this.tahunBeli,
    required this.ukuran,
    required this.satuan,
    required this.keadaan,
    required this.jumlah,
    required this.harga,
    required this.keterangan,
    required this.images,
  });

  factory Inventaris.fromJson(Map<String, dynamic> json) {
    return Inventaris(
      id: json['id'],
      kartuRuangId: json['kartu_ruang_id'] ?? '-',
      ruangan: json['ruangan'] ?? '-',
      kodeBarang: json['kode_barang'] ?? '-',
      kodeRegister: json['kode_register'] ?? '-',
      jenisBarang: json['jenis_barang'] ?? '-',
      namaPemegang: json['nama_pemegang'] ?? '-',
      merekTipe: json['merek_tipe'] ?? '-',
      noSeri: json['no_seri'] ?? '-',
      bahan: json['bahan'] ?? '-',
      caraPerolehan: json['cara_perolehan'] ?? '-',
      tahunBeli: json['tahun_beli'] ?? '-',
      ukuran: json['ukuran'] ?? '-',
      satuan: json['satuan'] ?? '-',
      keadaan: json['keadaan'] ?? '-',
      jumlah: json['jumlah'] ?? '-',
      harga: json['harga'] ?? '-',
      keterangan: json['keterangan'] ?? '-',
      images: (json['gambar'] as List? ?? [])
          .map((e) => InventarisImage.fromJson(e))
          .toList(),
    );
  }
}
