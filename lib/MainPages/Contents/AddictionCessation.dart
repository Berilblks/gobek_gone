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

class Habit {
  final String name;
  final String currentGoal;
  final int attempt;
  final String record;
  final Color color;
  final IconData icon;
  final String expandedContent; // Akordeon açıldığında gösterilecek içerik

  const Habit(this.name, this.currentGoal, this.attempt, this.record, this.color, this.icon, this.expandedContent);
}

class AddictioncessationScreen extends StatefulWidget {
  const AddictioncessationScreen({super.key});

  final List<Habit> habits = const [
    Habit(
        "Smoking",
        "7 Days", 5,
        "9 Days",
        Color(0xFFE53935),
        Icons.local_fire_department,
        "Bu alışkanlık 5 kez bozuldu. En uzun kesintisiz süreniz 9 gündü. Daha fazla yardım için bir uzmana danışabilirsiniz."
    ),
    Habit(
      "Alcohol",
      "60 days",
      3,
      "32 days",
      Color(0xFF29B6F6),
      Icons.local_bar,
      "60 günlük hedefinize ulaşmak için 28 gün kaldı. Zorlandığınız anlar için motivasyon teknikleri uygulayın.",
    ),
  ];

  @override
  State<AddictioncessationScreen> createState() => _AddictioncessationScreenState();
}

class _AddictioncessationScreenState extends State<AddictioncessationScreen> {

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
          ListView(
            padding: const EdgeInsets.only(top: 80, bottom: 80),
            children: [
              // Motivasyon Başlığı
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Let's Get Rid of Our Addictions",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              //  İlerleme Paneli
              Row(
                children: [
                  // Kartlar buraya gelecek
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(16),
                      height: 150,
                      color: Colors.blue.shade100,
                      child: Center(child: Text("Süre Kartı")),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(16),
                      height: 150,
                      color: Colors.green.shade100,
                      child: Center(child: Text("Tasarruf Kartı")),
                    ),
                  ),
                ],
              ),
              // Günlük Kayıt Butonu
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () { /* Log modalı */ },
                  child: const Text('Bugünkü Tüketimi Kaydet'),
                ),
              ),

              // Grafik Alanı
              Container(
                height: 250,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text("Tüketim Trendi Grafiği Alanı")),
              ),

              // Yapay Zeka Öneri Kartı
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.yellow.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Yapay Zeka Önerileri ve Rozet Hedefleri"),
                  ),
                ),
              ),
            ],
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
