import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/BottomBar.dart';
import 'package:gobek_gone/General/Fab.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/AI.dart';
import 'package:gobek_gone/MainPages/Homepage.dart';
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
  BadgeModel(id: 1, name: "İlk Adım", description: "Uygulamaya başarıyla giriş yaptın.", isCompleted: true, iconPath: '👟'),
  BadgeModel(id: 2, name: "5K Koşucusu", description: "Toplamda 5 kilometre koşu tamamla.", isCompleted: true, iconPath: '🏃'),
  BadgeModel(id: 3, name: "Su Uzmanı", description: "7 gün boyunca günlük su hedefini tamamla.", isCompleted: false, iconPath: '💧'),
  BadgeModel(id: 4, name: "Egzersiz Zinciri", description: "14 gün aralıksız egzersiz yap.", isCompleted: false, iconPath: '💪'),
  BadgeModel(id: 5, name: "Göbek Savaşçısı", description: "İlk 5 kiloyu ver.", isCompleted: true, iconPath: '🔥'),
  BadgeModel(id: 6, name: "Yapay Zeka Dostu", description: "AI'dan 10 farklı tavsiye al.", isCompleted: false, iconPath: '🧠'),
];

// 2. Rozetler Sayfası
class BadgesPage extends StatelessWidget {
  const BadgesPage({Key? key}) : super(key: key);

  // Sosyal Medya Paylaşım Fonksiyonu
  void _shareBadge(BuildContext context, BadgeModel badge) async {
    final String text = badge.isCompleted
        ? "Harika! Göbek Gone'da '${badge.name}' rozetini kazandım: ${badge.description}. Hadi sen de bu sağlıklı yaşam yolculuğuna katıl!"
        : "Bu rozeti kazanmak için çalışıyorum: ${badge.name}! Göbek Gone ile hedeflerime yürüyorum.";

    // Paylaşım paketini kullanarak metni paylaşıyoruz.
    await Share.share(text, subject: 'Göbek Gone Rozet Başarısı');
  }

  // Rozet Detay Modalını Gösteren Fonksiyon
  void _showBadgeDetail(BuildContext context, BadgeModel badge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(24),
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
                label: Text("Başarımı Paylaş"),
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
                  label: Text("Henüz Tamamlanmadı"),
                  backgroundColor: Colors.red.shade50,
                  labelStyle: TextStyle(color: Colors.red.shade700)),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = kToolbarHeight + MediaQuery.of(context).padding.top;
      // Rozetler için ızgara görünümü
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Toplam ${mockBadges.where((b) => b.isCompleted).length} Rozet Kazandın!",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
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
                    onTap: () => _showBadgeDetail(context, badge),
                    borderRadius: BorderRadius.circular(16),
                    child: BadgeItem(badge: badge),
                  );
                },
              ),
            ),
          ],
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
              badge.isCompleted ? "Kazanıldı" : "Kilitli",
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