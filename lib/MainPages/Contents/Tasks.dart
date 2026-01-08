import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/features/tasks/logic/tasks_bloc.dart';
import 'package:gobek_gone/features/tasks/data/models/dailytask_response.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {

  @override
  void initState() {
    super.initState();
    context.read<TasksBloc>().add(LoadTodayTasksRequested());
  }

  void _toggleTaskCompletion(DailyTaskResponse task, bool? newValue) {
    if (newValue == null) return;
    context.read<TasksBloc>().add(ToggleTaskCompletionRequested(
      taskId: task.id, 
      isCompleted: newValue
    ));
  }

  double _getCompletionPercentage(List<DailyTaskResponse> tasks) {
    if (tasks.isEmpty) return 0.0;
    final completedCount = tasks.where((t) => t.isCompleted).length;
    return completedCount / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is TasksLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is TasksFailure) {
            return Center(child: Text("Error: ${state.error}", style: const TextStyle(color: Colors.red)));
          }

          if (state is TasksLoaded) {
            final tasks = state.tasks;
            final double completionPercent = _getCompletionPercentage(tasks);
            final int completedCount = tasks.where((t) => t.isCompleted).length;

            return CustomScrollView(
              slivers: [
                // --- VIBRANT APP BAR (MATCHING USER PAGE STYLE) ---
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: AppColors.appbar_color,
                  elevation: 0,
                  toolbarHeight: 60,
                  centerTitle: true,
                  title: const Text(
                    "Daily Goals",
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // --- HERO CARD (CIRCULAR PROGRESS) ---
                SliverToBoxAdapter(
                  child: _buildVibrantProgressCard(completionPercent, completedCount, tasks.length),
                ),

                // --- TASK LIST HEADER ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your Mission",
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.w800, 
                            color: Colors.blueGrey.shade800
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade100.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text(
                            "$completedCount/${tasks.length} Done",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade600, fontSize: 12),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                // --- TASK LIST ---
                if (tasks.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.bedtime, size: 60, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("No tasks today, take a break!", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = tasks[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: _buildVibrantTaskItem(task),
                        );
                      },
                      childCount: tasks.length,
                    ),
                  ),
                  
                const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildVibrantProgressCard(double percent, int completed, int total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)], // Deep vibrant green
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Decor
          Positioned(
            right: -20, top: -20,
            child: Icon(Icons.fitness_center, size: 150, color: Colors.white.withOpacity(0.05)),
          ),
          
          Row(
            children: [
              // Circular Progress
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.2)),
                    ),
                    CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Center(
                      child: Text(
                        "${(percent * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 25),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Keep pushing!".toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                     Text(
                      percent == 1 ? "All Done! 🎉" : "You're doing great!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                     const SizedBox(height: 8),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.2),
                         borderRadius: BorderRadius.circular(8)
                       ),
                       child:  Text(
                        "$completed completed",
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                     )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVibrantTaskItem(DailyTaskResponse task) {
    bool isDone = task.isCompleted;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleTaskCompletion(task, !isDone),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Color Strip on the left
                  Container(
                    width: 6,
                    color: isDone 
                        ? Colors.grey.shade300 
                        : AppThemeColors.primary_color,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: isDone 
                                        ? Colors.grey.shade400 
                                        : Colors.blueGrey.shade900,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    decorationColor: AppThemeColors.primary_color,
                                  ),
                                ),
                                if (task.description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    task.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDone 
                                          ? Colors.grey.shade300 
                                          : Colors.blueGrey.shade400,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          // Big Bold Animated Checkbox
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.elasticOut,
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDone 
                                  ? AppThemeColors.primary_color 
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDone 
                                    ? AppThemeColors.primary_color 
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: isDone 
                                ? [BoxShadow(color: AppThemeColors.primary_color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0,2))]
                                : null,
                            ),
                            child: isDone
                                ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
