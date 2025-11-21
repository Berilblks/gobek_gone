import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/app_colors.dart';

class gobekgBottombar extends StatefulWidget {
  const gobekgBottombar({super.key});

  @override
  State<gobekgBottombar> createState() => _gobekgBottombarState();
}

class _gobekgBottombarState extends State<gobekgBottombar> {

  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    Container(),
    Placeholder(),
    Placeholder(),
    Placeholder(),
    Placeholder(),
  ];
  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
        color: Color(0xFF557A77),
        // shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildNavBarItem(CupertinoIcons.home, 'Home', 0),
              buildNavBarItem(CupertinoIcons.checkmark_seal_fill, 'Badges', 1),
              SizedBox(width: 35,),
              buildNavBarItem(CupertinoIcons.person_3_fill, 'Friends', 3),
              buildNavBarItem(CupertinoIcons.list_bullet, 'Badges', 4),
            ],
          ),
        ),
    );
  }

  Widget buildNavBarItem(IconData icon, String label, int index){
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Color(0xFFFFFFFF) : Colors.white,
            fontWeight: _selectedIndex == index ? FontWeight.bold :FontWeight.normal,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Color(0xFF90D9FF) : Colors.white,
              fontWeight: _selectedIndex == index ? FontWeight.w800 :FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
