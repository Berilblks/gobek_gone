import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/BottomBar.dart';
import 'package:gobek_gone/General/Fab.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/AI.dart';
import 'package:gobek_gone/MainPages/Badges.dart';
import 'package:gobek_gone/MainPages/ContentPage.dart';
import 'package:gobek_gone/MainPages/Friends.dart' hide AppColors;
import 'package:gobek_gone/MainPages/HomeContent.dart';

class Homepage extends StatefulWidget {

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      Homecontent(onTabChange: _onItemTapped),
      BadgesPage(),
      AIpage(),
      FriendsPage(),
      ContentPage(),
    ];
  }

  // Tüm indeksler için sayfa geçişi yapacak şekilde güncellendi
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,

      // Body kısmı Stack yerine daha sade bir yapıya dönüştürüldü.
      body: Column(
        children: [
          // AppBar'ı direkt olarak Column'ın en üstüne yerleştiriyoruz
          //gobekgAppbar(),

          // Geri kalan alanı genişletilmiş bir şekilde mevcut sayfa kaplayacak
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),

      bottomNavigationBar: gobekgBottombar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: buildCenterFloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AIpage()));
        },
        backgroundColor: AppColors.AI_color,
        icon: CupertinoIcons.circle_grid_hex,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}