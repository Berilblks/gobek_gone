import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/features/badges/data/models/badge_model.dart';
import 'package:gobek_gone/features/badges/logic/badge_bloc.dart';
import 'package:share_plus/share_plus.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({Key? key}) : super(key: key);

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  @override
  void initState() {
    super.initState();
    // Trigger loading of badges
    context.read<BadgeBloc>().add(LoadBadges());
  }

  void _shareBadge(BuildContext context, BadgeModel badge) async {
    final String text = "Great! I earned the '${badge.name}' badge on Göbek Gone: ${badge.description}. Come join this healthy living journey!";
    await Share.share(text, subject: 'Göbek Gone Badge Success');
  }

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
            decoration: const BoxDecoration(
              color: AppColors.main_background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 30),
                Text(
                  badge.iconPath,
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 10),
                Text(
                  badge.name,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    badge.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: () => _shareBadge(context, badge),
                  icon: const Icon(Icons.share, size: 20),
                  label: const Text("Share My Success"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: gobekgAppbar(),
      endDrawer: const UserSideBar(),
      body: BlocBuilder<BadgeBloc, BadgeState>(
        builder: (context, state) {
          if (state is BadgeLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.bottombar_color));
          } else if (state is BadgeError) {
            return Center(child: Text("Error: ${state.error}"));
          } else if (state is BadgeLoaded) {
            final badges = state.badges;
            
            if (badges.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "No badges earned yet. Keep going!",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Text(
                          "Total Earned: ${badges.where((b) => b.isEarned).length}",
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        childAspectRatio: 1.0, 
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: badges.length,
                      itemBuilder: (context, index) {
                        final badge = badges[index];
                        return InkWell(
                          onTap: () => _showBadgeDetail(context, badge),
                          borderRadius: BorderRadius.circular(16),
                          child: BadgeItem(badge: badge, iconEmoji: badge.iconPath),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class BadgeItem extends StatelessWidget {
  final BadgeModel badge;
  final String iconEmoji;

  const BadgeItem({Key? key, required this.badge, required this.iconEmoji}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Now using the actual status from backend
    final bool isCompleted = badge.isEarned; 

    final Color color = isCompleted ? Colors.lightGreen.shade400 : Colors.grey.shade300;
    final Color textColor = isCompleted ? Colors.green.shade900 : Colors.grey.shade600;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isCompleted ? Colors.lightGreen.shade600 : Colors.grey.shade400,
              width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isCompleted ? Colors.green.shade800.withOpacity(0.8) : Colors.black12,
                  child: Text(
                    iconEmoji,
                    style: TextStyle(
                      fontSize: 35,
                      color: isCompleted ? null : Colors.black38
                    ),
                  ),
                ),
                if (!isCompleted)
                  const Icon(Icons.lock, size: 28, color: Colors.black54),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isCompleted ? "Won" : "Locked",
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.8),
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ],
        ),
      ),
    );
  }
}