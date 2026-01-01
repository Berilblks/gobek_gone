import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/features/auth/logic/auth_bloc.dart';

class PhysicalInformationPage extends StatelessWidget {
  const PhysicalInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user from state
    final state = context.read<AuthBloc>().state;
    
    // Default values
    int age = 0;
    double height = 0;
    double weight = 0;
    double bmi = 0;
    String bmiStatus = "Unknown";

    if (state is AuthAuthenticated && state.user != null) {
      final user = state.user!;
      height = user.height;
      weight = user.weight;

      // Calculate Age
      final now = DateTime.now();
      age = now.year - user.birthYear;
      if (now.month < user.birthMonth || (now.month == user.birthMonth && now.day < user.birthDay)) {
        age--;
      }

      // Calculate BMI
      if (height > 0) {
        // Height is likely in cm, convert to meters
        double heightM = height / 100;
        bmi = weight / (heightM * heightM);
        
        if (bmi < 18.5) {
          bmiStatus = "Underweight";
        } else if (bmi < 24.9) {
          bmiStatus = "Normal";
        } else if (bmi < 29.9) {
          bmiStatus = "Overweight";
        } else {
          bmiStatus = "Obese";
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.main_background,
      appBar: AppBar(
        title: const Text("Physical Information"),
        backgroundColor: AppColors.appbar_color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInfoCard(
              icon: Icons.cake,
              title: "Age",
              value: "$age",
              unit: "years",
              color: Colors.orange,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.height,
                    title: "Height",
                    value: height.toStringAsFixed(1),
                    unit: "cm",
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.monitor_weight,
                    title: "Weight",
                    value: weight.toStringAsFixed(1),
                    unit: "kg",
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildBmiCard(bmi, bmiStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 5),
              Text(unit, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBmiCard(double bmi, String status) {
    Color statusColor;
    if (status == "Normal") {
      statusColor = Colors.green;
    } else if (status == "Overweight") {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text("Body Mass Index (BMI)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text(
            bmi.toStringAsFixed(1),
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: statusColor),
          ),
          Text(
            status,
            style: TextStyle(fontSize: 20, color: statusColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
