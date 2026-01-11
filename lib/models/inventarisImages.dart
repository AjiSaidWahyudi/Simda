import 'package:simda_mobile/const.dart';

class InventarisImage {
  final int id;
  final String gambar;
  final int invId;

  InventarisImage({
    required this.id,
    required this.gambar,
    required this.invId,
  });

  factory InventarisImage.fromJson(Map<String, dynamic> json) {
    return InventarisImage(
      id: json['id'],
      gambar: json['gambar'],
      invId: json['inv_id'],
    );
  }

  String get url => '$BASE_URL/gambar_barang/$invId/$gambar';
}
