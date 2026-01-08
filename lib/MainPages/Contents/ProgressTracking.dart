import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/General/contentBar.dart';
import '../../features/progress/data/models/progress_overview_response.dart';
import '../../features/progress/logic/progress_bloc.dart';
import '../../features/auth/logic/auth_bloc.dart';

class ProgressTracking extends StatefulWidget {
  const ProgressTracking({Key? key}) : super(key: key);

  @override
  State<ProgressTracking> createState() => _ProgressTrackingState();
}

class _ProgressTrackingState extends State<ProgressTracking> {

  @override
  void initState() {
    super.initState();
    context.read<ProgressBloc>().add(LoadProgressOverview());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: contentBar(),
      endDrawer: const UserSideBar(),
      body: BlocConsumer<ProgressBloc, ProgressState>(
        listener: (context, state) {
          if (state is ProgressLoaded) {
          }
          if (state is ProgressError) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProgressLoading) {
             return const Center(child: CircularProgressIndicator());
          }
          if (state is ProgressError) {
             return _buildErrorState(state.message);
          }
          if (state is ProgressLoaded) {
             return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSummaryCard(state.data),
                      const SizedBox(height: 20),
                      _buildChartCard(state.data),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _buildBmiCard(state.data)),
                          const SizedBox(width: 15),
                          Expanded(child: _buildStreakCard(state.data)),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
          }
          return _buildErrorState("No Data");
        },
      ),
    
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWeightDialog(),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Log Today's Weight", style: TextStyle(color: Colors.black)),
          content: TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              hintText: "e.g. 75.5",
              hintStyle: TextStyle(color: Colors.grey),
              suffixText: "kg",
              suffixStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
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
                  Navigator.pop(context);
                  context.read<ProgressBloc>().add(UpdateWeightEvent(val));

                  context.read<AuthBloc>().add(LoadUserRequested());
                  
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Weight updating...")));
                }
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          Text("Could not load data: $msg", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<ProgressBloc>().add(LoadProgressOverview()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.AI_color, foregroundColor: Colors.white),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ProgressOverviewResponse d) {
    return Card(
      elevation: 5,
      color: Colors.white,
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
             SizedBox(
               height: 180,
               child: BarChart(
                 BarChartData(
                   alignment: BarChartAlignment.spaceAround,
                   maxY: ((d.startWeight > d.currentWeight ? d.startWeight : d.currentWeight) > d.targetWeight ? (d.startWeight > d.currentWeight ? d.startWeight : d.currentWeight) : d.targetWeight) + 10,
                   barTouchData: BarTouchData(
                     enabled: false,
                     touchTooltipData: BarTouchTooltipData(
                       tooltipBgColor: Colors.transparent, 
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
                            backDrawRodData: BackgroundBarChartRodData(show: true, toY: ((d.startWeight > d.currentWeight ? d.startWeight : d.currentWeight) > d.targetWeight ? (d.startWeight > d.currentWeight ? d.startWeight : d.currentWeight) : d.targetWeight) + 10, color: Colors.grey.shade100),
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
                            backDrawRodData: BackgroundBarChartRodData(show: true, toY: ((d.startWeight > d.currentWeight ? d.startWeight : d.currentWeight) > d.targetWeight ? (d.startWeight > d.currentWeight ? d.startWeight : d.currentWeight) : d.targetWeight) + 10, color: Colors.grey.shade100),
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
                            backDrawRodData: BackgroundBarChartRodData(show: true, toY: ((d.startWeight > d.currentWeight ? d.startWeight : d.currentWeight) > d.targetWeight ? (d.startWeight > d.currentWeight ? d.startWeight : d.currentWeight) : d.targetWeight) + 10, color: Colors.grey.shade100),
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

  Widget _buildChartCard(ProgressOverviewResponse d) {
    final history = d.history;
    if (history.isEmpty) {
       return const Card(
         color: Colors.white,
         child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No data available yet.", style: TextStyle(color: Colors.black)))),
       );
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].weight));
    }

    double minWeight = history.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    double maxWeight = history.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    
    minWeight -= 1;
    maxWeight += 1;

    return Card(
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Weekly Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200)),
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (history.length > 5) ? (history.length / 4).floorToDouble() : 1, 
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < history.length) {
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
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          );
                        }
                      )
                    )
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
                        color: AppColors.title_color.withValues(alpha: 0.2),
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

  Widget _buildBmiCard(ProgressOverviewResponse d) {
    return Card(
      elevation: 5,
      color: Colors.white,
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
                color: _getBmiColor(d.bmiStatus).withValues(alpha: 0.2),
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

  Widget _buildStreakCard(ProgressOverviewResponse d) {
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