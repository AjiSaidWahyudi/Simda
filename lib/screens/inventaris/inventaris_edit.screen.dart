import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:simda_mobile/models/inventarisImages.dart';
import 'package:simda_mobile/services/api_services.dart';
import 'package:simda_mobile/widgets/dropdown_field.dart';
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
  bool _loading = false;
  List<dynamic> _kartuRuangList = [];

  List<InventarisImage> _existingImages = [];
  List<File> _newImages = [];
  List<int> _deletedImageIds = [];

  @override
  void initState() {
    super.initState();
    _selectedKartuRuang = widget.item.kartuRuangId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchKartuRuang();
    });
    _existingImages = List.from(widget.item.images);
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
    if ((_existingImages.length + _newImages.length) >= 4) {
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
      _newImages.add(compressed ?? original);
    });
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 85);

    if (pickedFiles.isEmpty) return;

    if (_existingImages.length + _newImages.length + pickedFiles.length > 4) {
      _showLimitWarning();
      return;
    }

    for (final picked in pickedFiles) {
      final original = File(picked.path);
      final compressed = await compressImage(original);
      _newImages.add(compressed ?? original);
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
      newImages: _newImages,
      deletedImageIds: _deletedImageIds,
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

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // ==========================
                // GAMBAR LAMA (SERVER)
                // ==========================
                ..._existingImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final img = entry.value;

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          img.url,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _deletedImageIds.add(_existingImages[index].id);
                              _existingImages.removeAt(index);
                            });
                          },
                          child: _removeBtn(),
                        ),
                      ),
                    ],
                  );
                }),

                // ==========================
                // GAMBAR BARU (LOKAL)
                // ==========================
                ..._newImages.asMap().entries.map((entry) {
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
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _newImages.removeAt(index);
                            });
                          },
                          child: _removeBtn(),
                        ),
                      ),
                    ],
                  );
                }),

                // ==========================
                // TOMBOL TAMBAH
                // ==========================
                if ((_existingImages.length + _newImages.length) < 4)
                  GestureDetector(
                    onTap: _loading ? null : _showImageSourcePicker,
                    child: _addBox(),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            PrimaryButton(
              text: 'SIMPAN',
              loading: _loading,
              onPressed: _loading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _removeBtn() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.7),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.close, size: 18, color: Colors.white),
  );
}

Widget _addBox() {
  return Container(
    width: 90,
    height: 90,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade400),
    ),
    child: const Icon(Icons.add_a_photo_outlined),
  );
}
