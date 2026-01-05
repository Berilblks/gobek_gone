import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/LoginPages/OnboardingScreen.dart';
import 'package:gobek_gone/MainPages/UsersBar/Settings.dart';
import 'package:gobek_gone/MainPages/UsersBar/User.dart';
import 'package:gobek_gone/features/auth/logic/auth_bloc.dart';
import 'package:gobek_gone/core/network/api_client.dart';
import 'package:gobek_gone/core/constants/app_constants.dart';
import 'package:gobek_gone/features/gamification/data/models/level_progress_response.dart';
import 'package:gobek_gone/features/gamification/data/services/gamification_service.dart';

class AppThemeColors {
  static const Color main_background = Color(0xFFF0F4F8);
  static const Color primary_color = Color(0xFF4CAF50);
  static const Color icons_color = Color(0xFF388E3C);
}
// ---------------------------------------------------


class UserSideBar extends StatefulWidget {
  const UserSideBar({super.key});

  @override
  State<UserSideBar> createState() => _UserSideBarState();
}

class _UserSideBarState extends State<UserSideBar> {
  LevelProgressResponse? _levelData;

  @override
  void initState() {
    super.initState();
    _fetchLevel();
  }

  Future<void> _fetchLevel() async {
    try {
      // Assuming context is available or passing ApiClient differently if needed (but drawer has context)
      // Safest is to use AppConstants directly as in HomeContent
      final service = GamificationService(ApiClient(baseUrl: AppConstants.apiBaseUrl));
      final data = await service.getLevelProgress();
      if (mounted && data != null) {
        setState(() => _levelData = data);
      }
    } catch (_) {}
  }

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

                     // LEVEL ROZETİ
                    if (_levelData != null)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 16),
                            const SizedBox(width: 5),
                            Text("Lvl ${_levelData!.level}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
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