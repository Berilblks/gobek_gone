import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:share_plus/share_plus.dart';

// 1. Veri Modeli
// Rozetlerin yapısını tanımlayan sınıf.
class BadgeModel {
  final int id;
  final String name;
  final String description;
  final bool isCompleted;
  final String iconPath;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isCompleted,
    required this.iconPath,
  });
}

// Statik Rozet Listesi (İlk UI Taslağı İçin)
final List<BadgeModel> mockBadges = [
  BadgeModel(id: 1, name: "First Step", description: "You have successfully logged into the application.", isCompleted: true, iconPath: '👟'),
  BadgeModel(id: 2, name: "5K Runner", description: "Complete a total of 5 kilometers of running.", isCompleted: true, iconPath: '🏃'),
  BadgeModel(id: 3, name: "Water Specialist", description: "Complete your daily water goal for 7 days.", isCompleted: false, iconPath: '💧'),
  BadgeModel(id: 4, name: "Exercise Chain", description: "Exercise for 14 days straight.", isCompleted: false, iconPath: '💪'),
  BadgeModel(id: 5, name: "Belly Warrior", description: "Lose the first 5 pounds.", isCompleted: true, iconPath: '🔥'),
  BadgeModel(id: 6, name: "AI-Friednly", description: "Get 10 different recommendations from AI.", isCompleted: false, iconPath: '🧠'),
];

// 2. Rozetler Sayfası
class BadgesPage extends StatelessWidget {
  const BadgesPage({Key? key}) : super(key: key);

  // Sosyal Medya Paylaşım Fonksiyonu
  void _shareBadge(BuildContext context, BadgeModel badge) async {
    final String text = badge.isCompleted
        ? "Great! I earned the'${badge.name}' badge on Göbek Gone: ${badge.description}. Come join this healthy living journey!"
        : "I'm working to earn this badge: ${badge.name}! I'm walking toward my goals with Göbek Gone.";

    // Paylaşım paketini kullanarak metni paylaşıyoruz.
    await Share.share(text, subject: 'Göbek Gone Badge Succes');
  }

  // Rozet Detay Modalını Gösteren Fonksiyon
  void _showBadgeDetail(BuildContext context, BadgeModel badge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return SizedBox(
          height: 325,
          width: 375,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.main_background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            //padding: EdgeInsets.all(100),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  badge.iconPath, // Rozet ikonu (emoji kullandık)
                  style: TextStyle(fontSize: 80),
                ),
                SizedBox(height: 10),
                Text(
                  badge.name,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800),
                ),
                SizedBox(height: 15),
                Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                SizedBox(height: 25),
                badge.isCompleted
                    ? ElevatedButton.icon(
                  onPressed: () => _shareBadge(context, badge),
                  icon: Icon(Icons.share, size: 20),
                  label: Text("Share My Success"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen.shade400,
                    foregroundColor: Colors.white,
                    padding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                )
                    : Chip(
                    label: Text("Not yet completed"),
                    backgroundColor: Colors.red.shade50,
                    labelStyle: TextStyle(color: Colors.red.shade700)),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) { // <-- Sadece tek bir build metodu olmalı
    return Scaffold(
      appBar: gobekgAppbar(), // AppBar eklendi
      endDrawer: const UserSideBar(),
      // Rozetler için ızgara görünümü Scafold'un body'si oldu
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    "Total: ${mockBadges.where((b) => b.isCompleted).length} You've earned a badge!",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800
                    ),
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Mobil için 2 sütun ideal
                  childAspectRatio: 1.0, // Kare şeklinde
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: mockBadges.length,
                itemBuilder: (context, index) {
                  final badge = mockBadges[index];
                  // Rozet öğesini oluştur
                  return InkWell(
                    onTap: () => _showBadgeDetail(context, badge), // Hata veren kısım şimdi doğru bağlamda
                    borderRadius: BorderRadius.circular(16),
                    child: BadgeItem(badge: badge),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// 3. Rozet Izgara Öğesi Widget'ı
class BadgeItem extends StatelessWidget {
  final BadgeModel badge;
  const BadgeItem({Key? key, required this.badge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tamamlanma durumuna göre renk ve kilit simgesi belirliyoruz.
    final Color color = badge.isCompleted
        ? Colors.lightGreen.shade400
        : Colors.grey.shade300;
    final Color textColor = badge.isCompleted ? Colors.green.shade900 : Colors.grey.shade600;
    final Color iconColor = badge.isCompleted ? Colors.white : Colors.grey.shade500;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: badge.isCompleted ? Colors.lightGreen.shade600 : Colors.grey.shade300,
              width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Rozet İkonu veya Kilit Simgesi
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: badge.isCompleted ? Colors.green.shade800.withOpacity(0.8) : Colors.white70,
                  child: Text(
                    badge.iconPath,
                    style: TextStyle(fontSize: 35),
                  ),
                ),
                if (!badge.isCompleted)
                  Icon(
                    Icons.lock,
                    color: Colors.black54,
                    size: 24,
                  ),
              ],
            ),
            SizedBox(height: 10),
            // Rozet Adı
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
            SizedBox(height: 4),
            // Tamamlanma Durumu Metni
            Text(
              badge.isCompleted ? "Won" : "Locked",
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}