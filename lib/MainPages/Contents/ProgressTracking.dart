import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';

import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/General/contentBar.dart';

// Service & Model
import 'package:gobek_gone/core/network/api_client.dart';
import 'package:gobek_gone/core/constants/app_constants.dart';
import '../../features/progress/data/models/progress_overview_response.dart';
import '../../features/progress/data/services/progress_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart'; 
import '../../features/auth/logic/auth_bloc.dart'; // Add AuthBloc
import 'package:flutter_bloc/flutter_bloc.dart'; // Add flutter_bloc

class ProgressTracking extends StatefulWidget {
  const ProgressTracking({Key? key}) : super(key: key);

  @override
  State<ProgressTracking> createState() => _ProgressTrackingState();
}

class _ProgressTrackingState extends State<ProgressTracking> {
  bool _isLoading = true;
  ProgressOverviewResponse? _data;
  late ProgressService _progressService;
  late AuthRepository _authRepository; // Add AuthRepo

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(baseUrl: AppConstants.apiBaseUrl);
    _progressService = ProgressService(apiClient);
    _authRepository = AuthRepository(apiClient: apiClient); // Init AuthRepo
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    setState(() => _isLoading = true);
    try {
      final result = await _progressService.getProgressOverview();
      if (mounted) {
        setState(() {
          _data = result;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,
      appBar: contentBar(),
      endDrawer: const UserSideBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? _buildErrorState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Özet Kartı (Kilo Hedefi)
                      _buildSummaryCard(),
                      const SizedBox(height: 20),

                      // 2. Grafik Kartı
                      _buildChartCard(),
                      const SizedBox(height: 20),

                      // 3. Alt Kartlar (BMI & Streak)
                      Row(
                        children: [
                          Expanded(child: _buildBmiCard()),
                          const SizedBox(width: 15),
                          Expanded(child: _buildStreakCard()),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWeightDialog,
        backgroundColor: AppColors.title_color,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Log Weight", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _showAddWeightDialog() async {
    final TextEditingController _weightController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Log Today's Weight"),
          content: TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: "e.g. 75.5",
              suffixText: "kg",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.title_color, foregroundColor: Colors.white),
              onPressed: () async {
                final val = double.tryParse(_weightController.text.replaceAll(',', '.'));
                if (val != null && val > 0) {
                  Navigator.pop(context); // Close dialog
                  await _updateWeight(val);
                }
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  Future<void> _updateWeight(double weight) async {
    setState(() => _isLoading = true);
    try {
      await _authRepository.updateUserWeight(weight);
      
      // Sync global user state (Profile, Home, etc.)
      if (mounted) context.read<AuthBloc>().add(LoadUserRequested());

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Weight updated successfully!")));
      await _fetchProgress(); // Refresh local chart
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isLoading = false);
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          const Text("Could not load progress data.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchProgress,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.AI_color, foregroundColor: Colors.white),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  // --- 1. SUMMARY CARD ---
  Widget _buildSummaryCard() {
    final d = _data!;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text("Current Weight", style: TextStyle(fontSize: 14, color: Colors.grey)),
                     Text(
                       "${d.currentWeight} kg",
                       style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.title_color),
                     ),
                   ],
                 ),
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                     Text("Goal: ${d.targetWeight.toStringAsFixed(1)} kg", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                     const SizedBox(height: 4),
                     Text("Left: ${d.remainingWeight.toStringAsFixed(1)} kg", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                   ],
                 )
               ],
             ),
             const SizedBox(height: 20),
             // Visual Comparison (Bar Chart)
             SizedBox(
               height: 180,
               child: BarChart(
                 BarChartData(
                   alignment: BarChartAlignment.spaceAround,
                   maxY: [d.startWeight, d.currentWeight, d.targetWeight].reduce((a, b) => a > b ? a : b) + 10,
                   barTouchData: BarTouchData(
                     enabled: false,
                     touchTooltipData: BarTouchTooltipData(
                       tooltipBgColor: Colors.transparent, // Fix for fl_chart 0.65.0
                       tooltipPadding: EdgeInsets.zero,
                       tooltipMargin: 8,
                       getTooltipItem: (group, groupIndex, rod, rodIndex) {
                         return BarTooltipItem(
                           rod.toY.toStringAsFixed(1),
                           const TextStyle(
                             color: AppColors.title_color, 
                             fontWeight: FontWeight.bold,
                           ),
                         );
                       },
                     ),
                   ),
                   titlesData: FlTitlesData(
                     show: true,
                     bottomTitles: AxisTitles(
                       sideTitles: SideTitles(
                         showTitles: true,
                         getTitlesWidget: (double value, TitleMeta meta) {
                           const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                           Widget text;
                           switch (value.toInt()) {
                             case 0: text = const Text('Start', style: style); break;
                             case 1: text = const Text('Current', style: style); break;
                             case 2: text = const Text('Goal', style: style); break;
                             default: text = const Text('', style: style);
                           }
                           return SideTitleWidget(axisSide: meta.axisSide, child: text);
                         },
                         reservedSize: 20,
                       ),
                     ),
                     leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                   ),
                   borderData: FlBorderData(show: false),
                   gridData: FlGridData(show: false),
                   barGroups: [
                     BarChartGroupData(
                       x: 0,
                       barRods: [
                         BarChartRodData(
                            toY: d.startWeight, 
                            color: Colors.grey.shade400, 
                            width: 20, 
                            borderRadius: BorderRadius.circular(4),
                            backDrawRodData: BackgroundBarChartRodData(show: true, toY: d.startWeight + 10, color: Colors.grey.shade100),
                         )
                       ],
                       showingTooltipIndicators: [0],
                     ),
                     BarChartGroupData(
                       x: 1,
                       barRods: [
                         BarChartRodData(
                            toY: d.currentWeight, 
                            color: AppColors.title_color, 
                            width: 20, 
                            borderRadius: BorderRadius.circular(4),
                            backDrawRodData: BackgroundBarChartRodData(show: true, toY: d.startWeight + 10, color: Colors.grey.shade100),
                         )
                       ],
                       showingTooltipIndicators: [0],
                     ),
                     BarChartGroupData(
                       x: 2,
                       barRods: [
                         BarChartRodData(
                            toY: d.targetWeight, 
                            color: Colors.greenAccent.shade700, 
                            width: 20, 
                            borderRadius: BorderRadius.circular(4),
                            backDrawRodData: BackgroundBarChartRodData(show: true, toY: d.startWeight + 10, color: Colors.grey.shade100),
                         )
                       ],
                       showingTooltipIndicators: [0],
                     ),
                   ],
                 ),
               ),
             ),
             
             const SizedBox(height: 10),
             const SizedBox(height: 10),
             Text(
               "You've lost ${d.weightLost.toStringAsFixed(1)} kg so far!",
               style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
             )
          ],
        ),
      ),
    );
  }

  // --- 2. CHART CARD ---
  Widget _buildChartCard() {
    final history = _data!.history;
    print("CHART DATA HISTORY: ${history.map((e) => e.weight).toList()}"); // DEBUG
    if (history.isEmpty) {
       return const Card(
         child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No data available yet."))),
       );
    }

    // Prepare spots
    // We map index to X value, and show Date on Bottom Title
    List<FlSpot> spots = [];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].weight));
    }

    double minWeight = history.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    double maxWeight = history.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    
    // Add buffer
    minWeight -= 1;
    maxWeight += 1;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Weekly Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (history.length > 5) ? (history.length / 4).floorToDouble() : 1, // Avoid crowding
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < history.length) {
                            // Show Month/Day e.g. "12 Oct"
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('d MMM').format(history[index].date),
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: minWeight,
                  maxY: maxWeight,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.title_color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.title_color.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. BMI CARD ---
  Widget _buildBmiCard() {
    final d = _data!;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("BMI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 10),
            Text(
              d.currentBmi.toStringAsFixed(1),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.icons_color),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getBmiColor(d.bmiStatus).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                d.bmiStatus,
                style: TextStyle(color: _getBmiColor(d.bmiStatus), fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getBmiColor(String status) {
    if (status.contains("Normal")) return Colors.green;
    if (status.contains("Overweight")) return Colors.orange;
    if (status.contains("Obese")) return Colors.red;
    return Colors.blue;
  }

  // --- 4. STREAK CARD ---
  Widget _buildStreakCard() {
     final d = _data!;
     return Card(
       elevation: 5,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
       color: Colors.orangeAccent.shade100,
       child: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           children: [
             const Text("Streak", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
             const SizedBox(height: 10),
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 30),
                 const SizedBox(width: 5),
                 Text(
                   "${d.currentStreak}",
                   style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                 ),
               ],
             ),
             const SizedBox(height: 5),
             const Text("Days Active", style: TextStyle(color: Colors.white70, fontSize: 12)),
           ],
         ),
       ),
     );
  }
}