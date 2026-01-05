import 'package:flutter/material.dart';
import 'package:gobek_gone/General/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../features/workout/data/models/workout_plan_model.dart';
import '../../features/workout/data/services/workout_service.dart';
import 'package:gobek_gone/MainPages/AI.dart';

class WorkoutPlanPage extends StatefulWidget {
  const WorkoutPlanPage({super.key});

  @override
  State<WorkoutPlanPage> createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage> {
  late WorkoutService _workoutService;
  WorkoutPlan? _plan;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(baseUrl: AppConstants.apiBaseUrl);
    _workoutService = WorkoutService(apiClient: apiClient);
    _fetchPlan();
  }

  Future<void> _fetchPlan() async {
    try {
      final plan = await _workoutService.getUserWorkoutPlan();
      if (mounted) {
        setState(() {
          _plan = plan;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Modern light grey background
      appBar: AppBar(
        title: const Text("My Workout Plan", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.appbar_color,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.bottombar_color))
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Error: $_error", textAlign: TextAlign.center)))
              : _plan == null
                  ? _buildEmptyState()
                  : _buildPlanContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5)
                ],
              ),
              child: const Icon(Icons.fitness_center_outlined, size: 64, color: AppColors.bottombar_color),
            ),
            const SizedBox(height: 32),
            const Text(
              "No Plan Yet?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              "Let our AI fitness expert parse your needs and create a perfect workout routine just for you.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AIpage(initialMessage: "Create a personal workout plan for me")),
                  );
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Create with AI"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bottombar_color,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern Header Card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.bottombar_color, AppColors.bottombar_color.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.bottombar_color.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _plan?.planName ?? "Personalized Plan",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildHeaderTag(_plan?.goal ?? "Fitness", Icons.track_changes),
                  const SizedBox(width: 12),
                  _buildHeaderTag(_plan?.difficulty ?? "General", Icons.bar_chart),
                ],
              ),
            ],
          ),
        ),

        // Tabs & Content
        Expanded(
          child: DefaultTabController(
            length: _plan?.days?.length ?? 0,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  labelColor: AppColors.bottombar_color,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.bottombar_color,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  tabs: _plan!.days!.map((day) => Tab(text: day.dayName)).toList(),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: _plan!.days!.map((day) => _buildDayView(day)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDayView(WorkoutDay day) {
    if (day.exercises == null || day.exercises!.isEmpty) {
      return const Center(child: Text("Rest Day! Enjoy your recovery.", style: TextStyle(color: Colors.grey, fontSize: 16)));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: day.exercises!.length,
      itemBuilder: (context, index) {
        final exerciseData = day.exercises![index];
        final exercise = exerciseData.exercise;

        return GestureDetector(
          onTap: () {
            if (exercise != null) _showDetailDialog(context, exercise);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Hero(
                    tag: "exercise_img_${exercise?.id ?? index}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildExerciseImage(context, exercise?.imageUrl, size: 80),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise?.name ?? "Unknown Exercise",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.bottombar_color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${exerciseData.sets} Sets  •  ${exerciseData.reps} Reps",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.bottombar_color),
                          ),
                        ),
                        if (exerciseData.notes != null && exerciseData.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Row(
                              children: [
                                const Icon(Icons.note_alt_outlined, size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    exerciseData.notes!,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Identical to ActivitylistPage logic for API compatibility
  Widget _buildExerciseImage(BuildContext context, String? imageUrl, {double size = 80, bool isLarge = false}) {
    double width = isLarge ? double.infinity : size;
    double height = size;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: width, height: height,
        color: Colors.grey[200],
        child: Icon(Icons.fitness_center, color: Colors.grey, size: isLarge ? 50 : 24),
      );
    }

    String finalUrl = imageUrl.replaceAll('\\', '/');
    if (finalUrl.startsWith('~')) finalUrl = finalUrl.substring(1);
    
    if (!finalUrl.startsWith('http')) {
       String baseUrl = AppConstants.apiBaseUrl;
       // Remove trailing /api if present to get root valid static file path
       if (baseUrl.endsWith('/api')) {
          baseUrl = baseUrl.substring(0, baseUrl.length - 4);
       } else if (baseUrl.endsWith('/api/')) {
          baseUrl = baseUrl.substring(0, baseUrl.length - 5);
       }
       
       if (!finalUrl.startsWith('/')) finalUrl = '/$finalUrl';
       finalUrl = "$baseUrl$finalUrl";
    }

    return Image.network(
      finalUrl,
      width: width, height: height,
      fit: BoxFit.cover,
      errorBuilder: (_,__,___) => Container(
        width: width, height: height,
        color: Colors.grey[200],
        child: Icon(Icons.broken_image, color: Colors.grey, size: isLarge ? 50 : 24),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, dynamic exercise) {
     if (exercise == null) return;

     showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: _buildExerciseImage(context, exercise.imageUrl, size: 250, isLarge: true),
                  ),
                  Positioned(
                    top: 10, right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(exercise.exerciseLevel),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getDifficultyText(exercise.exerciseLevel),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      exercise.description ?? "No description available.",
                      style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[700]),
                    ),

                    if (exercise.detail != null && exercise.detail!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                       const Text("Instructions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        exercise.detail!,
                        style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[700]),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 0: return Colors.green; // Beginner
      case 1: return Colors.orange; // Intermediate
      case 2: return Colors.red; // Advanced
      default: return Colors.grey;
    }
  }

  String _getDifficultyText(int level) {
     switch (level) {
      case 0: return "Beginner";
      case 1: return "Intermediate";
      case 2: return "Advanced";
      default: return "Unknown";
    }
  }
}
