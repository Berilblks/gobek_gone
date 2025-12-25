import 'package:flutter/material.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/UsersBar/User.dart'; // UserPage yolunu kontrol et

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Görsel amaçlı Dark Mode değişkeni
  bool _isDarkMode = false;

  bool _waterReminder = true;
  bool _exerciseReminder = true;
  bool _aiMotivation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,
      body: Column(
        children: [
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
                    // Buraya Fiziksel Bilgiler sayfası gelecek
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

                _buildSectionHeader("App Preferences"),
                // ✨ Dark Mode Butonu (Sadece görsel olarak çalışır)
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode, color: Colors.black54),
                  title: const Text("Dark Mode"),
                  value: _isDarkMode,
                  onChanged: (v) => setState(() => _isDarkMode = v),
                  activeColor: Colors.green,
                ),

                const Divider(),

                _buildSectionHeader("Notifications"),
                _buildSwitchItem("Water Reminder", _waterReminder, (v) => setState(() => _waterReminder = v)),
                _buildSwitchItem("Exercise Reminder", _exerciseReminder, (v) => setState(() => _exerciseReminder = v)),
                _buildSwitchItem("AI Motivation Messages", _aiMotivation, (v) => setState(() => _aiMotivation = v)),

                const Divider(),

                _buildSectionHeader("Account & Security"),
                _buildSettingItem(icon: Icons.lock_reset, title: "Change Password", onTap: () {}),
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

  // --- ÖZEL APPBAR ---
  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: AppColors.appbar_color,
      height: MediaQuery.of(context).padding.top + 60,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          const Expanded(child: Center(child: Text("Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // --- YARDIMCI METOTLAR ---
  Widget _buildSectionHeader(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
  );

  Widget _buildSettingItem({required IconData icon, required String title, required VoidCallback onTap, Color? titleColor}) => ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: TextStyle(color: titleColor)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap
  );

  Widget _buildSwitchItem(String title, bool val, Function(bool) onChanged) => SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 15)),
      value: val,
      onChanged: onChanged,
      activeColor: Colors.green
  );

  // --- DIALOG VE MODAL KODLARI ---
  void _showFeedbackSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}