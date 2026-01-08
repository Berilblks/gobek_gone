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

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
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
        _dispatchUpdate();
      }
    } catch (e) {
      debugPrint("Görsel seçme hatası: $e");
    }
  }

  void _showPickerMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.black87)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.orange),
              title: const Text('Take a Photo', style: TextStyle(color: Colors.black87)),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.appbar_color),
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
              _dispatchUpdate();
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
      _dispatchUpdate();
    }
  }

  void _dispatchUpdate() async {
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
        photoBase64 = _profilePhoto; 
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _loadUserData();
          } else if (state is AuthFailure) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text("Update Failed: ${state.error}"), backgroundColor: Colors.red),
             );
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

          if (state is! AuthAuthenticated || state.user == null) {
             return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: AppColors.appbar_color,
                elevation: 0,
                toolbarHeight: 60,
                centerTitle: true,
                title: const Text(
                  "My Profile",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // --- AVATAR SECTION ---
                      _buildAvatar(),
                      const SizedBox(height: 25),

                      // --- LEVEL CARD ---
                      if (_levelData != null) ...[
                         _buildLevelCard(),
                         const SizedBox(height: 25),
                      ],
                      _buildInfoTile("Username", userName, Icons.person_outline, (v) => setState(() => userName = v)),
                      _buildInfoTile("Full Name", fullName, Icons.badge_outlined, (v) => setState(() => fullName = v)),
                      _buildInfoTile("E-mail", email, Icons.email_outlined, null),
                      _buildInfoTile("Gender", gender, Icons.wc, (v) => setState(() => gender = v)),
                      _buildInfoTile("Birth Date", birthDate, Icons.calendar_today_outlined, (v) => setState(() => birthDate = v)),
                      _buildInfoTile("Height (cm)", height, Icons.height, (v) => setState(() => height = v)),
                      _buildInfoTile("Weight (kg)", weight, Icons.monitor_weight_outlined, (v) => setState(() => weight = v)),
                      const SizedBox(height: 40), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.appbar_color.withValues(alpha: 0.5), width: 3),
            ),
            child: CircleAvatar(
              radius: 65,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: _image != null 
                ? FileImage(_image!) 
                : (_profilePhoto != null && _profilePhoto!.isNotEmpty 
                    ? MemoryImage(base64Decode(_profilePhoto!)) as ImageProvider 
                    : null),
              child: (_image == null && (_profilePhoto == null || _profilePhoto!.isEmpty))
                  ? Icon(Icons.person, size: 70, color: Colors.grey.shade400)
                  : null,
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: () => _showPickerMenu(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bottombar_color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, Function(String)? onEdit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onEdit != null ? () {
             if (label == "Birth Date") {
               _pickDate();
             } else {
               _editInfoDialog(label, value, onEdit);
             }
          } : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.appbar_color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.bottombar_color, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  Icon(Icons.edit_rounded, color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard() {
    final d = _levelData!;
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text(
                     "CURRENT LEVEL", 
                     style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)
                   ),
                   const SizedBox(height: 5),
                   Text(
                     "Level ${d.level}", 
                     style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)
                   ),
                 ],
               ),
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.white.withValues(alpha: 0.2),
                   shape: BoxShape.circle,
                 ),
                 child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 32),
               ),
             ],
           ),
           const SizedBox(height: 25),
           Column(
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text("${d.currentXp} XP", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                   Text("${d.xpForNextLevel} XP", style: const TextStyle(color: Colors.white70)),
                 ],
               ),
               const SizedBox(height: 8),
               ClipRRect(
                 borderRadius: BorderRadius.circular(10),
                 child: LinearProgressIndicator(
                    value: (d.progressPercentage / 100).clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: Colors.black12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                 ),
               ),
             ],
           ),
        ],
      ),
    );
  }
}