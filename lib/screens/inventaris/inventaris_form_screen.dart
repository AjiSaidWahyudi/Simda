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
  final _namaPemegang = TextEditingController();
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

  Future<void> _showImageSourcePicker() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    if (_images.length >= 4) {
      _showLimitWarning();
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (picked == null) return;

    final original = File(picked.path);
    final compressed = await compressImage(original);

    setState(() {
      _images.add(compressed ?? original);
    });
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 85);

    if (pickedFiles.isEmpty) return;

    if (_images.length + pickedFiles.length > 4) {
      _showLimitWarning();
      return;
    }

    for (final picked in pickedFiles) {
      final original = File(picked.path);
      final compressed = await compressImage(original);
      _images.add(compressed ?? original);
    }

    setState(() {});
  }

  void _showLimitWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Maksimal 4 gambar')),
    );
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

  @override
  void dispose() {
    _kodeBarang.dispose();
    _kodeRegister.dispose();
    _jenisBarang.dispose();
    _namaPemegang.dispose();
    _merekTipe.dispose();
    _noSeri.dispose();
    _bahan.dispose();
    _caraPerolehan.dispose();
    _tahunBeli.dispose();
    _ukuran.dispose();
    _satuan.dispose();
    _jumlah.dispose();
    _harga.dispose();
    _keterangan.dispose();
    super.dispose();
  }

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
      'nama_pemegang': _namaPemegang.text.trim(),
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
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  enabled: false, // ❗ biar gak bisa dipilih
                  child: Text(
                    'Pilih Ruang',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ..._kartuRuangList.map<DropdownMenuItem<int>>((item) {
                  return DropdownMenuItem<int>(
                    value: item['id'],
                    child: Text(item['nama_ruangan'] ?? 'Tanpa Nama'),
                  );
                }),
              ],
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
            AppTextField(controller: _namaPemegang, label: 'Nama Pemegang'),
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
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._images.asMap().entries.map((entry) {
                  final index = entry.key;
                  final img = entry.value;

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          img,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // ❌ tombol hapus
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _images.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                // ➕ tombol tambah
                if (_images.length < 4)
                  GestureDetector(
                    onTap: _loading ? null : _showImageSourcePicker,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined),
                    ),
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
