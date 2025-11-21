import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:gobek_gone_gone/MainPages/FriendsPage.dart';
import 'package:gobek_gone_gone/General/AppBar.dart';


// Sınıf Adlarını Kontrol Ederek Import Ediyoruz.
// Lütfen buradaki 'Contents/' ön ekini kendi dosya yapınıza göre kontrol edin.
import 'Badges.dart';
//import 'AI.dart';
import 'Friends.dart';
//import 'Contents.dart'; // İçerik dosyanızın adı 'Contents.dart' ise

// Bottom Bar Widget'ını import ediyoruz (General klasöründe)
import '../General/BottomBar.dart';


// Bu, uygulamanın durumunu yönetecek ana widget'tır.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. Controller ve index tanımı
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);
  int _currentIndex = 0;

  // 2. Sayfa listesi tanımı.
  // NOT: Badges'tan sonraki sayfalarda hata alıyorsanız, o dosyaların içindeki sınıf adlarını (AI, Friends, Contents) KONTROL EDİN.
  final List<Widget> _pageList = [
    // 0: Anasayfa
    const HomePageContent(),

    // 1: Rozetler (Sınıf adı Badges ise)
    const BadgesPage(),

    // 2: Yapay Zeka (Sınıf adı AI ise)
    //const AI(),

    // 3: Arkadaşlar (Sınıf adı Friends ise)
    const FriendsPage(),

    // 4: İçerik (Sınıf adı Contents ise)
    //const Contents(),
  ];


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbar(),
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