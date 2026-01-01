import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/contentBar.dart';
import 'package:gobek_gone/features/tasks/logic/tasks_bloc.dart';

import '../../features/tasks/data/models/dailytask_response.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {

  @override
  void initState() {
    super.initState();
    // Fetch today's tasks from backend
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
      backgroundColor: AppThemeColors.main_background,
      appBar: contentBar(),
      endDrawer: const UserSideBar(),
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

            return Column(
              children: [
                // İlerleme Kartı
                _buildProgressCard(completionPercent, completedCount, tasks.length),

                const SizedBox(height: 10),

                // Görev Listesi
                if (tasks.isEmpty)
                  const Expanded(child: Center(child: Text("No tasks for today!")))
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                         context.read<TasksBloc>().add(LoadTodayTasksRequested());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _buildTaskItem(task);
                        },
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProgressCard(double percent, int completed, int total) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppThemeColors.primary_color, AppThemeColors.primary_color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppThemeColors.primary_color.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Goals",
                    style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${(percent * 100).toInt()}% Done",
                    style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  percent == 1.0 ? Icons.emoji_events : Icons.trending_up,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$completed of $total tasks completed",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ✨ PREMIUM TASK ITEM
  Widget _buildTaskItem(DailyTaskResponse task) {
    bool isDone = task.isCompleted;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _toggleTaskCompletion(task, !isDone),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Custom Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppThemeColors.primary_color : Colors.transparent,
                    border: Border.all(
                      color: isDone ? AppThemeColors.primary_color : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 20),
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDone ? Colors.grey : Colors.black87,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          decorationColor: AppThemeColors.primary_color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}