import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/app_colors.dart';

class gobekgBottombar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  gobekgBottombar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.bottombar_color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildNavBarItem(CupertinoIcons.home, 'Home', 0),
            buildNavBarItem(CupertinoIcons.checkmark_seal_fill, 'Badges', 1),
            SizedBox(width: 38),
            buildNavBarItem(CupertinoIcons.person_3_fill, 'Friends', 3),
            buildNavBarItem(CupertinoIcons.list_bullet, 'Content', 4),
          ],
        ),
      ),
    );
  }

  Widget buildNavBarItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Color(0xFFFFFFFF) : Colors.white,
            size: 32,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.text_color : Colors.white,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
