import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
// SVG kullanımı paket içinde sorun çıkarabileceği için kaldırıldı.
// import 'package:flutter_svg/flutter_svg.dart';


abstract class NavPage {
  static const int home = 0;
  static const int badges = 1;
  static const int ai = 2;
  static const int friends = 3;
  static const int content = 4;
}

class BottomBar extends StatelessWidget {
  BottomBar({
    super.key,
    required this.controller,
    required this.onTap,
  });

  final NotchBottomBarController controller;
  final Function(int) onTap;

  // Bottom Bar öğelerini oluştururken sadece standart Icon widget'ları kullanıldı.
  // Bu, paketin sorunsuz çalışmasını sağlar.
  final List<BottomBarItem> bottomBarItems = [
    // 0: Anasayfa
    const BottomBarItem(
      inActiveItem: Icon(Icons.home_outlined, color: Colors.blueGrey, size: 24),
      activeItem: Icon(Icons.home, color: Color(0xFF4CAF50), size: 26), // Yeşil tonu (Göbek Gone teması)
      itemLabel: 'Anasayfa',
    ),
    // 1: Rozetler
    const BottomBarItem(
      inActiveItem: Icon(Icons.stars_outlined, color: Colors.blueGrey, size: 24),
      activeItem: Icon(Icons.stars, color: Color(0xFF8BC34A), size: 26), // Yeşil tonu
      itemLabel: 'Rozetler',
    ),

    // 2: YAPAY ZEKA (Özel bir ikon kullanıldı)
    const BottomBarItem(
      inActiveItem: Icon(Icons.psychology_alt_outlined, color: Colors.blueGrey, size: 24),
      activeItem: Icon(Icons.psychology_alt, color: Color(0xFF689F38), size: 26), // Koyu Yeşil tonu
      itemLabel: 'Yapay Zeka',
    ),

    // 3: Arkadaşlar (Bildirim gönderme)
    const BottomBarItem(
      inActiveItem: Icon(Icons.notifications_active_outlined, color: Colors.blueGrey, size: 24),
      activeItem: Icon(Icons.notifications_active, color: Color(0xFF4CAF50), size: 26), // Yeşil tonu
      itemLabel: 'Bildirim',
    ),
    // 4: İçerik (Sidebar'ı açacak menü)
    const BottomBarItem(
      inActiveItem: Icon(Icons.menu_book_outlined, color: Colors.blueGrey, size: 24),
      activeItem: Icon(Icons.menu_book, color: Color(0xFF8BC34A), size: 26), // Yeşil tonu
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
      bottomBarHeight: 65, // Biraz yükseltildi

      /// Arka plan rengi (Uygulama temanızla uyumlu olması için hafif gri/yeşil)
      color: Colors.white,

      /// Tıklandığında çağrılır.
      onTap: (index) {
        onTap(index);
      },

      // İstenen ve büyük ihtimalle paketin null güvenliği nedeniyle zorunlu olan parametreler:
      removeMargins: false,
      notchColor: Colors.white,

      // Paketin iç yapısındaki olası bir zorunluluğu atlamak için null atıyoruz.
      // Bu, paketin eski bir sürümünde zorunlu olan, ancak yeni sürümde isteğe bağlı hale gelen
      // veya tamamen kaldırılan parametreler için yaygın bir geçici çözümdür.
      kIconSize: 24.0, // Hatanın çözümü için eklendi
      kBottomRadius: 10.0, // Hatanın çözümü için eklendi

      // Diğer isteğe bağlı parametreler...
      showLabel: true,

      // Öğeler arasındaki boşluğu ayarlayabilirsiniz
      itemLabelStyle: TextStyle(fontSize: 12, color: Colors.blueGrey.shade800),

      // Çentik şeklini ayarlayın
      showBlurBottomBar: false, // Kenarlara blur efekti ekler

    );
  }
}