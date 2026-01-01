import 'package:flutter/material.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/features/auth/logic/auth_bloc.dart';
import 'package:gobek_gone/features/auth/data/models/user_model.dart';

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
  String? _profilePhoto;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  void _dispatchUpdate() {
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

    context.read<AuthBloc>().add(UpdateProfileRequested(
      fullname: fullName,
      username: userName,
      birthDay: d,
      birthMonth: m,
      birthYear: y,
      height: double.tryParse(height) ?? 0.0,
      weight: double.tryParse(weight) ?? 0.0,
      gender: gender,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,
      body: Column(
        children: [
          // ÜST BAR (AppBar Yerine)
          _buildTopBar(context),

          const SizedBox(height: 30),

          // PROFİL FOTOĞRAFI
          _buildAvatar(),

          const SizedBox(height: 30),

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
            color: Colors.black.withOpacity(0.05),
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
}