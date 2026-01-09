import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simda_mobile/providers/auth_provider.dart';
import 'package:simda_mobile/screens/main_screen.dart';
import 'package:simda_mobile/services/api_services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:simda_mobile/widgets/app_text_field.dart';
import 'package:simda_mobile/widgets/dropdown_field.dart';
import 'package:simda_mobile/widgets/image_picker_field.dart';
import 'package:simda_mobile/widgets/primary_button.dart';

class InventarisFormScreen extends StatefulWidget {
  const InventarisFormScreen({Key? key}) : super(key: key);

  @override
  State<InventarisFormScreen> createState() => _InventarisFormScreenState();
}

class _InventarisFormScreenState extends State<InventarisFormScreen> {
  final _kodeBarang = TextEditingController();
  final _kodeRegister = TextEditingController();
  final _jenisBarang = TextEditingController();
  final _merekTipe = TextEditingController();
  final _noSeri = TextEditingController();
  final _bahan = TextEditingController();
  final _caraPerolehan = TextEditingController();
  final _tahunBeli = TextEditingController();
  final _ukuran = TextEditingController();
  final _satuan = TextEditingController();
  final _jumlah = TextEditingController();
  final _harga = TextEditingController();
  final _keterangan = TextEditingController();

  int? _kartuRuangId;
  List<File> _images = [];
  bool _loading = false;
  List<dynamic> _kartuRuangList = [];
  String? _keadaan;

  @override
  void initState() {
    super.initState();
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

    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 85, // ringan saja, server tetap kompres ulang
    );

    if (pickedFiles.isEmpty) return;

    if (_images.length + pickedFiles.length > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 4 gambar')),
      );
      return;
    }

    List<File> newImages = [];

    for (final picked in pickedFiles) {
      final original = File(picked.path);
      final compressed = await compressImage(original);
      newImages.add(compressed ?? original);
    }

    setState(() {
      _images.addAll(newImages);
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

  final List<String> _keadaanList = [
    'Baik',
    'Kurang Baik',
    'Rusak Berat',
  ];

  Future<void> _submit() async {
    if (_kartuRuangId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kartu ruang wajib dipilih')),
      );
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal 1 gambar')),
      );
      return;
    }

    setState(() => _loading = true);
    final token = context.read<AuthProvider>().token;

    final fields = {
      'kartu_ruang_id': _kartuRuangId.toString(),
      'kode_barang': _kodeBarang.text.trim(),
      'kode_register': _kodeRegister.text.trim(),
      'jenis_barang': _jenisBarang.text.trim(),
      'merek_tipe': _merekTipe.text.trim(),
      'no_seri': _noSeri.text.trim(),
      'bahan': _bahan.text.trim(),
      'cara_perolehan': _caraPerolehan.text.trim(),
      'tahun_beli': _tahunBeli.text.trim(),
      'ukuran': _ukuran.text.trim(),
      'satuan': _satuan.text.trim(),
      'keadaan': _keadaan!,
      'jumlah': _jumlah.text.trim(),
      'harga': _harga.text.trim(),
      'keterangan': _keterangan.text.trim(),
    };

    try {
      final resp = await ApiService.uploadInventaris(
        token: token,
        fields: fields,
        images: _images,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(initialIndex: 1), // ← Inventaris
        ),
      );

      if (resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil ditambahkan')),
        );

        Navigator.pop(context, true); // ✅ aman
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan inventaris')),
        );
        setState(() => _loading = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error: $e')),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Inventaris')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownField<int>(
              label: 'Pilih Kartu Ruang',
              value: _kartuRuangId,
              items: _kartuRuangList.map<DropdownMenuItem<int>>((item) {
                return DropdownMenuItem<int>(
                  value: item['id'],
                  child: Text(item['nama_ruangan'] ?? 'Tanpa Nama'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _kartuRuangId = val);
              },
            ),
            const SizedBox(height: 20),
            AppTextField(controller: _kodeBarang, label: 'Kode Barang'),
            const SizedBox(height: 16),
            AppTextField(controller: _kodeRegister, label: 'Kode Register'),
            const SizedBox(height: 16),
            AppTextField(controller: _jenisBarang, label: 'Jenis Barang'),
            const SizedBox(height: 16),
            AppTextField(controller: _merekTipe, label: 'Merek / Tipe'),
            const SizedBox(height: 16),
            AppTextField(controller: _noSeri, label: 'No. Seri'),
            const SizedBox(height: 16),
            AppTextField(controller: _bahan, label: 'Bahan'),
            const SizedBox(height: 16),
            AppTextField(controller: _caraPerolehan, label: 'Cara Perolehan'),
            const SizedBox(height: 16),
            AppTextField(controller: _tahunBeli, label: 'Tahun Beli'),
            const SizedBox(height: 16),
            AppTextField(controller: _ukuran, label: 'Ukuran'),
            const SizedBox(height: 16),
            AppTextField(controller: _satuan, label: 'Satuan'),
            const SizedBox(height: 16),
            DropdownField<String>(
              label: 'Keadaan Barang',
              value: _keadaan,
              items: _keadaanList
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() => _keadaan = val);
              },
            ),
            const SizedBox(height: 16),
            AppTextField(controller: _jumlah, label: 'Jumlah'),
            const SizedBox(height: 16),
            AppTextField(controller: _harga, label: 'Harga'),
            const SizedBox(height: 16),
            AppTextField(controller: _keterangan, label: 'Keterangan'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ..._images.map((img) => Image.file(img, width: 80)),
                if (_images.length < 4)
                  IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: _pickImage,
                  ),
              ],
            ),
            const SizedBox(height: 16),
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
