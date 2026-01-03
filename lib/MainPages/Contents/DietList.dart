import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/General/contentBar.dart';
import 'package:gobek_gone/MainPages/AI.dart';
import 'package:gobek_gone/core/constants/app_constants.dart';
import 'package:gobek_gone/core/network/api_client.dart';
import 'package:gobek_gone/features/diet/data/diet_service.dart';
import 'package:intl/intl.dart';

class DietList extends StatefulWidget {
  final String? initialDietPlan; // Fallback data from Chat
  const DietList({super.key, this.initialDietPlan});

  @override
  State<DietList> createState() => _DietListState();
}

class _DietListState extends State<DietList> {
  DietPlan? _dietPlan;
  bool _isLoading = true;
  late DietService _dietService;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(baseUrl: AppConstants.apiBaseUrl);
    _dietService = DietService(apiClient: apiClient);
    
    // If we have passed data, use it immediately
    if (widget.initialDietPlan != null && widget.initialDietPlan!.isNotEmpty) {
       _dietPlan = DietPlan(
         id: 0, 
         content: widget.initialDietPlan!, 
         createdAt: DateTime.now()
       );
       _isLoading = false;
       // We still try to load from backend in background or just stick with this
    } else {
       _loadDietPlan();
    }
  }

  Future<void> _loadDietPlan() async {
    setState(() => _isLoading = true);
    try {
      final plan = await _dietService.getLatestDietPlan();
      setState(() {
        _dietPlan = plan;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading diet plan: $e");
      setState(() => _isLoading = false);
    }
  }

  // Parses the diet text and adds real dates next to day names based on createdAt
  String _processDietText(String text, DateTime startDate) {
    // English Mapping
    final daysEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    // Turkish Mapping
    final daysTr = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    
    // Normalize text (trim spaces)
    String processedText = text;

    // Determine the Monday of the week the plan was created
    // Assuming the plan starts on the Monday of that week
    // Note: DateTime.weekday gives 1 for Monday, 7 for Sunday.
    int daysFromMonday = startDate.weekday - 1; 
    DateTime weekStart = startDate.subtract(Duration(days: daysFromMonday));
    
    final now = DateTime.now();

    // Helper to replace all occurrences case-insensitively
    String replaceDay(String content, String dayName, int dayIndex) {
      DateTime targetDate = weekStart.add(Duration(days: dayIndex));
      String formattedDate = DateFormat('d MMM', 'tr_TR').format(targetDate);
      
      // Check if this day is TODAY
      bool isToday = (targetDate.year == now.year && targetDate.month == now.month && targetDate.day == now.day);
      
      String replacement;
      if (isToday) {
         replacement = "**$dayName ($formattedDate) - BUGÜN** 🔴"; // Highlight Today
      } else {
         replacement = "**$dayName ($formattedDate)**";
      }

      // Replace "Pazartesi" with replacement
      // Using RegExp to match whole words and be case insensitive
      return content.replaceAllMapped(
        RegExp(r'\b' + RegExp.escape(dayName) + r'\b', caseSensitive: false),
        (match) => replacement
      );
    }

    // Process both English and Turkish day names
    for (int i = 0; i < 7; i++) {
   
     // Only process if the text actually contains the day name to avoid unnecessary regex work
      if (processedText.toLowerCase().contains(daysEn[i].toLowerCase())) {
          processedText = replaceDay(processedText, daysEn[i], i);
      }
      
      if (processedText.toLowerCase().contains(daysTr[i].toLowerCase())) {
          processedText = replaceDay(processedText, daysTr[i], i);
      }
    }
    
    return processedText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,
      appBar: contentBar(),
      endDrawer: const UserSideBar(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.bottombar_color))
        : (_dietPlan == null)
            ? _buildEmptyState()
            : _buildDietView(),
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
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.bottombar_color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_outlined,
                size: 80,
                color: AppColors.bottombar_color,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "No Diet Plan Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "You haven't created a personalized diet plan yet. Let our AI assistant build one tailored just for you!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIpage()),
                ).then((_) => _loadDietPlan()); // Refresh when coming back
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bottombar_color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text(
                "Create with AI Assistant",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietView() {
    final processedContent = _processDietText(_dietPlan!.content, _dietPlan!.createdAt);
    final createDateStr = DateFormat('MMMM d, yyyy').format(_dietPlan!.createdAt);

    return RefreshIndicator(
      onRefresh: _loadDietPlan,
      color: AppColors.bottombar_color,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.bottombar_color, AppColors.bottombar_color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.bottombar_color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weekly Diet Plan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Created on $createDateStr",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Markdown Content Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: MarkdownBody(
                  data: processedContent,
                  styleSheet: MarkdownStyleSheet(
                    h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.bottombar_color),
                    h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF445555)),
                    p: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                    strong: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.bottombar_color),
                    listBullet: const TextStyle(color: AppColors.bottombar_color),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Re-generate Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIpage()),
                ).then((_) => _loadDietPlan());
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Ask AI to Update Plan"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.bottombar_color,
                side: const BorderSide(color: AppColors.bottombar_color),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}