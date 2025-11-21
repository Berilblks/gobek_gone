import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/BottomBar.dart';
import 'package:gobek_gone/General/Fab.dart';
import 'package:gobek_gone/General/app_colors.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const Center(child: Text("Home Page (Index 0)")),
    const Center(child: Text("Badges Page (Index 1)")),
    const Center(child: Text("FAB Action Page (Index 2)")),
    const Center(child: Text("Friends Page (Index 3)")),
    const Center(child: Text("Settings Page (Index 4)")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,
      appBar: gobekgAppbar(),

      body: _screens[_selectedIndex],

      bottomNavigationBar: gobekgBottombar(),

      floatingActionButton: buildCenterFloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: const Color(0xFFC0E0DD),
        icon: CupertinoIcons.circle_grid_hex,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}