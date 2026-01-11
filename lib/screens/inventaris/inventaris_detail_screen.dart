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
  int _currentIndex = 0;

  void _openImageViewer(int startIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) {
        int index = startIndex;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Stack(
              children: [
                PageView.builder(
                  controller: PageController(initialPage: startIndex),
                  itemCount: item!.images.length,
                  onPageChanged: (i) {
                    setModalState(() => index = i);
                  },
                  itemBuilder: (context, i) {
                    return InteractiveViewer(
                      child: Image.network(
                        item!.images[i].url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('IMAGE VIEWER ERROR: $error');
                          return const Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.white, size: 50),
                          );
                        },
                      ),
                    );
                  },
                ),

                // ❌ CLOSE BUTTON
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // COUNTER (opsional)
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Text(
                    '${index + 1} / ${item!.images.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
                      Builder(builder: (_) {
                        debugPrint('IMAGE COUNT: ${item!.images.length}');
                        for (final img in item!.images) {
                          debugPrint('IMAGE URL: ${img.url}');
                        }
                        return const SizedBox.shrink();
                      }),
                      if (item!.images.isNotEmpty)
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: SizedBox(
                                height: 220,
                                child: PageView.builder(
                                  itemCount: item!.images.length,
                                  onPageChanged: (index) {
                                    setState(() => _currentIndex = index);
                                  },
                                  itemBuilder: (context, index) {
                                    final img = item!.images[index];

                                    // 🔍 DEBUG URL GAMBAR
                                    debugPrint('LOAD IMAGE: ${img.url}');

                                    return GestureDetector(
                                      onTap: () {
                                        _openImageViewer(index);
                                      },
                                      child: Image.network(
                                        img.url,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) return child;
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          debugPrint('IMAGE ERROR: $error');
                                          return Container(
                                            color: Colors.grey.shade200,
                                            alignment: Alignment.center,
                                            child: const Icon(
                                                Icons.broken_image,
                                                size: 40),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // =====================
                            // DOT INDICATOR
                            // =====================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                item!.images.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentIndex == index
                                        ? Colors.blue
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
