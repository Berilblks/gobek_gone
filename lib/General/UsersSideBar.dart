import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/LoginPages/OnboardingScreen.dart';
import 'package:gobek_gone/MainPages/UsersBar/Settings.dart';
import 'package:gobek_gone/MainPages/UsersBar/User.dart';
import 'package:gobek_gone/features/auth/logic/auth_bloc.dart';
import 'package:gobek_gone/features/gamification/logic/gamification_bloc.dart';

class UserSideBar extends StatefulWidget {
  const UserSideBar({super.key});

  @override
  State<UserSideBar> createState() => _UserSideBarState();
}

class _UserSideBarState extends State<UserSideBar> {

  @override
  void initState() {
    super.initState();
    context.read<GamificationBloc>().add(LoadLevelProgress());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              String userName = "Guest";
              String email = "guest@example.com";
              String? profilePhoto;

              if (authState is AuthAuthenticated && authState.user != null) {
                userName = authState.user!.username;
                email = authState.user!.email;
                profilePhoto = authState.user!.profilePhoto;
              }

              return Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 30,
                  bottom: 30,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.bottombar_color, AppColors.AI_color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bottombar_color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white24,
                        backgroundImage: (profilePhoto != null && profilePhoto.isNotEmpty)
                            ? MemoryImage(base64Decode(profilePhoto))
                            : null,
                        child: (profilePhoto == null || profilePhoto.isEmpty)
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    BlocBuilder<GamificationBloc, GamificationState>(
                      builder: (context, gameState) {
                         if (gameState.levelProgress != null) {
                           return Column(
                             children: [
                               const SizedBox(height: 15),
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                 decoration: BoxDecoration(
                                   color: Colors.white.withValues(alpha: 0.2),
                                   borderRadius: BorderRadius.circular(20),
                                   border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                 ),
                                 child: Row(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                     const SizedBox(width: 8),
                                     Text(
                                       "Level ${gameState.levelProgress!.level}",
                                       style: const TextStyle(
                                         color: Colors.white,
                                         fontWeight: FontWeight.bold,
                                         fontSize: 15,
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           );
                         }
                         return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: "Profile",
                    subtitle: "View your personal information",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserPage())),
                  ),
                  const SizedBox(height: 15),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    subtitle: "App preferences and security",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 60),
            child: InkWell(
              onTap: () {
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Onboardingscreen()),
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.red.shade700),
                    const SizedBox(width: 10),
                    Text(
                      "Log Out",
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.appbar_color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.black45, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}