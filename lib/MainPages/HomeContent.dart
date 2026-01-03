import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/AI.dart';
import 'package:gobek_gone/MainPages/Contents/AddictionCessation.dart';
import 'package:gobek_gone/features/addiction/logic/addiction_bloc.dart';
import 'package:gobek_gone/MainPages/Contents/BMI.dart';
import 'package:gobek_gone/MainPages/Contents/DietList.dart';
import 'package:gobek_gone/features/auth/logic/auth_bloc.dart';
import 'package:intl/intl.dart';

class Homecontent extends StatefulWidget {
  final Function(int) onTabChange;
  const Homecontent({super.key, required this.onTabChange});

  @override
  State<Homecontent> createState() => _HomecontentState();
}

class _HomecontentState extends State<Homecontent> {
  @override
  void initState() {
    super.initState();
    // Load addiction status when home loads
    context.read<AddictionBloc>().add(LoadAddictionStatus());
  }

  @override
  Widget build(BuildContext context) {
    // Get User Name from AuthBloc
    String userName = "User";
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user != null) {
      userName = authState.user!.username.isNotEmpty 
          ? authState.user!.username 
          : authState.user!.fullname.split(' ')[0]; 
    }

    final String dateStr = DateFormat('EEEE, d MMMM', 'tr_TR').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.main_background,
      appBar: gobekgAppbar(),
      endDrawer: const UserSideBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            _buildHeader(userName, dateStr),
            const SizedBox(height: 25),

            // 2. Daily Tip
            _buildDailyTip(),
            const SizedBox(height: 25),

            // 3. Summary Section (BMI & Diet)
            const Text(
              "Your Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    title: "BMI Status",
                    icon: Icons.monitor_weight_outlined,
                    color: Colors.blueAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BMICalculatorPage())),
                    child: const Text("Check Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    title: "Diet Plan",
                    icon: Icons.restaurant_menu,
                    color: AppColors.bottombar_color,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DietList())),
                    child: const Text("View Plan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 4. Addiction Status (New)
            _buildAddictionStatus(context),
            const SizedBox(height: 25),

            // 5. AI Assistant CTA
            _buildAICard(context),

            const SizedBox(height: 25),

            // 6. Quick Actions Grid
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                 _buildActionCard(
                  context, 
                  "Badges", 
                  Icons.emoji_events_outlined, 
                  Colors.amber.shade700,
                  () => widget.onTabChange(1), 
                  isTab: true,
                ),
                _buildActionCard(
                  context, 
                  "Friends", 
                  Icons.people_outline, 
                  Colors.indigo,
                   () => widget.onTabChange(3),
                   isTab: true,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ... (Header and other existing widgets remain mostly same, adding new ones below)

  Widget _buildDailyTip() {
     final tips = [
       "Drink 8 glasses of water today!",
       "Take a 10-minute walk after lunch.",
       "Avoid sugary drinks for better energy.",
       "Sleep at least 7 hours tonight.",
       "Eat more greens for a healthy gut."
     ];
     // Simple random picker based on day of year to keep it constant for the day
     final dayOfYear = int.parse(DateFormat("D").format(DateTime.now()));
     final tip = tips[dayOfYear % tips.length];

     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(15),
         border: Border(left: BorderSide(color: AppColors.title_color, width: 4)),
         boxShadow: [
            BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 3))
         ],
       ),
       child: Row(
         children: [
           Icon(Icons.lightbulb_outline, color: AppColors.title_color, size: 28),
           const SizedBox(width: 15),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text("Daily Tip", style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 4),
                 Text(tip, style: const TextStyle(color: Colors.black87, fontSize: 14)),
               ],
             ),
           )
         ],
       ),
     );
  }

  Widget _buildAddictionStatus(BuildContext context) {
    return BlocBuilder<AddictionBloc, AddictionState>(
      builder: (context, state) {
        if (state is AddictionActive) {
          final counter = state.counters.first; // Assuming mostly one for summary
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddictionCessation())),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                   BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.purple.shade50,
                    child: Icon(Icons.spa, color: Colors.purple, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Addiction Free", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text("${counter.cleanDays} Days Clean", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          );
        } else if (state is AddictionNone) {
           return Container(); // Hide if no addiction tracking, or show simple CTA
        }
        return Container();
      },
    );
  }

  // ... (Keep existing helpers _buildHeader, _buildSummaryCard etc.)

  Widget _buildHeader(String name, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Hello, $name 👋",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Text(
          "Let's make today healthy!",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, {
    required String title, 
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap,
    required Widget child
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 5),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAICard(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIpage())),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.AI_color, AppColors.AI_color.withValues(alpha: 0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(color: AppColors.bottombar_color.withValues(alpha: 0.6), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Talk to AI Assistant",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Ask for diet plans, advice, or motivation.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, {bool isTab = false}) {
     return InkWell(
      onTap: onTap,
       borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
           border: isTab ? Border.all(color: Colors.grey.shade200) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             if (isTab) const Text("(In Tabs)", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}