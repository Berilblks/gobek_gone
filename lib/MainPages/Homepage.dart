import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/BottomBar.dart';
import 'package:gobek_gone/General/Fab.dart';
import 'package:gobek_gone/General/Sidebar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/AI.dart';
import 'package:gobek_gone/MainPages/Badges.dart';
import 'package:gobek_gone/MainPages/Friends.dart';

class Homepage extends StatefulWidget {

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  int _selectedIndex = 0;
  bool _isSidebarOpen = false;

  static final List<Widget> _screens = [
    Homepage(),
    BadgesPage(),
    AIpage(),
    FriendsPage(),
    Center(child: Text("Content Page")),
  ];

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      _toggleSidebar();
    }
    else{
      setState(() {
        _selectedIndex = index;
        if (_isSidebarOpen) {
          _isSidebarOpen = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,
      appBar: gobekgAppbar(),

      body: Stack(
        children: [
          _screens[_selectedIndex],  // ana içerik

          if(_isSidebarOpen)
            Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleSidebar,
                  child: Container(color: Colors.black54,),
                ),
            ),
            PositionedSidebar(
              isOpened: _isSidebarOpen,
              onClose: _toggleSidebar,
            ),
        ],
      ),

      bottomNavigationBar: gobekgBottombar(
        onItemTapped: _onItemTapped,
      ),

      floatingActionButton: buildCenterFloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => AIpage()),);
        },
        backgroundColor: AppColors.AI_color,
        icon: CupertinoIcons.circle_grid_hex,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    );
  }
}