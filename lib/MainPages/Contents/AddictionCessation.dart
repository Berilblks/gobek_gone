import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:intl/intl.dart';
import 'package:gobek_gone/General/contentBar.dart';
import 'package:gobek_gone/features/addiction/logic/addiction_bloc.dart';
import 'package:gobek_gone/features/addiction/data/models/Addictiontype.dart';

import '../../features/addiction/data/models/Addaddiction_request.dart';
import '../../features/addiction/data/models/Addictioncounter_response.dart';

// Colors (Assumed from previous context)
class AppThemeColors {
  static const Color main_background = Color(0xFFF0F4F8);
  static const Color primary_color = Color(0xFF4CAF50);
  static const Color icons_color = Color(0xFF388E3C);
}

class AddictionCessation extends StatefulWidget {
  const AddictionCessation({super.key});

  @override
  State<AddictionCessation> createState() => _AddictionCessationState();
}

class _AddictionCessationState extends State<AddictionCessation> {

  final String _motivationalQuote = "The greatest victory is the victory a person gains over her own self.";
  final String _warning = "If you can't overcome your addictions on your own, please don't hesitate to reach out for support.";
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  @override
  void initState() {
    super.initState();
    // Load initial status
    context.read<AddictionBloc>().add(LoadAddictionStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.main_background,
      appBar: contentBar(),
      endDrawer: const UserSideBar(),
      body: BlocConsumer<AddictionBloc, AddictionState>(
        listener: (context, state) {
          if (state is AddictionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is AddictionLoading) {
            return const Center(child: CircularProgressIndicator(color: AppThemeColors.icons_color));
          }

          if (state is AddictionNone) {
            return _buildSelectionScreen(context);
          }

          if (state is AddictionActive) {
            return _buildDashboard(context, state.counters);
          }

          if (state is AddictionFailure) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text("Error: ${state.error}", textAlign: TextAlign.center),
                   const SizedBox(height: 10),
                   ElevatedButton(onPressed: () => context.read<AddictionBloc>().add(LoadAddictionStatus()), child: const Text("Retry"))
                 ],
               ),
             );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- 1. SELECTION SCREEN (NO RECORD) ---
  Widget _buildSelectionScreen(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Start Your Journey",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppThemeColors.icons_color),
          ),
          const SizedBox(height: 10),
          const Text(
            "Select the habit you want to quit to start tracking your progress.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          _buildSelectionCard(
            context,
            icon: Icons.smoking_rooms,
            title: "Quit Smoking",
            color: Colors.orange,
            onTap: () => _showAddDialog(context, AddictionType.smoking),
          ),
          const SizedBox(height: 15),
          _buildSelectionCard(
            context,
            icon: Icons.local_bar,
            title: "Quit Alcohol",
            color: Colors.blue,
            onTap: () => _showAddDialog(context, AddictionType.alcohol),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard(BuildContext context, {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. DASHBOARD (ACTIVE RECORD) ---
  Widget _buildDashboard(BuildContext context, List<AddictionCounterResponse> counters) {
    if (counters.isEmpty) return _buildSelectionScreen(context);

    // Identify which are active
    final bool hasSmoking = counters.any((c) => c.addictionType == AddictionType.smoking);
    final bool hasAlcohol = counters.any((c) => c.addictionType == AddictionType.alcohol);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Render existing counters
          ...counters.map((counter) {
              // Determine duration
              final Duration duration = DateTime.now().difference(counter.quitDate);
              
              // Determine labels and icons
              final String typeLabel = counter.addictionType == AddictionType.smoking ? "Cigarette Freedom" : "Alcohol Freedom";
              final IconData icon = counter.addictionType == AddictionType.smoking ? Icons.smoking_rooms_outlined : Icons.local_bar_outlined;
              
              // Calculate Stats
              double saved = 0;
              if (!duration.isNegative) {
                  saved = (duration.inMinutes / 1440.0) * counter.dailyUsage * counter.costPerUnit; 
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildStatsCard(icon, typeLabel, duration, saved, true),
              );
          }),

          // Show "Add Other" options if not both present
          if (!hasSmoking) ...[
             _buildSelectionCard(
                context,
                icon: Icons.smoking_rooms,
                title: "Quit Smoking Too",
                color: Colors.orange,
                onTap: () => _showAddDialog(context, AddictionType.smoking),
             ),
             const SizedBox(height: 20),
          ],
          if (!hasAlcohol) ...[
             _buildSelectionCard(
                context,
                icon: Icons.local_bar,
                title: "Quit Alcohol Too",
                color: Colors.blue,
                onTap: () => _showAddDialog(context, AddictionType.alcohol),
             ),
             const SizedBox(height: 20),
          ],


          _buildQuoteCard(),
          const SizedBox(height: 20),

          // Tools Header
             Text(
              "Helpful Tools and Support",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppThemeColors.icons_color,
              ),
            ),
            const SizedBox(height: 10),
            
            // Tools Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15.0,
              mainAxisSpacing: 15.0,
              children: [
                _buildToolCard(context, Icons.self_improvement, "Breathing Exercise", Colors.green),
                _buildToolCard(context, Icons.phone, "Emergency Support", Colors.red),
              ],
            ),

          const SizedBox(height: 20),
          _buildWarning(),
           const SizedBox(height: 20),
          
          ElevatedButton.icon(
            onPressed: () => _showRelapseDialog(context),
            icon: const Icon(Icons.refresh),
            label: const Text("I RELAPSED / RESET DATE"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade400,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
             const SizedBox(height: 20),
             
             // Bottom Text
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                textAlign: TextAlign.center,
                "We're always here for you.",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(IconData icon, String title, Duration duration, double saved, bool showSavings) {
    String timeString = _formatDuration(duration);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(icon, size: 30, color: AppThemeColors.icons_color),
                 const SizedBox(width: 10),
                 Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppThemeColors.icons_color)),
               ],
             ),
             const Divider(height: 30),
             const Text("Clean Time", style: TextStyle(color: Colors.grey)),
             const SizedBox(height: 5),
             Text(timeString, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppThemeColors.primary_color)),
             
             if (showSavings) ...[
                const SizedBox(height: 20),
                const Text("Money Saved (Est.)", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                Text(_currencyFormat.format(saved), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
             ]
          ],
        ),
      ),
    );
  }

  // --- DIALOGS ---

  void _showAddDialog(BuildContext context, AddictionType type) {
    final TextEditingController consumptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(type == AddictionType.smoking ? "Quit Smoking" : "Quit Alcohol"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: consumptionController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: type == AddictionType.smoking ? "Daily Packs" : "Daily Units",
                      icon: const Icon(Icons.numbers),
                    ),
                  ),
                  if (type == AddictionType.smoking)
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Pack Price (₺)",
                        icon: Icon(Icons.attach_money),
                      ),
                    ),
                    if (type == AddictionType.alcohol)
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Cost Per Unit (₺)",
                        icon: Icon(Icons.attach_money),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text("Quit Date"),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppThemeColors.primary_color,
                                onPrimary: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
              ElevatedButton(
                onPressed: () {
                  final consumption = double.tryParse(consumptionController.text) ?? 0;
                  final price = double.tryParse(priceController.text) ?? 0;
                  
                  if (consumption > 0) {
                      context.read<AddictionBloc>().add(SelectAddictionRequested(
                        AddAddictionRequest(
                          addictionType: type.value,
                          dailyUsage: consumption,
                          costPerUnit: price,
                          quitDate: selectedDate,
                        )
                      ));
                      Navigator.pop(context);
                  }
                },
                child: const Text("START TRACKING"),
              )
            ],
          );
        }
      ),
    );
  }

  void _showRelapseDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("I Relapsed"),
          content: const Text("Don't worry, setbacks happen. This will reset your quit date to TODAY. Are you sure?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                 context.read<AddictionBloc>().add(RelapseRequested(DateTime.now()));
                 Navigator.pop(context);
              },
              child: const Text("RESET DATE"),
            )
          ],
        ),
      );
  }

  // --- HELPERS ---
   String _formatDuration(Duration duration) {
    if (duration.isNegative) return "Just Started!";
    final int days = duration.inDays;
    final int hours = duration.inHours % 24;
    return "$days Days, $hours Hours";
  }

  Widget _buildQuoteCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.format_quote, size: 30, color: AppThemeColors.icons_color),
            const SizedBox(height: 10),
            Text(
              _motivationalQuote,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarning() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.warning_amber, size: 30, color: Colors.red),
            const SizedBox(height: 10),
            Text(
              _warning,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, IconData icon, String title, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
           if (title == "Breathing Exercise") _showBreathingDialog(context);
           if (title == "Emergency Support") _showEmergencyDialog(context);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showBreathingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Take a Deep Breath",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Calm Down with the 4-7-8 Technique:',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 10),
                Text('1. Exhale all the air from your mouth.'),
                Text('2. Breathe in slowly through your nose (4 seconds).'),
                Text('3. Hold your breath (7 seconds).'),
                Text('4. Release it with a "shhh" sound from your mouth (8 seconds).'),
                SizedBox(height: 15),
                Text('Repeat this cycle 3 times'),
                SizedBox(height: 10),
                Divider(),
                Text(
                  'Tip: This helps calm the nervous system.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CLOSE'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  void _showEmergencyDialog(BuildContext context) {
     showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Emergency Support and Assistance Resources",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Don't hesitate to get help. You are not alone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'EMERGENCY SUPPORT LINE:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                Text(
                  'Call: 112',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                SizedBox(height: 20),
                Text(
                  'Online Support Resource:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'bırakabilirsin.org',
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
                Text(
                  '(When you click on this link, you will be directed to an external browser.)',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CLOSE'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}