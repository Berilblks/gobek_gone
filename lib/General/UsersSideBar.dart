import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/LoginPages/OnboardingScreen.dart';
import 'package:gobek_gone/MainPages/UsersBar/Settings.dart';
import 'package:gobek_gone/MainPages/UsersBar/User.dart';
import 'package:gobek_gone/features/auth/logic/auth_bloc.dart';

/*.// --- GEREKLİ YER TUTUCU SAYFALAR (ÖRNEK AMAÇLI) ---
class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("User Profile")), body: Center(child: Text("User Information Page")));
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Settings")), body: Center(child: Text("Application Settings Page")));
}
.*/
// Renklerin doğru çalışması için varsayılan AppThemeColors tanımı (Projenizdekinin aynısı olmalı)
class AppThemeColors {
  static const Color main_background = Color(0xFFF0F4F8);
  static const Color primary_color = Color(0xFF4CAF50);
  static const Color icons_color = Color(0xFF388E3C);
}
// ---------------------------------------------------


class UserSideBar extends StatelessWidget {
  const UserSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.main_background,

      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // ✨ YENİ: ORTALANMIŞ SIDEBAR BAŞLIK KISMI (Custom Header)
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20, // Status bar boşluğu + ekstra
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: AppColors.AI_color, // Arka plan rengi
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // İçeriği ortalar
              children: [
                // Kullanıcı Fotoğrafı
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // Kullanıcı Adı
                const Text(
                  "USERNAME",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),

                // E-posta Adresi
                const Text(
                  "username@mail.com",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // --------------------------------------------------------

          // --- KULLANICI BİLGİLERİ (User Info) ---
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.grey),
            title: const Text("User Information", style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage(),),);
            },
          ),

          const Divider(),

          // --- AYARLAR (Settings) ---
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey),
            title: const Text("Settings", style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(),),);

            },
          ),

          const Divider(),

          // --- OPSİYONEL: ÇIKIŞ YAP (Logout) ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Exit", style: TextStyle(fontSize: 16, color: Colors.red)),
            onTap: () {
              // Trigger Logic Logout
              context.read<AuthBloc>().add(LogoutRequested());
              
              // Navigation
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Onboardingscreen()),
                (route) => false, // Remove all previous routes
              );
            },
          ),
        ],
      ),
    );
  }
}