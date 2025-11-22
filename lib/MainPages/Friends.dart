import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/BottomBar.dart';
import 'package:gobek_gone/General/Fab.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/AI.dart';

// 1. Veri Modeli ve Mock Veri
class FriendModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String level;
  final int steps;

  FriendModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.level,
    required this.steps,
  });
}

final List<FriendModel> mockMyFriends = [
  FriendModel(
    id: 'user1',
    name: "Ahmet Yılmaz",
    avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
    level: "143",
    steps: 1924,
  ),
  FriendModel(
    id: 'user2',
    name: "Ayşe Can",
    avatarUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
    level: "149",
    steps: 1924,
  ),
  FriendModel(
    id: 'user3',
    name: "Mehmet Kaya",
    avatarUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
    level: "145",
    steps: 1924,
  ),
  FriendModel(
    id: 'user4',
    name: "Zeynep Demir",
    avatarUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
    level: "150",
    steps: 2100,
  ),
];


// 2. Arkadaşlar Sayfası (Kompakt AppBar ve Tek Arama Çubuğu)
class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FriendModel> _filterFriends(List<FriendModel> friendList) {
    if (_searchText.isEmpty) {
      return friendList;
    }
    return friendList
        .where((friend) => friend.name.toLowerCase().contains(_searchText))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFriends = _filterFriends(mockMyFriends);
    final double topPadding = kToolbarHeight + MediaQuery.of(context).padding.top;

      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(15.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow_color,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.grey,),
                      hintText: "Find my friend...",
                      border: InputBorder.none,
                    ),
                ),
              ),
            ),
            Expanded(
                child: _buildFriendList(filteredFriends),
            ),
          ],
        ),
      );
  }

  // ... (Geri kalan metodlar)
  Widget _buildFriendList(List<FriendModel> friends) {
    if (friends.isEmpty && _searchText.isNotEmpty) {
      return Center(
        child: Text(
          "Aradığınız kriterde arkadaşınız bulunamadı.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      );
    }
    if (friends.isEmpty && _searchText.isEmpty) {
      return Center(
        child: Text(
          "Henüz hiç arkadaşın yok. Yeni arkadaşlar eklemeye ne dersin?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return FriendCard(
          friend: friend,
          onMessage: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${friend.name} ile sohbet açıldı!')),
            );
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// 3. Her Bir Arkadaşı Temsil Eden Kart Widget'ı (Sadece Mesaj Gönder Butonlu)
// -----------------------------------------------------------------------------
class FriendCard extends StatelessWidget {
  final FriendModel friend;
  final VoidCallback onMessage;

  const FriendCard({
    Key? key,
    required this.friend,
    required this.onMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(friend.avatarUrl),
              radius: 30,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Level ${friend.level} • ${friend.steps} Adım",
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: onMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              ),
              child: const Text("Mesaj Gönder"),
            ),
          ],
        ),
      ),
    );
  }
}