import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/contentBar.dart';
import 'package:gobek_gone/features/auth/logic/auth_bloc.dart';
import 'package:gobek_gone/features/bmi/logic/bmi_bloc.dart';
import 'package:gobek_gone/features/bmi/data/models/bmi_status.dart';
import 'package:gobek_gone/MainPages/UsersBar/User.dart';

// Renklerin doğru çalışması için, projenizde AppThemeColors sınıfının aşağıdaki gibi tanımlı olduğunu varsayıyoruz.
class AppThemeColors {
  static const Color main_background = Color(0xFFF0F4F8); // Açık arka plan
  static const Color primary_color = Color(0xFF4CAF50);    // Ana yeşil
  static const Color icons_color = Color(0xFF388E3C);     // Koyu yeşil
}


class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {

  @override
  void initState() {
    super.initState();
    // Load history when page opens
    context.read<BmiBloc>().add(LoadBmiHistoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    // Get User Data
    final authState = context.watch<AuthBloc>().state;
    String userName = "User";
    
    // User stats
    double userHeight = 0;
    double userWeight = 0;
    int userAge = 0;
    String userGender = "N/A";
    
    // Calculate Age Logic (should be shared ideally)
    if (authState is AuthAuthenticated && authState.user != null) {
      final user = authState.user!;
      userName = user.username.isNotEmpty ? user.username : user.fullname;
      userHeight = user.height;
      userWeight = user.weight;
      userGender = user.gender;
      
      final now = DateTime.now();
      userAge = now.year - user.birthYear;
      if (now.month < user.birthMonth || (now.month == user.birthMonth && now.day < user.birthDay)) {
        userAge--;
      }
    }

    return Scaffold(
      backgroundColor: AppThemeColors.main_background,
      appBar: contentBar(),
      endDrawer: const UserSideBar(),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated && state.user != null) {
              final user = state.user!;
              final now = DateTime.now();
              int age = now.year - user.birthYear;
              if (now.month < user.birthMonth || (now.month == user.birthMonth && now.day < user.birthDay)) {
                age--;
              }
              
              if (user.height > 0 && user.weight > 0 && age > 0) {
                 // Trigger calculation automatically when user data changes/loads
                 context.read<BmiBloc>().add(CalculateBmiRequested(
                    height: user.height,
                    weight: user.weight,
                    age: age,
                    gender: user.gender,
                 ));
              }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text("Hello, $userName!", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("We will use your physical information from your profile.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              // --- USER INFO DISPLAY ---
              Row(
                children: [
                  Expanded(child: _buildInfoCard("Height", "${userHeight.toStringAsFixed(0)} cm", Icons.height)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInfoCard("Weight", "$userWeight kg", Icons.monitor_weight)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildInfoCard("Age", "$userAge", Icons.cake)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInfoCard("Gender", userGender, Icons.person)),
                ],
              ),
              
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const UserPage()));
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Update Info in Profile"),
                  style: TextButton.styleFrom(foregroundColor: AppThemeColors.icons_color),
                ),
              ),
              
              const SizedBox(height: 20),

              // --- CALCULATE BUTTON ---
              BlocConsumer<BmiBloc, BmiState>(
                listener: (context, state) {
                  if (state is BmiFailure) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
                  }
                },
                builder: (context, state) {
                  if (state is BmiLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return ElevatedButton(
                    onPressed: () {
                      // Trigger calculation manually
                      if (userHeight > 0 && userWeight > 0 && userAge > 0) {
                        context.read<BmiBloc>().add(CalculateBmiRequested(
                          height: userHeight,
                          weight: userWeight,
                          age: userAge,
                          gender: userGender,
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please update your profile with valid Height, Weight and Birthdate.")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeColors.icons_color,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("CALCULATE & UPDATE BMI", style: TextStyle(fontSize: 18, color: Colors.white)),
                  );
                },
              ),


            const SizedBox(height: 40),

            // --- RESULT DISPLAY ---
            BlocBuilder<BmiBloc, BmiState>(
              builder: (context, state) {
                if (state is BmiSuccess && state.latestBmi != null) {
                  final result = state.latestBmi!;
                  Color resultColor = _getColorForStatus(result.status);

                  return Column(
                    children: [
                      const Text("Your BMI Result:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                        result.bmiResult.toStringAsFixed(2),
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: resultColor),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        result.statusDescription.isNotEmpty ? result.statusDescription : result.status.name, // Use stored desc or enum name
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: resultColor),
                      ),
                      const SizedBox(height: 10),
                      Text("Last calculated: ${result.calculationDate.toString().split(' ')[0]}", style: const TextStyle(color: Colors.grey)),
                    ],
                  );
                }
                return const SizedBox.shrink(); 
              },
            ),

            const SizedBox(height: 40),

            // --- BMI CATEGORIES TABLE ---
            _buildBmiTable(context),
          ],
        ),
      ),
    ),
    );
  }

  Color _getColorForStatus(BmiStatus status) {
     switch (status) {
       case BmiStatus.underweight: return Colors.blue;
       case BmiStatus.normalWeight: return AppThemeColors.primary_color;
       case BmiStatus.overweight: return Colors.orange;
       case BmiStatus.obese: return Colors.red;
     }
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppThemeColors.icons_color),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBmiTable(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.green, width: 3),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("BMI Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                 _buildTableRow("BMI", "Status", isHeader: true),
                _buildTableRow("< 18.5", "Underweight", color: Colors.blue),
                _buildTableRow("18.5 - 24.9", "Normal Weight", color: AppThemeColors.primary_color),
                _buildTableRow("25.0 - 29.9", "Overweight", color: Colors.orange),
                _buildTableRow("30.0 - 34.9", "Obesity Class I", color: Colors.red.shade400),
                _buildTableRow("35.0 - 39.9", "Obesity Class II", color: Colors.red.shade600),
                _buildTableRow(">= 40.0", "Obesity Class III", color: Colors.red.shade800),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String range, String status, {Color? color, bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey.shade200 : null,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(range, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, color: color != null && !isHeader ? color : Colors.black)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(status, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, color: color != null && !isHeader ? color : Colors.black)),
        ),
      ],
    );
  }
}
