import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gobek_gone/General/app_colors.dart';


Widget buildCenterFloatingActionButton({
  required VoidCallback onPressed,        // Tıklandığında çalışacak fonksiyon
  required Color backgroundColor,
  required IconData icon,
}) {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow_color,
          spreadRadius: 3,
          blurRadius: 7,
          offset: const Offset(0, 15),
        ),
      ],
    ),
    child: FloatingActionButton(
      backgroundColor: AppColors.AI_color,
      shape: const CircleBorder(
        side: BorderSide(
          color: AppColors.AIborder_color,
          width: 3,
        ),
      ),
      onPressed: onPressed,
      elevation: 8,
      child: Icon(
        icon,
        size: 40,
        color: Colors.white,
      ),
    ),
  );
}