import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:simda_mobile/services/api_services.dart';
import 'package:simda_mobile/widgets/dropdown_field.dart';
import 'package:simda_mobile/widgets/image_picker_field.dart';
import 'package:simda_mobile/widgets/primary_button.dart';
import '../../models/inventaris.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class InventarisEditScreen extends StatefulWidget {
  final Inventaris item;
  const InventarisEditScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<InventarisEditScreen> createState() => _InventarisEditScreenState();
}

class _InventarisEditScreenState extends State<InventarisEditScreen> {
  int? _selectedKartuRuang;
  List<File> _newImages = [];
  bool _loading = false;
  List<dynamic> _kartuRuangList = [];

  @override
  void initState() {
    super.initState();
    _selectedKartuRuang = widget.item.kartuRuangId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchKartuRuang();
    });
  }

  Future<void> _fetchKartuRuang() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      final json = await ApiService.getKartuRuang(token);
      print("Kartu Ruang API Response: $json"); // <-- debug

      if (json['status'] == true || json is List) {
        setState(() {
          _kartuRuangList = json['data'] ?? json;
        });
      }
    } catch (e) {
      print("Error fetch kartu ruang: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 85);

    if (pickedFiles.isEmpty) return;

    // jumlah gambar lama dari API
    final existingCount = widget.item.images.length;

    if (existingCount + _newImages.length + pickedFiles.length > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 4 gambar per inventaris')),
      );
      return;
    }

    List<File> newFiles = [];

    for (final picked in pickedFiles) {
      final original = File(picked.path);
      final compressed = await compressImage(original);
      newFiles.add(compressed ?? original);
    }

    setState(() {
      _newImages.addAll(newFiles);
    });
  }

  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'compressed_${p.basename(file.path)}',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // 🔥 60–75 ideal
      format: CompressFormat.jpeg,
    );

    return result != null ? File(result.path) : null;
  }

  Widget _buildImages() {
    final existingImages = widget.item.images; // dari API
    final totalCount = existingImages.length + _newImages.length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Gambar lama (network)
        ...existingImages.map((img) {
          return Image.network(
            img.url,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
          );
        }),

        // Gambar baru (local)
        ..._newImages.map((file) {
          return Image.file(
            file,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
          );
        }),

        // Tombol tambah (jika < 4)
        if (totalCount < 4)
          InkWell(
            onTap: _pickImage,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.add_a_photo),
            ),
          ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);

    final token = context.read<AuthProvider>().token;

    final fields = {
      'kartu_ruang_id': _selectedKartuRuang.toString(),
    };

    final resp = await ApiService.updateInventaris(
      token: token,
      id: widget.item.id,
      fields: fields,
      images: _newImages, // 🔥 LIST, BUKAN SINGLE
    );

    if (!mounted) return;

    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil diupdate')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal update')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Inventaris')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ============================
            // 🔽 DROPDOWN KARTU RUANG
            // ============================

            DropdownField<int>(
              label: 'Pilih Kartu Ruang',
              value: _selectedKartuRuang,
              items: _kartuRuangList.map<DropdownMenuItem<int>>((item) {
                return DropdownMenuItem<int>(
                  value: item['id'],
                  child: Text(item['nama_ruangan'] ?? 'Tanpa Nama'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedKartuRuang = val);
              },
            ),

            const SizedBox(height: 20),

            // ============================
            // 🔽 GAMBAR
            // ============================
            _buildImages(),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // gambar lama (dari API)
                ...widget.item.images.map((img) => Stack(
                      children: [
                        Image.network(img.url,
                            width: 90, height: 90, fit: BoxFit.cover),
                        // nanti bisa ditambah tombol hapus
                      ],
                    )),

                // gambar baru (local)
                ..._newImages.map((file) => Image.file(
                      file,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    )),

                if (widget.item.images.length + _newImages.length < 4)
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[300],
                      child: const Icon(Icons.add_a_photo),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            PrimaryButton(
              text: 'SIMPAN',
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
