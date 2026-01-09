import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simda_mobile/models/inventaris.dart';
import 'package:simda_mobile/providers/auth_provider.dart';
import 'package:simda_mobile/screens/inventaris/inventaris_edit.screen.dart';
import 'package:simda_mobile/services/api_services.dart';
import 'package:simda_mobile/theme/app_text_style.dart';
import 'package:simda_mobile/utils/currency_formatter.dart';
import 'package:provider/provider.dart';

class InventarisDetailScreen extends StatefulWidget {
  final int id;
  const InventarisDetailScreen({super.key, required this.id});

  @override
  State<InventarisDetailScreen> createState() => _InventarisDetailScreenState();
}

class _InventarisDetailScreenState extends State<InventarisDetailScreen> {
  Inventaris? item;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      final res = await ApiService.getInventarisDetail(
        token: token,
        id: widget.id,
      );

      if (res.statusCode != 200) {
        throw Exception('Gagal memuat detail inventaris');
      }

      final json = jsonDecode(res.body);

      setState(() {
        item = Inventaris.fromJson(json['data']);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        item = null;
      });

      debugPrint('ERROR DETAIL INVENTARIS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
        actions: [
          if (!isLoading && item != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InventarisEditScreen(
                      item: item!, // kirim data ke halaman edit
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : item == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (item!.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(item!.imageUrl!),
                        ),
                      const SizedBox(height: 20),
                      _info('Ruangan', item!.ruangan),
                      _info('Kode Barang', item!.kodeBarang),
                      _info('Kode Register', item!.kodeRegister),
                      _info('Jenis Barang', item!.jenisBarang),
                      _info('Merek & Tipe', item!.merekTipe),
                      _info('No. Seri', item!.noSeri),
                      _info('Bahan', item!.bahan),
                      _info('Cara Perolehan', item!.caraPerolehan),
                      _info('Tahun Pembelian', item!.tahunBeli),
                      _info('Ukuran', item!.ukuran),
                      _info('Satuan', item!.satuan),
                      _info('Keadaan', item!.keadaan),
                      _info('Jumlah', item!.jumlah),
                      _info(
                        'Harga',
                        CurrencyFormatter.rupiah(item!.harga),
                      ),
                      _info('Keterangan', item!.keterangan),
                    ],
                  ),
                ),
    );
  }

  Widget _info(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.label),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyle.title),
        ],
      ),
    );
  }
}
