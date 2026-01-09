import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simda_mobile/models/inventarisSearch.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_services.dart';
import '../../widgets/inventaris_card.dart';
import 'inventaris_form_screen.dart';

class InventarisListScreen extends StatefulWidget {
  const InventarisListScreen({Key? key}) : super(key: key);

  @override
  State<InventarisListScreen> createState() => _InventarisListScreenState();
}

class _InventarisListScreenState extends State<InventarisListScreen> {
  List<InventarisSearch> items = [];
  List<InventarisSearch> filtered = [];
  bool loading = false;
  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    searchCtrl.addListener(_search);
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final resp = await ApiService.getInventaris(token);

    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body);
      items = list.map((e) => InventarisSearch.fromJson(e)).toList();
      filtered = items;
    }
    setState(() => loading = false);
  }

  void _search() {
    final q = searchCtrl.text.toLowerCase();
    setState(() {
      filtered = items.where((e) {
        return e.jenisBarang.toLowerCase().contains(q) ||
            e.ruangan.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaris'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InventarisFormScreen()),
        ).then((_) => _load()),
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// SEARCH
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Cari barang...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                /// LIST
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      return InventarisCardScreen(item: filtered[i]);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
