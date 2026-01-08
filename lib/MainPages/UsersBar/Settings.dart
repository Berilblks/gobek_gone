import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/features/auth/logic/auth_bloc.dart';
import 'package:gobek_gone/LoginPages/OnboardingScreen.dart';
import 'package:gobek_gone/MainPages/UsersBar/User.dart'; 
import 'package:gobek_gone/MainPages/UsersBar/ChangePasswordPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gobek_gone/features/notifications/notification_service.dart';
import 'package:gobek_gone/MainPages/UsersBar/PhysicalInformationPage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Local state
  bool _waterReminder = false;
  bool _exerciseReminder = false;
  bool _aiMotivation = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _waterReminder = prefs.getBool('water_reminder') ?? false;
      _exerciseReminder = prefs.getBool('exercise_reminder') ?? false;
      _aiMotivation = prefs.getBool('ai_motivation') ?? false;
    });

    // Sync with notification service on load just in case (optional, but good practice)
    // Request permissions on first load if any is enabled
    if (_waterReminder || _exerciseReminder || _aiMotivation) {
       await NotificationService().requestPermissions();
    }
    
    if (_waterReminder) NotificationService().scheduleWaterReminder();
    if (_exerciseReminder) NotificationService().scheduleExerciseReminder();
    if (_aiMotivation) NotificationService().scheduleAIMotivation();
  }

  Future<void> _toggleWater(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('water_reminder', value);
    setState(() => _waterReminder = value);

    if (value) {
      // NotificationService().scheduleWaterReminder(); // Periodic every minute (TESTING)
      NotificationService().scheduleWaterReminderHourly(); // Hourly
    } else {
      NotificationService().cancelNotification(100);
    }
  }

  Future<void> _toggleExercise(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('exercise_reminder', value);
    setState(() => _exerciseReminder = value);

    if (value) {
      NotificationService().scheduleExerciseReminder();
    } else {
      NotificationService().cancelNotification(200);
    }
  }

  Future<void> _toggleMotivation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ai_motivation', value);
    setState(() => _aiMotivation = value);

    if (value) {
      NotificationService().scheduleAIMotivation();
    } else {
      NotificationService().cancelNotification(300);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,
      body: Column(
        children: [
          // Listen to AuthBloc for deletion states
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is DeleteAccountCodeSent) {
                _showDeleteCodeDialog();
              } else if (state is DeleteAccountSuccess) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Onboardingscreen()), 
                );
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error), backgroundColor: Colors.red),
                );
              }
            },
            child: const SizedBox.shrink(),
          ),
          _buildCustomAppBar(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSectionHeader("User Profile"),
                _buildSettingItem(
                  icon: Icons.straighten,
                  title: "Physical Information",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PhysicalInformationPage()));
                  },
                ),
                _buildSettingItem(
                  icon: Icons.edit,
                  title: "Edit Profile",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserPage()));
                  },
                ),

                const Divider(),

                _buildSectionHeader("Notifications"),
                _buildSwitchItem("Water Reminder (Every Hour)", _waterReminder, _toggleWater),
                _buildSwitchItem("Exercise Reminder (Daily 18:00)", _exerciseReminder, _toggleExercise),
                _buildSwitchItem("AI Motivation (Daily 09:00)", _aiMotivation, _toggleMotivation),

                const Divider(),

                _buildSectionHeader("Account & Security"),
                _buildSettingItem(
                    icon: Icons.lock_reset, 
                    title: "Change Password", 
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
                    }
                ),
                _buildSettingItem(
                    icon: Icons.delete_forever,
                    title: "Delete Account",
                    titleColor: Colors.red,
                    onTap: () => _showDeleteDialog()
                ),

                const Divider(),

                _buildSectionHeader("Support"),
                _buildSettingItem(
                    icon: Icons.feedback,
                    title: "Feedback & Suggestions",
                    onTap: () => _showFeedbackSheet()
                ),
                _buildSettingItem(icon: Icons.policy, title: "Privacy Policy", onTap: () {}),

                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Version 1.0.0", style: TextStyle(color: Colors.grey))
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CUSTOM APPBAR ---
  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: AppColors.appbar_color,
      height: MediaQuery.of(context).padding.top + 60,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87), 
            onPressed: () => Navigator.pop(context)
          ),
          const Expanded(child: Center(child: Text("Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)))),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
  );

  Widget _buildSettingItem({required IconData icon, required String title, required VoidCallback onTap, Color? titleColor}) {
     return ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(title, style: TextStyle(color: titleColor ?? Colors.black87)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap
    );
  }

  Widget _buildSwitchItem(String title, bool val, Function(bool) onChanged) {
      return SwitchListTile(
          title: Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          value: val,
          onChanged: onChanged,
          activeColor: Colors.green
      );
  }

  // --- DIALOG VE MODAL KODLARI ---
  
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Delete Account"),
        content: const Text("Are you sure? This cannot be undone. You will receive a verification code via email."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(DeleteAccountRequested());
            },
            child: const Text("Send Code", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteCodeDialog() {
    TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Confirm Deletion"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please enter the 6-digit code sent to your email."),
            const SizedBox(height: 10),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(hintText: "Code"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(ConfirmDeleteAccountRequested(code: codeController.text));
            },
            child: const Text("DELETE PERMANENTLY", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFeedbackSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Feedback & Suggestions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(hintText: "Your message...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
              onPressed: () => Navigator.pop(context),
              child: const Text("Send", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}