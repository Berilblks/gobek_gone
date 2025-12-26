import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/BottomBar.dart';
import 'package:gobek_gone/General/Fab.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/AI.dart';
import 'package:gobek_gone/MainPages/Badges.dart';
import 'package:gobek_gone/MainPages/Contents/ActivitylistPage.dart' hide AppColors;
import 'package:gobek_gone/MainPages/Contents/AddictionCessation.dart';
import 'package:gobek_gone/MainPages/Contents/BMI.dart';
import 'package:gobek_gone/MainPages/Contents/DietList.dart';
import 'package:gobek_gone/MainPages/Contents/ProgressTracking.dart';
import 'package:gobek_gone/MainPages/Contents/Tasks.dart';
import 'package:gobek_gone/MainPages/Friends.dart' hide AppColors;
import 'package:gobek_gone/MainPages/HomeContent.dart';

class HomeCardItem {
  final String title;
  final IconData icon;
  final Widget targetPage;

  HomeCardItem({required this.title, required this.icon, required this.targetPage});
}

// ContentPage sınıfı
class ContentPage extends StatefulWidget {


  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {

  int _selectedIndex = 4;

  // 2. Kart Verilerini Tanımlama
  final List<HomeCardItem> cardItems = [
    HomeCardItem(title: "Body Mass Index", icon: Icons.monitor_weight, targetPage: BMICalculatorPage()),
    HomeCardItem(title: "Progress Tracking", icon: Icons.timeline, targetPage: ProgressTracking()),
    HomeCardItem(title: "Tasks", icon: Icons.checklist, targetPage: Tasks()),
    HomeCardItem(title: "Diet List", icon: Icons.restaurant, targetPage: DietList()),
    HomeCardItem(title: "Exercises", icon: Icons.directions_run, targetPage: ActivitylistPage()),
    HomeCardItem(title: "Addiction Cessation", icon: Icons.nature_people, targetPage: AddictionCessation()),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: gobekgAppbar(),
      endDrawer: const UserSideBar(),
      backgroundColor: AppColors.main_background,

      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 15.0,
          children: cardItems.map((item) {
            return _buildContentCard(context, item);
          }).toList(),
        ),
      ),

    );
  }

  // Kartı Oluşturan ve Yönlendirme Yapan Fonksiyon
  Widget _buildContentCard(BuildContext context, HomeCardItem item) {
    return Card(
      elevation: 15,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: AppColors.bottombar_color,
          width: 1,
        ),
      ),
      child: InkWell(
        // Tıklama işlevi
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // Sayfaya Yönlendirme (Navigasyon)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => item.targetPage,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              item.icon,
              size: 50.0,
              color: AppColors.icons_color,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}