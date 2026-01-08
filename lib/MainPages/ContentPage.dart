import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/Contents/ActivitylistPage.dart';
import 'package:gobek_gone/MainPages/Contents/AddictionCessation.dart';
import 'package:gobek_gone/MainPages/Contents/BMI.dart';
import 'package:gobek_gone/MainPages/Contents/DietList.dart';
import 'package:gobek_gone/MainPages/Contents/ProgressTracking.dart';
import 'package:gobek_gone/MainPages/Contents/Tasks.dart';

class HomeCardItem {
  final String title;
  final IconData icon;
  final Widget targetPage;
  final List<Color> colors;

  HomeCardItem({
    required this.title, 
    required this.icon, 
    required this.targetPage,
    required this.colors,
  });
}

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {

  final List<HomeCardItem> cardItems = [
    HomeCardItem(
      title: "Body Mass Index", 
      icon: Icons.monitor_weight_outlined, 
      targetPage: BMICalculatorPage(),
      colors: [Colors.blueAccent, Colors.blue.shade300],
    ),
    HomeCardItem(
      title: "Progress Tracking", 
      icon: Icons.show_chart_rounded, 
      targetPage: ProgressTracking(),
      colors: [Colors.purpleAccent, Colors.purple.shade300],
    ),
    HomeCardItem(
      title: "Tasks", 
      icon: Icons.task_alt_rounded, 
      targetPage: Tasks(),
      colors: [Colors.orangeAccent, Colors.orange.shade300],
    ),
    HomeCardItem(
      title: "Diet List", 
      icon: Icons.restaurant_menu_rounded, 
      targetPage: DietList(),
      colors: [Colors.greenAccent.shade700, Colors.green.shade400],
    ),
    HomeCardItem(
      title: "Exercises", 
      icon: Icons.fitness_center_rounded, 
      targetPage: ActivitylistPage(),
      colors: [Colors.redAccent, Colors.red.shade300],
    ),
    HomeCardItem(
      title: "Addiction Cessation", 
      icon: Icons.spa_rounded, 
      targetPage: AddictionCessation(),
      colors: [Colors.tealAccent.shade700, Colors.teal.shade400],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: gobekgAppbar(),
      endDrawer: const UserSideBar(),
      backgroundColor: AppColors.main_background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        child: GridView.builder(
          itemCount: cardItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 20.0,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            return _buildContentCard(context, cardItems[index]);
          },
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, HomeCardItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item.targetPage),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: item.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item.colors.first.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    size: 32.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Tap to view",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}