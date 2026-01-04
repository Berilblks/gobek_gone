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
  final String? initialDietPlan;
  const DietList({super.key, this.initialDietPlan});

  @override
  State<DietList> createState() => _DietListState();
}

class _DietListState extends State<DietList> with SingleTickerProviderStateMixin {
  DietPlan? _dietPlan;
  bool _isLoading = true;
  late DietService _dietService;
  
  // Day parsing logic
  Map<String, String> _dailyPlans = {};
  List<String> _daysOrder = [];
  String _selectedDay = "";
  late TabController _tabController;
  // Fallback controller if no days found
  bool _hasParsedDays = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);

    final apiClient = ApiClient(baseUrl: AppConstants.apiBaseUrl);
    _dietService = DietService(apiClient: apiClient);
    
    // Check for weekly status in background
    _checkWeeklyStatus();
    
    if (widget.initialDietPlan != null && widget.initialDietPlan!.isNotEmpty) {
       _dietPlan = DietPlan(
         id: 0, 
         content: widget.initialDietPlan!, 
         createdAt: DateTime.now()
       );
       _parseDietContent(_dietPlan!.content);
       _isLoading = false;
       _loadDietPlan(background: true);
    } else {
       _loadDietPlan();
    }
  }

  Future<void> _loadDietPlan({bool background = false}) async {
    if (!background) {
      if (mounted) setState(() => _isLoading = true);
    }

    try {
      final plan = await _dietService.getLatestDietPlan();
      if (mounted) {
        setState(() {
          _dietPlan = plan;
          if (_dietPlan != null) {
            _parseDietContent(_dietPlan!.content);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint("Error loading diet plan: $e");
    }
  }
  
  Future<void> _checkWeeklyStatus() async {
    // Wait a bit for UI to settle
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final status = await _dietService.checkDietStatus();
    if (status != null && status.status == "WeighInRequired") {
       _showWeighInDialog();
    }
  }

  void _showWeighInDialog() {
    final TextEditingController _weightController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("🎉 One Week Completed!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("You are doing great! Before creating your new weekly plan, we need your current weight."),
            const SizedBox(height: 20),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Current Weight (kg)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixText: "kg"
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () async {
               if (_weightController.text.isNotEmpty) {
                  final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
                  if (weight != null) {
                     Navigator.pop(context); // Close dialog
                     await _handleWeighIn(weight);
                  }
               }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.bottombar_color, foregroundColor: Colors.white),
            child: const Text("Save & Update"),
          )
        ],
      ),
    );
  }

  Future<void> _handleWeighIn(double weight) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saving weight...")));
    
    try {
      // 1. Update Weight
      final apiClient = ApiClient(baseUrl: AppConstants.apiBaseUrl);
      await apiClient.dio.post('/Auth/UpdateWeight', data: {'weight': weight});

      // 2. Navigate to AI
      if (mounted) {
         Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => AIpage(
             initialMessage: "I am now $weight kg. Based on my performance last week and my new weight, can you create a new diet list for this week?",
           )),
         ).then((_) => _loadDietPlan());
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _parseDietContent(String content) {
    // Basic parser to split content by day headers
    // Supports English day names
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    // Normalize newlines
    String normalized = content.replaceAll('\r\n', '\n');
    
    // Split by lines to find headers
    List<String> lines = normalized.split('\n');
    Map<String, List<String>> chunks = {};
    String currentDay = "General";
    chunks[currentDay] = [];

    // Regex to match lines that strongly look like day headers (e.g. "**Pazartesi**", "# Salı")
    for (String line in lines) {
      String trimmed = line.trim();
      
      bool isHeader = false;
      String foundDay = "";
      
      for (String d in days) {
        if (trimmed.toLowerCase().contains(d.toLowerCase())) {
          // Check if the line is SHORT (likely a header) or bolded or header
          if (trimmed.length < 30 || trimmed.startsWith('**') || trimmed.startsWith('#')) {
             isHeader = true;
             foundDay = d;
             break;
          }
        }
      }

      if (isHeader) {
        // Normalize day name to Title Case
        String normalizedDay = foundDay[0].toUpperCase() + foundDay.substring(1).toLowerCase();
        currentDay = normalizedDay;

        if (!chunks.containsKey(currentDay)) {
          chunks[currentDay] = [];
        }
      } else {
        chunks[currentDay]?.add(line);
      }
    }
    
    // Cleanup chunks
    Map<String, String> result = {};
    List<String> order = [];
    
    // Standard Sort Order
    final sortOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday', 'General'];
    
    chunks.forEach((key, value) {
       String body = value.join('\n').trim();
       if (key != "General" || body.length > 20) { 
         result[key] = body;
       }
    });

    // Populate order list based on sortOrder
    for (var d in sortOrder) {
      if (result.containsKey(d)) order.add(d);
    }
    // Add any others not in sort order (unexpected headers)
    result.keys.forEach((k) {
      if (!sortOrder.contains(k) && !order.contains(k)) order.add(k);
    });

    if (_tabController.length != order.length && order.isNotEmpty) {
       _tabController.dispose();
       _tabController = TabController(length: order.length, vsync: this);
    }
    
    _dailyPlans = result;
    _daysOrder = order;
    _hasParsedDays = _daysOrder.isNotEmpty;

    if (_hasParsedDays) {
      // Try to select TODAY
      String todayEn = DateFormat('EEEE').format(DateTime.now());
      int index = _daysOrder.indexOf(todayEn);
      if (index != -1) {
        _selectedDay = todayEn;
        _tabController.animateTo(index); // Animate to today
      } else {
        _selectedDay = _daysOrder.first;
        _tabController.animateTo(0);
      }
    } else {
      _tabController.dispose();
      _tabController = TabController(length: 1, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,
      appBar: const contentBar(),
      endDrawer: const UserSideBar(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.bottombar_color))
        : (_dietPlan == null)
            ? _buildEmptyState()
            : _buildCalendarViewDiet(),
      floatingActionButton: _dietPlan != null ? FloatingActionButton.extended(
        onPressed: () {
           Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const AIpage()),
           ).then((_) => _loadDietPlan());
        },
        backgroundColor: AppColors.bottombar_color,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text("Update Plan", style: TextStyle(color: Colors.white)),
      ) : null,
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
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))
                ]
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
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
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Your AI assistant is ready to create a personalized diet program for you. Let's reach your goals together!",
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
                ).then((_) => _loadDietPlan());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bottombar_color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: AppColors.bottombar_color.withOpacity(0.4),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text(
                "Create Plan with AI",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to parse content into meals
  List<Map<String, String>> _parseMeals(String content) {
    List<Map<String, String>> meals = [];
    final lines = content.split('\n');
    
    String currentMeal = "";
    List<String> currentBuffer = [];

    // Keywords for meal headers logic
    final mealKeywords = ['breakfast', 'lunch', 'dinner', 'snack', 'morning', 'noon', 'evening'];
    
    void pushCurrent() {
      if (currentMeal.isNotEmpty && currentBuffer.isNotEmpty) {
        String body = currentBuffer.join('\n').trim();
        if (body.isNotEmpty) {
           meals.add({'title': currentMeal, 'content': body});
        }
      }
    }

    for (String line in lines) {
      String trimmed = line.trim().toLowerCase();
      // Check for headers like "**Kahvaltı**" or "### Öğle"
      bool isHeader = false;
      String foundHeader = "";
      
      // Simple verify if line starts with header markdown and contains a meal name
      for (var k in mealKeywords) {
         if (trimmed.contains(k) && (trimmed.startsWith('#') || trimmed.startsWith('**') || trimmed.length < 50)) {
            // Further refinement: exclude "This is your breakfast plan" sentences by length check above
            // and assume headers are reasonably short
            isHeader = true;
            // Extract nice title from line
            foundHeader = line.replaceAll(RegExp(r'[#*:]'), '').trim();
            break;
         }
      }

      if (isHeader) {
        pushCurrent();
        currentMeal = foundHeader;
        currentBuffer = [];
      } else {
        if (currentMeal.isNotEmpty) {
           currentBuffer.add(line);
        } else {
           // If we have content before any header, maybe add to "Not"
           if (line.trim().isNotEmpty) {
              if (currentBuffer.isEmpty) currentMeal = "General"; 
              currentBuffer.add(line);
           }
        }
      }
    }
    pushCurrent();
    return meals;
  }

  Widget _buildCalendarViewDiet() {
     if (!_hasParsedDays) {
        return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
             child: Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                   padding: const EdgeInsets.all(20),
                   child: MarkdownBody(data: _dietPlan!.content),
                )
             ),
          );
     }

     return Column(
       children: [
         // Tab Bar Section (Moved from AppBar to Body)
         if (_daysOrder.length > 1)
           Container(
             color: AppColors.bottombar_color,
             width: double.infinity,
             padding: const EdgeInsets.symmetric(vertical: 8),
             child: TabBar(
               controller: _tabController,
               isScrollable: true,
               indicatorColor: Colors.white,
               indicatorWeight: 4,
               labelColor: Colors.white,
               unselectedLabelColor: Colors.white60,
               labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
               tabs: _daysOrder.map((day) => Tab(text: day)).toList(),
               padding: const EdgeInsets.symmetric(horizontal: 10),
               tabAlignment: TabAlignment.start,
               dividerColor: Colors.transparent, // Remove default divider
             ),
           ),
         
         // Content Section
         Expanded(
           child: TabBarView(
             controller: _tabController,
             children: _daysOrder.map((day) {
               final rawContent = _dailyPlans[day] ?? "";
               if (rawContent.isEmpty) {
                 return const Center(child: Text("No data found for this day."));
               }
               
               // Try to parse meals
               final meals = _parseMeals(rawContent);
               
               // Use Table View if meals found, otherwise fallback Markdown
               if (meals.length >= 3) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...meals.map((m) => Container(
                         margin: const EdgeInsets.only(bottom: 12),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(16),
                           boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0,4))]
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             // Header
                             Container(
                               width: double.infinity,
                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                               decoration: BoxDecoration(
                                 color: AppColors.bottombar_color.withOpacity(0.05),
                                 borderRadius: const BorderRadius.vertical(top: Radius.circular(16))
                               ),
                               child: Text(
                                 m['title'] ?? "",
                                 style: const TextStyle(
                                   color: AppColors.bottombar_color,
                                   fontWeight: FontWeight.bold,
                                   fontSize: 16
                                 ),
                               ),
                             ),
                             // Body
                             Padding(
                               padding: const EdgeInsets.all(16),
                               child: MarkdownBody(
                                  data: m['content']!,
                                  styleSheet: MarkdownStyleSheet(
                                    p: const TextStyle(fontSize: 15, color: Color(0xFF455A64), height: 1.5),
                                    strong: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                               ),
                             )
                           ],
                         ),
                      )).toList(),
                      const SizedBox(height: 80),
                    ],
                  );
               }

               return SingleChildScrollView(
                 padding: const EdgeInsets.all(16),
                 child: Column(
                   children: [
                       Card(
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: MarkdownBody(
                              data: rawContent,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                h1: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.bottombar_color),
                                h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF455A64)),
                                p: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF37474F)),
                                strong: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.bottombar_color),
                                listBullet: const TextStyle(color: AppColors.AI_color, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                          ),
                        ),
                       ),
                     const SizedBox(height: 80),
                   ],
                 ),
               );
             }).toList(),
           ),
         ),
       ],
     );
  }
}