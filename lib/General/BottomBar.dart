import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';


abstract class NavPage {
  static const int home = 0;
  static const int badges = 1;
  static const int ai = 2;
  static const int friends = 3;
  static const int content = 4;
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.controller,
    required this.onTap,
  });

  final NotchBottomBarController controller;
  final Function(int) onTap;

  final List<BottomBarItem> bottomBarItems = const [
    BottomBarItem(
      inActiveItem: Icon(Icons.home, color: Colors.blueGrey),
      activeItem: Icon(Icons.home, color: Colors.blueAccent),
      itemLabel: 'Anasayfa',
    ),
    BottomBarItem(
      inActiveItem: Icon(Icons.star, color: Colors.blueGrey),
      activeItem: Icon(Icons.star, color: Colors.blueAccent),
      itemLabel: 'Rozetler',
    ),
    BottomBarItem(
      inActiveItem: Icon(Icons.computer, color: Colors.blueGrey),
      activeItem: Icon(Icons.computer, color: Colors.blueAccent),
      itemLabel: 'Yapay Zeka',
    ),
    BottomBarItem(
      inActiveItem: Icon(Icons.group, color: Colors.blueGrey),
      activeItem: Icon(Icons.group, color: Colors.blueAccent),
      itemLabel: 'Arkadaşlar',
    ),
    BottomBarItem(
      inActiveItem: Icon(Icons.article, color: Colors.blueGrey),
      activeItem: Icon(Icons.article, color: Colors.blueAccent),
      itemLabel: 'İçerik',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedNotchBottomBar(
      /// [NotchBottomBarController] zorunlu.
      notchBottomBarController: controller,

      /// Öğelerin listesi zorunlu.
      bottomBarItems: bottomBarItems,

      /// Yüksekliği isteğe bağlıdır, varsayılanı 60'tır.
      bottomBarHeight: 60,

      /// Arka plan rengi
      color: Colors.white,

      kBottomRadius: 25.0, // Varsayılan bir değer ekledik
      kIconSize: 24.0,      // Varsayılan bir değer ekledik


      /// Tıklandığında çağrılır.
      onTap: (index) {
        onTap(index);
      },

      // Diğer isteğe bağlı parametreler...
      showLabel: true,
      notchColor: Colors.white,
      removeMargins: false,
    );
  }
}

