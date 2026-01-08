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
import 'package:gobek_gone/core/network/api_client.dart';
import 'package:gobek_gone/core/constants/app_constants.dart';
import 'package:gobek_gone/features/gamification/data/models/level_progress_response.dart';
import 'package:gobek_gone/features/gamification/data/services/gamification_service.dart';
import 'package:gobek_gone/MainPages/Contents/WorkoutPlanPage.dart';
import 'package:intl/intl.dart';

class Homecontent extends StatefulWidget {
  final Function(int) onTabChange;
  const Homecontent({super.key, required this.onTabChange});

  @override
  State<Homecontent> createState() => _HomecontentState();
}

class _HomecontentState extends State<Homecontent> {
  LevelProgressResponse? _levelData;
  int _waterGlasses = 0;
  final int _waterGoal = 8;
  String _selectedMood = "";
  final List<String> _moods = ["Happy 😃", "Neutral 😐", "Tired 😴", "Sad 😔", "Energetic ⚡"];

  @override
  void initState() {
    super.initState();
    context.read<AddictionBloc>().add(LoadAddictionStatus());
    _fetchLevelProgress();
  }

  Future<void> _fetchLevelProgress() async {
    try {
       final service = GamificationService(ApiClient(baseUrl: AppConstants.apiBaseUrl));
       final data = await service.getLevelProgress();
       if (mounted && data != null) setState(() => _levelData = data);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    String userName = "User";
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user != null) {
      userName = authState.user!.username.isNotEmpty 
          ? authState.user!.username 
          : authState.user!.fullname.split(' ')[0]; 
    }
    final String dateStr = DateFormat('EEEE, d MMMM', 'en_US').format(DateTime.now());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const gobekgAppbar(),
      endDrawer: const UserSideBar(),
      body: Stack(
        children: [
          Container(
            height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.appbar_color, AppColors.bottombar_color],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hello, $userName 👋", style: const TextStyle(color: Color(0xFF557A77), fontSize: 24, fontWeight: FontWeight.bold)), 
                        Text(dateStr, style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              
              if (_levelData != null) Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildGlassLevelBar(),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWeightGoalCard(context),
                       const SizedBox(height: 20),

                       Row(
                         children: [
                           Expanded(child: _buildWaterTracker()),
                           const SizedBox(width: 15),
                           Expanded(
                             child: Column(
                               children: [
                                 _buildSummaryCard(
                                   context, "Diet Plan", Icons.restaurant_menu, Colors.orange, 
                                   () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DietList()))
                                 ),
                                 const SizedBox(height: 15),
                                  _buildSummaryCard(
                                   context, "Workout", Icons.fitness_center, Colors.deepPurple, 
                                   () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutPlanPage()))
                                 ),
                               ],
                             ),
                           ),
                         ],
                       ),

                       const SizedBox(height: 20),

                       _buildMoodSection(),
                       const SizedBox(height: 20),

