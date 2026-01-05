import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/General/contentBar.dart';
import 'package:gobek_gone/core/constants/app_constants.dart';
import 'package:gobek_gone/core/network/api_client.dart';
import 'package:gobek_gone/features/exercise/data/models/exercise_model.dart';
import 'package:gobek_gone/features/exercise/data/services/exercise_service.dart';

class ActivitylistPage extends StatefulWidget {
  @override
  State<ActivitylistPage> createState() => _ActivitylistPageState();
}

class _ActivitylistPageState extends State<ActivitylistPage> {

  bool isHomeSelected = true;
  String selectedMuscleGroup = "All Body"; // Default to All
  String selectedLevel = "All Levels"; // Default
  bool _isSidebarOpen = false;
  
  late ExerciseService _exerciseService;
  List<Exercise> _exercises = [];
  bool _isLoading = true;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(baseUrl: AppConstants.apiBaseUrl);
    _exerciseService = ExerciseService(apiClient: apiClient);
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    setState(() => _isLoading = true);
    
    // Map muscle group
    int? bodyPart;
    switch (selectedMuscleGroup) {
      case "Abs": bodyPart = 2; break;
      case "Legs": bodyPart = 3; break;
      case "Chest": bodyPart = 1; break;
      case "Back": bodyPart = 0; break;
      case "Shoulders": bodyPart = 4; break;
    }
    
    // Map level
    int? level;
    switch (selectedLevel) {
      case "Beginner": level = 0; break;
      case "Intermediate": level = 1; break;
      case "Advanced": level = 2; break;
    }

