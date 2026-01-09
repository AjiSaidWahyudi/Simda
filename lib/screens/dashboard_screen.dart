import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simda_mobile/models/inventarisSearch.dart';
import 'package:simda_mobile/providers/auth_provider.dart';
import 'package:simda_mobile/services/api_services.dart';
import 'package:simda_mobile/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:simda_mobile/widgets/inventaris_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<InventarisSearch> _items = [];
  Timer? _debounce;
  bool _isSearching = false;

  int _total = 0;
  int _baik = 0;
  int _rusakRingan = 0;
  int _rusakBerat = 0;
  bool _loadingStat = true;

  void _onSearchChanged(String keyword) {
    _debounce?.cancel();

    if (keyword.isEmpty) {
      setState(() {
        _isSearching = false;
        _items = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchInventaris(keyword);
    });
  }

  int _searchRequestId = 0;

  Future<void> _searchInventaris(String keyword) async {
    final requestId = ++_searchRequestId;

    setState(() => _isLoading = true);

    final result = await ApiService.searchInventaris(keyword);

    if (requestId != _searchRequestId) return;

    setState(() {
      _items = result;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _fetchStatistic();
  }

  Future<void> _fetchStatistic() async {
    final token = context.read<AuthProvider>().token;

    try {
      final data = await ApiService.getTotal(token);

      setState(() {
        _total = data['total'];
        _baik = data['baik'];
        _rusakRingan = data['kurang_baik'];
        _rusakBerat = data['rusak_berat'];
        _loadingStat = false;
      });
    } catch (e) {
      debugPrint('Dashboard error: $e');
      setState(() => _loadingStat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// 🔒 USER INFO (STICKY)
          SliverPersistentHeader(
            pinned: true,
            delegate: _UserHeaderDelegate(
              name: auth.name,
              username: auth.username,
            ),
          ),

          /// 🔒 SEARCH (STICKY)
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchHeaderDelegate(
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
          ),

          /// 📜 CONTENT SCROLL
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _isSearching ? _buildSearchResult() : _buildStatistic(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Inventaris',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.blue600,
                AppColors.blue800,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: _loadingStat
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(title: 'Total', value: _total.toString()),
                    _StatItem(title: 'Baik', value: _baik.toString()),
                    _StatItem(
                        title: 'Rusak Ringan', value: _rusakRingan.toString()),
                    _StatItem(
                        title: 'Rusak Berat', value: _rusakBerat.toString()),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSearchResult() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return const Text(
        'Tidak ada hasil',
        style: TextStyle(color: Colors.grey),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _items[index];
        return InventarisCardScreen(item: item);
      },
    );
  }
}

class _UserHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 100;
  @override
  double get maxExtent => 100;

  final String name;
  final String username;

  _UserHeaderDelegate({
    required this.name,
    required this.username,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blue600, AppColors.blue800],
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage('assets/images/avatar.jpg'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name.isEmpty ? '...' : name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                username.isEmpty ? '' : username,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_) => false;
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final Function(String) onChanged;

  _SearchHeaderDelegate({
    required this.controller,
    required this.onChanged,
  });

  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 70;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Cari barang atau ruangan...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_) => false;
}

/// ======================= /// STAT ITEM /// =======================
class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  const _StatItem({
    required this.title,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
