import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/LoginPages/OnboardingScreen.dart';
import 'package:gobek_gone/MainPages/UsersBar/Settings.dart';
import 'package:gobek_gone/MainPages/UsersBar/User.dart';
import 'package:gobek_gone/features/auth/logic/auth_bloc.dart';

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
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String userName = "Guest";
              String email = "guest@example.com";
              
              if (state is AuthAuthenticated && state.user != null) {
                // Backend'den gelen username bilgisini kullan
                userName = state.user!.username;
                email = state.user!.email;
              }

              return Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.AI_color.withOpacity(0.9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Kullanıcı Fotoğrafı
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      backgroundImage: (state is AuthAuthenticated && 
                                      state.user?.profilePhoto != null && 
                                      state.user!.profilePhoto!.isNotEmpty)
                          ? MemoryImage(base64Decode(state.user!.profilePhoto!))
                          : null,
                      child: (state is AuthAuthenticated && 
                              state.user?.profilePhoto != null && 
                              state.user!.profilePhoto!.isNotEmpty)
                          ? null
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(height: 10),

                    // Kullanıcı Adı
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // E-posta Adresi
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
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