import 'package:flutter/material.dart';
import 'package:simda_mobile/screens/dashboard_screen.dart';
import 'package:simda_mobile/screens/inventaris/inventaris_form_screen.dart';
import 'inventaris/inventaris_list_screen.dart';
import 'profile_screen.dart';
import '../theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final _screens = const [
    DashboardScreen(),
    InventarisListScreen(),
    InventarisFormScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.blue600,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined), label: 'Inventaris'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: 'Tambah'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
