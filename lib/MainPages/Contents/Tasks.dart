import 'package:flutter/material.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
// Projenizin renklerini içeren dosyayı import edin.
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/General/contentBar.dart';

// Renklerin doğru çalışması için varsayılan AppThemeColors tanımı
class AppThemeColors {
  static const Color main_background = Color(0xFFF0F4F8);
  static const Color primary_color = Color(0xFF4CAF50);
  static const Color icons_color = Color(0xFF388E3C);
}

// Görev Veri Modeli
class DailyTask {
  final String title;
  final String description;
  bool isCompleted;

  DailyTask({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {

  // --- MOCK VERİ ve DURUM YÖNETİMİ (Değişmedi) ---

  late List<DailyTask> _tasks;
  late DateTime _lastResetDate;

  @override
  void initState() {
    super.initState();
    _initializeTasks();
    _checkAndResetTasks();
  }

  void _initializeTasks() {
    _tasks = [
      DailyTask(title: "Drink Water", description: "Consume 15 glasses of water (approx. 3 Liters)"),
      DailyTask(title: "Hit Your Steps Goal", description: "Achieve 10,000 steps today"),
      DailyTask(title: "Daily Exercise", description: "Complete at least 30 minutes of moderate activity"),
      DailyTask(title: "Eat Veggies", description: "Include vegetables in all 3 main meals"),
      DailyTask(title: "Sleep 7 Hours", description: "Ensure 7 hours of undisturbed sleep"),
      DailyTask(title: "Mindfulness/Meditation", description: "Spend 10 minutes meditating or deep breathing"),
      DailyTask(title: "Screen Detox", description: "Avoid screens 1 hour before bedtime"),
    ];
  }

  void _checkAndResetTasks() {
    final DateTime today = DateTime.now();
    final DateTime todayOnly = DateTime(today.year, today.month, today.day);
    _lastResetDate = DateTime(today.year, today.month, today.day - 1);

    if (_lastResetDate.isBefore(todayOnly)) {
      setState(() {
        for (var task in _tasks) {
          task.isCompleted = false;
        }
        _lastResetDate = todayOnly;
      });
    }
  }

  void _toggleTaskCompletion(DailyTask task, bool? newValue) {
    setState(() {
      task.isCompleted = newValue ?? false;
    });
  }

  double _getCompletionPercentage() {
    if (_tasks.isEmpty) return 0.0;
    final completedCount = _tasks.where((t) => t.isCompleted).length;
    return completedCount / _tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final double completionPercent = _getCompletionPercentage();
    final int completedCount = _tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      backgroundColor: AppThemeColors.main_background,
      appBar: contentBar(),
      endDrawer: const UserSideBar(),
      body: Column(
        children: [
          // İlerleme Kartı
          _buildProgressCard(completionPercent, completedCount),

          const SizedBox(height: 10),

          // Görev Listesi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return _buildTaskItem(task);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✨ GÜNCELLENMİŞ GÖREV TAMAMLAMA KARTI (Orijinal yapıya geri dönüldü, boy kısaltıldı)
  Widget _buildProgressCard(double percent, int completed) {
    return Card(
      elevation: 4,
      // ✨ YENİ: Dış marjin (boşluk) orijinaline yakın (ortada kalması için)
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: AppThemeColors.primary_color,
      child: Padding(
        // ✨ YENİ: Dikey Padding (vertical) değeri kısaltıldı (20.0'dan 15.0'a)
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          children: [
            const Text(
              "Today's Progress",
              style: TextStyle(
                fontSize: 18, // Biraz küçültüldü
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10), // Boşluk kısaltıldı
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100, // ✨ YENİ: Çubuğun boyutu 120'den 100'e küçültüldü
                  height: 100, // ✨ YENİ: Çubuğun boyutu 120'den 100'e küçültüldü
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 7, // Çizgi kalınlığı ayarlandı
                    backgroundColor: Colors.white38,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Text(
                  "${(percent * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 28, // Yüzde metni küçültüldü
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Boşluk kısaltıldı
            Text(
              "$completed out of ${_tasks.length} tasks completed!",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tek Görev Öğesi (Değişmedi)
  Widget _buildTaskItem(DailyTask task) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Köşe yuvarlatma
        side: BorderSide(
          color: Colors.green, // Kenarlık rengi
          width: 2,             // Kenarlık kalınlığı
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: task.isCompleted ? AppThemeColors.primary_color : Colors.black87,
            decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          task.description,
          style: TextStyle(
            color: task.isCompleted ? Colors.grey : Colors.black54,
          ),
        ),
        value: task.isCompleted,
        activeColor: AppThemeColors.primary_color,
        onChanged: (newValue) => _toggleTaskCompletion(task, newValue),
        secondary: Icon(
          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.isCompleted ? AppThemeColors.primary_color : Colors.grey,
        ),
      ),
    );
  }
}