                       Row(
                         children: [
                           Expanded(child: _buildAddictionStatus(context)),
                           const SizedBox(width: 15),
                           Expanded(
                             child: _buildSummaryCard(
                               context, "BMI", Icons.monitor_weight_outlined, Colors.blue, 
                               () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BMICalculatorPage()))
                             )
                           ),
                         ],
                       ),

                       const SizedBox(height: 20),

                       _buildAICard(context),
                       
                       const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassLevelBar() {
     final d = _levelData!;
     return Container(
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: Colors.white.withValues(alpha: 0.2),
         borderRadius: BorderRadius.circular(15),
         border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
       ),
       child: Column(
         children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Row(
                 children: [
                   const Icon(Icons.star, color: Colors.amber, size: 18),
                   const SizedBox(width: 5),
                   Text("Level ${d.level}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                 ],
               ),
               Text("${d.currentXp}/${d.xpForNextLevel} XP", style: const TextStyle(color: Colors.white, fontSize: 12)),
             ],
           ),
           const SizedBox(height: 8),
           ClipRRect(
             borderRadius: BorderRadius.circular(10),
             child: LinearProgressIndicator(
               value: (d.progressPercentage / 100).clamp(0.0, 1.0),
               backgroundColor: Colors.black.withValues(alpha: 0.2),
               valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
               minHeight: 6,
             ),
           ),
         ],
       ),
     );
  }

  Widget _buildWaterTracker() {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               const Text("Water", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
               Icon(Icons.local_drink, color: Colors.blue.shade400),
             ],
           ),
           Center(
             child: Column(
               children: [
                 Text("$_waterGlasses / $_waterGoal", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                 const Text("glasses", style: TextStyle(fontSize: 12, color: Colors.grey)),
               ],
             ),
           ),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
               _waterBtn(Icons.remove, () => setState(() { if(_waterGlasses>0) _waterGlasses--; })),
               _waterBtn(Icons.add, () => setState(() { if(_waterGlasses<_waterGoal) _waterGlasses++; })),
             ],
           )
         ],
      ),
    );
  }

  Widget _waterBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
           boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87))),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("How are you feeling today?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _moods.map((mood) {
                bool isSelected = _selectedMood == mood;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.title_color : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(mood, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_selectedMood.isNotEmpty) ...[
            const SizedBox(height: 15),
            Text(
              _selectedMood.contains("Happy") ? "Keep shining! 🌟" 
              : _selectedMood.contains("Sad") ? "This too shall pass. 💙"
              : _selectedMood.contains("Tired") ? "Rest is productive too. 💤"
              : "You got this! 💪",
              style: TextStyle(color: AppColors.title_color, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
            )
          ]
        ],
      ),
    );
  }

  void _showSetTargetWeightDialog(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.user == null) return;
    final user = authState.user!;

    final TextEditingController controller = TextEditingController(text: user.targetWeight > 0 ? user.targetWeight.toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Target Weight"),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: "Target Weight (kg)", hintText: "e.g., 70.5"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text.replaceAll(',', '.'));
              if (val != null && val > 0) {
                context.read<AuthBloc>().add(UpdateProfileRequested(
                  fullname: user.fullname,
                  username: user.username,
                  birthDay: user.birthDay,
                  birthMonth: user.birthMonth,
                  birthYear: user.birthYear,
                  height: user.height,
                  weight: user.weight,
                  targetWeight: val, // New Target
                  gender: user.gender,
                  profilePhoto: user.profilePhoto,
                ));
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Widget _buildWeightGoalCard(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    double currentWeight = 0;
    double targetWeight = 0;
    if (authState is AuthAuthenticated && authState.user != null) {
      currentWeight = authState.user!.weight;
      targetWeight = authState.user!.targetWeight; 
    }
    if (currentWeight == 0) return const SizedBox.shrink();

    double diff = currentWeight - targetWeight;
    bool isLoss = diff > 0;
    String statusText = isLoss ? "${diff.toStringAsFixed(1)} kg to lose" : "${(-diff).toStringAsFixed(1)} kg to gain";
    if (diff.abs() < 0.1) statusText = "Goal Reached! 🎉";
    if (targetWeight == 0) statusText = "Tap to set Goal";

    return InkWell(
      onTap: () => _showSetTargetWeightDialog(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 const Text("Weight Goal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                   child: Text(statusText, style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                 )
               ],
             ),
             const SizedBox(height: 20),
             ClipRRect(
               borderRadius: BorderRadius.circular(10),
               child: LinearProgressIndicator(
                 value: targetWeight > 0 ? (targetWeight / currentWeight).clamp(0.0, 1.0) : 0, 
                 backgroundColor: Colors.grey.shade100,
                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.title_color),
                 minHeight: 10,
               ),
             ),
              const SizedBox(height: 10),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text("${currentWeight.toStringAsFixed(1)} kg", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                 Text(targetWeight > 0 ? "${targetWeight.toStringAsFixed(1)} kg" : "Set Target", style: const TextStyle(color: Colors.grey)),
               ],
             )
          ],
        ),
      ),
    );
  }

  Widget _buildAddictionStatus(BuildContext context) {
    return BlocBuilder<AddictionBloc, AddictionState>(
      builder: (context, state) {
        if (state is AddictionActive && state.counters.isNotEmpty) {
          final counter = state.counters.first; 
          return _buildSummaryCard(
              context, "${counter.cleanDays} Days Clean", Icons.spa, Colors.purple, 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddictionCessation()))
          );
        }
        return _buildSummaryCard(
            context, "No addiction info yet", Icons.spa_outlined, Colors.grey, 
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddictionCessation()))
        );
      },
    );
  }

  Widget _buildAICard(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIpage())),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.AI_color, Colors.teal.shade300]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.AI_color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.auto_awesome, color: Colors.white),
             SizedBox(width: 10),
             Text("Chat with AI Assistant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}