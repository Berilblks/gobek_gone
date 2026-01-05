import 'package:flutter/material.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/features/auth/logic/auth_bloc.dart';
import 'package:gobek_gone/core/network/api_client.dart';
import 'package:gobek_gone/core/constants/app_constants.dart';
import 'package:gobek_gone/features/gamification/data/models/level_progress_response.dart';
import 'package:gobek_gone/features/gamification/data/services/gamification_service.dart';
import 'package:percent_indicator/linear_percent_indicator.dart'; // Add
// Removed self-import

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // Kullanıcı Bilgileri
  String userName = "";
  String fullName = "";
  String email = "";
  String gender = "";
  String birthDate = "";
  String height = "";
  String weight = "";
  double targetWeight = 0.0;
  String? _profilePhoto;

  @override
  void initState() {
    super.initState();
    // Initial load attempt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _fetchLevel();
    });
  }

  LevelProgressResponse? _levelData;

  Future<void> _fetchLevel() async {
    try {
      final service = GamificationService(ApiClient(baseUrl: AppConstants.apiBaseUrl));
      final data = await service.getLevelProgress();
      if (mounted && data != null) {
        setState(() => _levelData = data);
      }
    } catch (_) {}
  }

  void _loadUserData() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated && state.user != null) {
      final user = state.user!;
      setState(() {
        userName = user.username;
        fullName = user.fullname;
        email = user.email;
        gender = user.gender;
        birthDate = "${user.birthDay}/${user.birthMonth}/${user.birthYear}";
        height = user.height.toString();
        weight = user.weight.toString();
        targetWeight = user.targetWeight;
        _profilePhoto = user.profilePhoto;
      });
    }
  }

  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Fotoğraf Seçme Fonksiyonu
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Görsel seçme hatası: $e");
    }
  }

  // Fotoğraf Seçenekleri Menüsü
  void _showPickerMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.orange),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_image != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() => _image = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  // Bilgi Düzenleme Penceresi
  void _editInfoDialog(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter new $title"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
              _dispatchUpdate(); // Trigger backend update
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime initialDate = DateTime.now();
    try {
      // Parse current string or default
      final parts = birthDate.split('/');
      if (parts.length == 3) {
        initialDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (_) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthDate = "${picked.day}/${picked.month}/${picked.year}";
      });
      _dispatchUpdate(); // Trigger backend update
    }
  }

  void _dispatchUpdate() async {
    // Parse date safely
    int d = 0, m = 0, y = 0;
    try {
      final parts = birthDate.split('/');
      if (parts.length == 3) {
        d = int.parse(parts[0]);
        m = int.parse(parts[1]);
        y = int.parse(parts[2]);
      }
    } catch (_) {}

    String? photoBase64;
    if (_image != null) {
      try {
        List<int> imageBytes = await _image!.readAsBytes();
        photoBase64 = base64Encode(imageBytes);
      } catch (e) {
        debugPrint("Error encoding image: $e");
      }
    } else {
        // If no new image, we can send null (if backend keeps old) or send existing _profilePhoto
        // User snippet says: "profilePhoto": "base64..." (Optional)
        // Usually optional means "if you want to change it". 
        // We will send null if no change, so backend keeps existing.
        // However, if we want to ensure consistency, we can send null. 
        // But if _image is null, we are not changing it.
        photoBase64 = null; 
    }

    if (!mounted) return;

    context.read<AuthBloc>().add(UpdateProfileRequested(
      fullname: fullName,
      username: userName,
      birthDay: d,
      birthMonth: m,
      birthYear: y,
      height: double.tryParse(height) ?? 0.0,
      weight: double.tryParse(weight) ?? 0.0,
      targetWeight: targetWeight,
      gender: gender,
      profilePhoto: photoBase64,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _loadUserData(); // Reload if auth state updates (e.g. after successful save)
          } else if (state is AuthFailure) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text("Update Failed: ${state.error}"), backgroundColor: Colors.red),
             );
             // Optionally reload user data to get back to a valid state
             context.read<AuthBloc>().add(LoadUserRequested());
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is AuthFailure) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Text("Something went wrong.", style: TextStyle(color: Colors.red)),
                   const SizedBox(height: 10),
                   ElevatedButton(
                     onPressed: () => context.read<AuthBloc>().add(LoadUserRequested()),
                     child: const Text("Retry"),
                   )
                 ],
               ),
             );
          }

          // Guard: If not authenticated (and not loading/failure handled above), show loader
          if (state is! AuthAuthenticated || state.user == null) {
             return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // ÜST BAR (AppBar Yerine)
              _buildTopBar(context),

              const SizedBox(height: 30),

              // PROFİL FOTOĞRAFI
              _buildAvatar(),

              const SizedBox(height: 30),

              if (_levelData != null) ...[
                 _buildLevelCard(),
                 const SizedBox(height: 20),
              ],
              
              // BİLGİ LİSTESİ
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildInfoTile("Username", userName, (v) => setState(() => userName = v)),
                    _buildInfoTile("Full Name", fullName, (v) => setState(() => fullName = v)),
                    _buildInfoTile("E-mail", email, null),
                    _buildInfoTile("Gender", gender, (v) => setState(() => gender = v)),
                    _buildInfoTile("Birth Date", birthDate, (v) => setState(() => birthDate = v)),
                    _buildInfoTile("Height (cm)", height, (v) => setState(() => height = v)),
                    _buildInfoTile("Weight (kg)", weight, (v) => setState(() => weight = v)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: AppColors.appbar_color,
      height: MediaQuery.of(context).padding.top + 60,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Center(
            child: Text(
              "My Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _image != null 
              ? FileImage(_image!) 
              : (_profilePhoto != null && _profilePhoto!.isNotEmpty 
                  ? MemoryImage(base64Decode(_profilePhoto!)) as ImageProvider 
                  : null),
            child: (_image == null && (_profilePhoto == null || _profilePhoto!.isEmpty))
                ? const Icon(Icons.person, size: 80, color: Colors.white)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showPickerMenu(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, Function(String)? onEdit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.green, size: 28),
              onPressed: () {
                if (label == "Birth Date") {
                  _pickDate();
                } else {
                  _editInfoDialog(label, value, onEdit);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    final d = _levelData!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text("CURRENT LEVEL", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
                   const SizedBox(height: 5),
                   Text("Level ${d.level}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                 ],
               ),
               Icon(Icons.workspace_premium, color: Colors.amber.shade700, size: 40),
             ],
           ),
           const SizedBox(height: 15),
           LinearPercentIndicator(
              lineHeight: 12.0,
              percent: (d.progressPercentage / 100).clamp(0.0, 1.0),
              center: Text(
                "${d.progressPercentage.toStringAsFixed(0)}%",
                style: const TextStyle(fontSize: 9.0, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              leading: Text("${d.currentXp} XP", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              trailing: Text("${d.xpForNextLevel} XP", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              barRadius: const Radius.circular(7),
              progressColor: Colors.amber.shade700,
              backgroundColor: Colors.grey.shade200,
              animation: true,
              padding: const EdgeInsets.symmetric(horizontal: 10),
           ),
        ],
      ),
    );
  }
}