    try {
      final fetched = await _exerciseService.getExercises(
         isHome: isHomeSelected,
         bodyPart: bodyPart,
         exerciseLevel: level
      );
      
      // Client-side filtering safeguard
      // Ensures that if API returns mixed data, we strictly show what was requested.
      final filtered = fetched.where((e) {
         if (isHomeSelected) {
           return e.isHome == true;
         } else {
           // For Gym, we assume exercises that are NOT for home (require equipment)
           return e.isHome == false;
         }
      }).toList();

      if (mounted) {
        setState(() {
          _exercises = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
         setState(() {
           _exercises = [];
           _isLoading = false;
         });
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading exercises: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Statik yükseklik varsayımları:
    const double customAppBarHeight = 60.0; 
    const double bottomBarHeight = 56.0;   

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.main_background,
      endDrawer: const UserSideBar(),
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
                const SizedBox(height: 10),
                _buildMuscleFilterBar(),
                const SizedBox(height: 8),
                _buildLevelFilterBar(),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.bottombar_color))
                    : _exercises.isEmpty
                      ? Center(
                          child: Text(
                            "No exercises matching this filter were found.",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomBarHeight + 20),
                          itemCount: _exercises.length,
                          itemBuilder: (_, index) =>
                              ExerciseCard(exercise: _exercises[index]),
                        ),
                ),
              ],
            ),
          ),
          
          // ... (Rest of Positioned widgets)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: contentBar(),
          ),

          if (_isSidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: Container(color: Colors.black54),
            ),
        ],
      ),
    );
  }

  // ... (Location Toggle logic remains same)

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
          _buildToggleButton("Home 🏡", true),
          _buildToggleButton("Gym 🏛️", false),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool home) {
    bool selected = isHomeSelected == home;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isHomeSelected != home) {
             setState(() => isHomeSelected = home);
             _fetchExercises();
          }
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
          _buildChip("All Body", Icons.accessibility_new, selectedMuscleGroup, (val) {
             if (selectedMuscleGroup != val) {
               setState(() => selectedMuscleGroup = val);
               _fetchExercises();
             }
          }),
          _buildChip("Abs", Icons.self_improvement, selectedMuscleGroup, (val) {
             setState(() => selectedMuscleGroup = val); _fetchExercises();
          }),
          _buildChip("Legs", Icons.directions_run, selectedMuscleGroup, (val) {
             setState(() => selectedMuscleGroup = val); _fetchExercises();
          }),
          _buildChip("Chest", Icons.fitness_center, selectedMuscleGroup, (val) {
             setState(() => selectedMuscleGroup = val); _fetchExercises();
          }),
          _buildChip("Back", Icons.accessibility, selectedMuscleGroup, (val) {
             setState(() => selectedMuscleGroup = val); _fetchExercises();
          }),
          _buildChip("Shoulders", Icons.sports_gymnastics, selectedMuscleGroup, (val) {
             setState(() => selectedMuscleGroup = val); _fetchExercises();
          }),
        ],
      ),
    );
  }


  Widget _buildLevelFilterBar() {
    return Container(
      height: 35,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip("All Levels", Icons.filter_list, selectedLevel, (val) {
             if (selectedLevel != val) { setState(() => selectedLevel = val); _fetchExercises(); }
          }),
          _buildChip("Beginner", Icons.start, selectedLevel, (val) {
             setState(() => selectedLevel = val); _fetchExercises();
          }),
          _buildChip("Intermediate", Icons.trending_up, selectedLevel, (val) {
             setState(() => selectedLevel = val); _fetchExercises();
          }),
          _buildChip("Advanced", Icons.bolt, selectedLevel, (val) {
             setState(() => selectedLevel = val); _fetchExercises();
          }),
        ],
      ),
    );
  }


  Widget _buildChip(String label, IconData icon, String currentSelection, Function(String) onSelect) {
    bool isSelected = currentSelection == label;

    return GestureDetector(
      onTap: () => onSelect(label),
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.AI_color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.black54),
            SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetailDialog(context),
      child: Card(
        margin: EdgeInsets.only(bottom: 15),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildExerciseImage(context, exercise.imageUrl),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name,
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(exercise.exerciseLevel),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _getDifficultyText(exercise.exerciseLevel),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      exercise.description.length > 50 ? exercise.description.substring(0, 50) + "..." : exercise.description,
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
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Large Image Header
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: _buildExerciseImage(context, exercise.imageUrl, isLarge: true),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(exercise.exerciseLevel),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getDifficultyText(exercise.exerciseLevel),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Body Part
                    Row(
                      children: [
                         const Icon(Icons.accessibility_new, color: AppColors.AI_color),
                         const SizedBox(width: 8),
                         Text(
                           _getBodyPartText(exercise.bodyPart),
                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                         )
                      ],
                    ),
                    const Divider(height: 30),

                    // Description
                    const Text(
                      "Description",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exercise.description,
                      style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF455A64)),
                    ),
                    
                    if (exercise.detail.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        "Details / Instructions",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.detail,
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF455A64)),
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

  String _getBodyPartText(int part) {
    switch (part) {
      case 0: return "Back";
      case 1: return "Chest";
      case 2: return "Abs";
      case 3: return "Legs";
      case 4: return "Shoulders";
      default: return "Full Body";
    }
  }

  Widget _buildExerciseImage(BuildContext context, String? imageUrl, {bool isLarge = false}) {
    double size = isLarge ? 250 : 80;
    double width = isLarge ? double.infinity : 80;
    
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: width,
        height: size,
        color: Colors.grey[200],
        child: Icon(Icons.image_not_supported, color: Colors.grey, size: isLarge ? 50 : 24),
      );
    }

    String finalUrl = imageUrl;
    
    // 1. Uniform Slashes
    finalUrl = finalUrl.replaceAll('\\', '/');
    
    if (finalUrl.startsWith('~')) {
      finalUrl = finalUrl.substring(1); 
    }

    if (!finalUrl.startsWith('http')) {
        String baseUrl = AppConstants.apiBaseUrl;
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
      width: width,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint("Failed to load image: $finalUrl");
        return Container(
          width: width, 
          height: size, 
          color: Colors.grey[300], 
          child: Icon(Icons.broken_image, color: Colors.grey, size: isLarge ? 50 : 24)
        );
      },
    );
  }


  Color _getDifficultyColor(int level) {
    switch (level) {
      case 0:
        return Colors.green; // Beginner
      case 1:
        return Colors.orange; // Intermediate
      case 2:
        return Colors.red; // Advanced
      default:
        return Colors.grey;
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
