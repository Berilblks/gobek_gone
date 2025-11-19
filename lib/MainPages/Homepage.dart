import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';

// Page İçeriklerini import ediyoruz (Bu dosyanın bir seviye üstünden pages klasörüne erişiyoruz)
import 'badges.dart';
import 'AI.dart';
import 'friends.dart';
// içerik imporutu


// Bottom Bar Widget'ını import ediyoruz (Bu dosyanın iki seviye üstünden widgets klasörüne erişiyoruz)
import '../General/BottomBar.dart';

// 1. Tüm sayfa widget'larını bir listede topluyoruz. 
// Bu liste, Bottom Bar'daki sırayla eşleşmelidir.
final List<Widget> _pageList = [
  const HomePageContent(), // 0: Anasayfa
];

// Bu, uygulamanın durumunu (hangi sayfanın açık olduğunu) yönetecek ana widget'tır.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 2. Bottom Bar Controller'ı tanımla ve başlangıç index'ini 0 yap
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);
  // 3. Şu anki sayfanın index'ini tut
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anasayfa'),
        backgroundColor: Colors.blueAccent,
      ),
      // Gövdede, _currentIndex'e karşılık gelen sayfayı göster
      body: _pageList[_currentIndex],
      // Barın içeriği arkada görünmesi için zorunlu
      extendBody: true,
      // Bottom Bar'ı yerleştir
      bottomNavigationBar: BottomBar(
        controller: _controller,
        onTap: (index) {
          // Bir sekmeye tıklandığında:
          setState(() {
            _currentIndex = index;           // Yeni index'i kaydet
            _controller.jumpTo(index);       // Bar animasyonunu tetikle
          });
        },
      ),
    );
  }
}

// Anasayfa (0. index) için basit içerik.
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Anasayfa İçeriği', style: TextStyle(fontSize: 24, color: Colors.blueAccent)),
    );
  }
}