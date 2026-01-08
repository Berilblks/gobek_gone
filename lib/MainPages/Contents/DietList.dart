import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/General/contentBar.dart';
import 'package:gobek_gone/MainPages/AI.dart';
import 'package:gobek_gone/core/constants/app_constants.dart';
import 'package:gobek_gone/core/network/api_client.dart';
import 'package:gobek_gone/features/diet/logic/diet_bloc.dart';
import 'package:intl/intl.dart';

class DietList extends StatefulWidget {
  final String? initialDietPlan;
  const DietList({super.key, this.initialDietPlan});

  @override
  State<DietList> createState() => _DietListState();
}

class _DietListState extends State<DietList> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // We keep _dailyPlans and _daysOrder local for UI consistency during tab rebuilds if needed,
  // but ideally they come from Bloc state. 
  // To avoid issues with TabController syncing, we will manage it carefully in Listener.

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    
    // Dispatch events
    context.read<DietBloc>().add(LoadDietPlan(initialDietContent: widget.initialDietPlan));
    context.read<DietBloc>().add(CheckDietStatusEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
         ).then((_) => context.read<DietBloc>().add(const LoadDietPlan(forceRefresh: true)));
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Helper to parse content into meals (View specific logic)
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
      bool isHeader = false;
      String foundHeader = "";
      
      for (var k in mealKeywords) {
         if (trimmed.contains(k) && (trimmed.startsWith('#') || trimmed.startsWith('**') || trimmed.length < 50)) {
            isHeader = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const contentBar(),
      endDrawer: const UserSideBar(),
      body: BlocConsumer<DietBloc, DietState>(
        listener: (context, state) {
           if (state is DietLoaded) {
             // Handle Tab Controller Sync
             if (_tabController.length != state.daysOrder.length && state.daysOrder.isNotEmpty) {
                _tabController.dispose();
                _tabController = TabController(length: state.daysOrder.length, vsync: this);
                
                // Try to select TODAY
                String todayEn = DateFormat('EEEE').format(DateTime.now());
                int index = state.daysOrder.indexOf(todayEn);
                if (index != -1) {
                  _tabController.animateTo(index); 
                }
             }
             
             // Handle Weigh In Dialog
             if (state.weighInRequired) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                   _showWeighInDialog();
                });
             }
           }
        },
        builder: (context, state) {
          if (state is DietLoading) {
             return const Center(child: CircularProgressIndicator(color: AppColors.bottombar_color));
          } else if (state is DietError) {
             return Center(child: Text(state.message));
          } else if (state is DietLoaded) {
             return _buildCalendarViewDiet(state.dailyPlans, state.daysOrder);
          } else if (state is DietEmpty) {
             return _buildEmptyState();
          }
           // Fallback for initial state if no data
          return const Center(child: CircularProgressIndicator(color: AppColors.bottombar_color));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const AIpage()),
           ).then((_) => context.read<DietBloc>().add(const LoadDietPlan(forceRefresh: true)));
        },
        backgroundColor: AppColors.bottombar_color,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text("Update Plan", style: TextStyle(color: Colors.white)),
      ),
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
                ).then((_) => context.read<DietBloc>().add(const LoadDietPlan(forceRefresh: true)));
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

  Widget _buildCalendarViewDiet(Map<String, String> dailyPlans, List<String> daysOrder) {
     if (daysOrder.isEmpty) {
        return const Center(child: Text("Could not parse diet plan format."));
     }

     return Column(
       children: [
         // Tab Bar Section (Moved from AppBar to Body)
         if (daysOrder.length > 1)
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
               tabs: daysOrder.map((day) => Tab(text: day)).toList(),
               padding: const EdgeInsets.symmetric(horizontal: 10),
               tabAlignment: TabAlignment.start,
               dividerColor: Colors.transparent, // Remove default divider
             ),
           ),
         
         // Content Section
         Expanded(
           child: TabBarView(
             controller: _tabController,
             children: daysOrder.map((day) {
               final rawContent = dailyPlans[day] ?? "";
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
                                h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.bottombar_color),
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