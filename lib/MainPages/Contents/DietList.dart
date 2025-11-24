import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/BottomBar.dart';
import 'package:gobek_gone/General/Fab.dart';
import 'package:gobek_gone/General/Sidebar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/AI.dart';
import 'package:gobek_gone/MainPages/Badges.dart';
import 'package:gobek_gone/MainPages/Friends.dart';
import 'package:gobek_gone/MainPages/HomeContent.dart';

class DietlistPage extends StatefulWidget {
  const DietlistPage({super.key});

  @override
  State<DietlistPage> createState() => _DietlistPageState();
}

class _DietlistPageState extends State<DietlistPage> {

  int _selectedIndex = 0;
  bool _isSidebarOpen = false;

  static final List<Widget> _screens = [
    Homecontent(),
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
      body: Stack(
        children: [
          Column(

            // sayfa içeriği

          ),

          _screens[_selectedIndex],

          // Karartma arka plan
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: AnimatedOpacity(
                opacity: _isSidebarOpen ? 1.0 : 0.0,
                duration: Duration(milliseconds: 350),
                child: Container(color: Colors.black54),
              ),
            ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: gobekgAppbar(),
          ),

          PositionedSidebar(
            isOpened: _isSidebarOpen,
            onClose: _toggleSidebar,
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
