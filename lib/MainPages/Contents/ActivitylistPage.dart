import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/BottomBar.dart';
import 'package:gobek_gone/General/Fab.dart';
import 'package:gobek_gone/General/Sidebar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/AI.dart';
import 'package:gobek_gone/MainPages/Badges.dart';
import 'package:gobek_gone/MainPages/Friends.dart';
import 'package:gobek_gone/MainPages/Homepage.dart';

class ActivitylistPage extends StatefulWidget {
  @override
  State<ActivitylistPage> createState() => _ActivitylistPageState();
}

class _ActivitylistPageState extends State<ActivitylistPage> {
  bool isHomeSelected = true;
  String selectedMuscleGroup = "Karın";
  bool _isSidebarOpen = false;
  int _selectedIndex = 0;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 4) {
      _toggleSidebar();
      return;
    }

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Homepage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BadgesPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AIpage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => FriendsPage()),
      );
    }
  }

  final List<Map<String, dynamic>> allExercises = [
    {
      "name": "Russian Twist",
      "image": "images/Russian-Twist.png",
      "difficulty": "Orta",
      "reps": "3 set x 12 tekrar",
      "isHome": true,
      "muscleGroup": "Karın",
    },
    {
      "name": "Plank",
      "image": "images/Plank.png",
      "difficulty": "Başlangıç",
      "reps": "30 sn bekleme",
      "isHome": true,
      "muscleGroup": "Karın",
    },
    {
      "name": "Squat",
      "image": "images/Squat.png",
      "difficulty": "Başlangıç",
      "reps": "3 set x 10 tekrar",
      "isHome": true,
      "muscleGroup": "Bacak",
    },
    {
      "name": "Push-up",
      "image": "images/Push-up.png",
      "difficulty": "Orta",
      "reps": "3 set x 8 tekrar",
      "isHome": true,
      "muscleGroup": "Göğüs",
    },
    {
      "name": "Bench Press",
      "image": "images/Benchpress.png",
      "difficulty": "İleri",
      "reps": "4 set x 8 tekrar",
      "isHome": false,
      "muscleGroup": "Göğüs",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Statik yükseklik varsayımları:
    const double customAppBarHeight = 60.0; // gobekgAppbar yüksekliği varsayımı
    const double bottomBarHeight = 56.0;   // gobekgBottombar yüksekliği varsayımı

    // Dinamik yükseklikler:
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double safeBottomPadding = MediaQuery.of(context).padding.bottom;

    final double availableHeight = MediaQuery.of(context).size.height
        - statusBarHeight
        - customAppBarHeight
        - bottomBarHeight
        - safeBottomPadding;

    final filteredExercises = allExercises.where((exercise) {
      final matchesLocation = exercise["isHome"] == isHomeSelected;
      final matchesMuscleGroup =
          selectedMuscleGroup == "Tüm Vücut" ||
              exercise["muscleGroup"] == selectedMuscleGroup;
      return matchesLocation && matchesMuscleGroup;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.main_background,
      body: Stack(
        children: [
          Positioned(
            top: statusBarHeight + customAppBarHeight,
          left: 0,
          right: 0,
          bottom: 0,
            child: Column(
              children: [
                _buildLocationToggle(),
                SizedBox(height: 15),
                _buildMuscleFilterBar(),
                SizedBox(height: 15),
                Expanded(
                  child: filteredExercises.isEmpty
                      ? Center(
                    child: Text(
                      "Bu filtreye uygun egzersiz bulunamadı",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, bottomBarHeight + 20),
                    itemCount: filteredExercises.length,
                    itemBuilder: (_, index) =>
                        ExerciseCard(exercise: filteredExercises[index]),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: gobekgAppbar(),
          ),

          PositionedSidebar(
            isOpened: _isSidebarOpen,
            onClose: _toggleSidebar,
          ),

          if (_isSidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: Container(color: Colors.black54),
            ),
        ],
      ),
      bottomNavigationBar: gobekgBottombar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: buildCenterFloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AIpage()));
        },
        backgroundColor: AppColors.AI_color,
        icon: CupertinoIcons.circle_grid_hex,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildLocationToggle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildToggleButton("Evde 🏡", true),
          _buildToggleButton("Spor Salonunda 🏛️", false),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool home) {
    bool selected = isHomeSelected == home;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => isHomeSelected = home);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.AI_color : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleFilterBar() {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip("Tüm Vücut", Icons.accessibility_new),
          _buildChip("Karın", Icons.self_improvement),
          _buildChip("Bacak", Icons.directions_run),
          _buildChip("Göğüs", Icons.fitness_center),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    bool isSelected = selectedMuscleGroup == label;

    return GestureDetector(
      onTap: () => setState(() => selectedMuscleGroup = label),
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.AI_color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.black54),
            SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                exercise["image"],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise["name"],
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(exercise["difficulty"]),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      exercise["difficulty"],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    exercise["reps"],
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.AI_color,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios,
                  size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case "Başlangıç":
        return Colors.green;
      case "Orta":
        return Colors.orange;
      case "İleri":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
