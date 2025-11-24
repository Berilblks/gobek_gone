// MenuListPage.dart
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/app_colors.dart';
// Yeni menü sayfalarını import ediyoruz
import 'package:gobek_gone/MainPages/Contents/activitylistpage.dart';
import 'package:gobek_gone/MainPages/Contents/addictionCessation.dart';
import 'package:gobek_gone/MainPages/Contents/BMI.dart';
import 'package:gobek_gone/MainPages/Contents/dietlist.dart';
import 'package:gobek_gone/MainPages/Contents/progressTracking.dart';
import 'package:gobek_gone/MainPages/Contents/tasks.dart';

class Contentpage extends StatelessWidget {

  // Menü öğelerinin listesi (Başlık, İkon ve Hedef Sayfa)
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Activity List', 'icon': Icons.directions_run, 'destination': ActivitylistPage()},
    {'title': 'Addiction Cessation', 'icon': Icons.thumb_up, 'destination': AddictioncessationScreen()},
    //{'title': 'Vücut Kitle İndeksi (BMI)', 'icon': Icons.monitor_weight, 'destination': BMI()},
    {'title': 'Diet List', 'icon': Icons.restaurant_menu, 'destination': DietlistPage()},
    //{'title': 'İlerleme Takibi', 'icon': Icons.timeline, 'destination': ProgressTracking()},
    //{'title': 'Görevler', 'icon': Icons.checklist, 'destination': Tasks()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,
      appBar: AppBar(
        title: const Text(
          'Tüm Araçlar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.main_background,
        elevation: 0,
        automaticallyImplyLeading: false, // BottomBar'dan geldiği için geri butonu gizle
      ),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Card(
              color: AppColors.text_color,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(item['icon'], color: AppColors.main_background),
                title: Text(
                  item['title'],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                onTap: () {
                  // Tıklanan menü öğesine göre gezinme (Navigation) yapılır
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => item['destination']),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}