import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// 1. Veri Modeli ve Mock Veri
// -----------------------------------------------------------------------------
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


// -----------------------------------------------------------------------------
// 2. Arkadaşlar Sayfası (Kompakt AppBar ve Tek Arama Çubuğu)
// -----------------------------------------------------------------------------
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

    return Scaffold(
      appBar: AppBar(
        // LOGO YOLU GÜNCELLENDİ
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset('images/logo-Photoroom.png', height: 28), // Yeni ikon yolu
        ),
        title: const Text(""), // Başlık metni boşaltıldı
        centerTitle: false,
        backgroundColor: Colors.lightGreen.shade100,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.green.shade800),
            onPressed: () {
              // Uygulama içi global arama fonksiyonu buraya gelecek.
            },
          ),
          IconButton(
            icon: CircleAvatar(
              backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/8.jpg'),
              radius: 14, // Daha küçük profil fotoğrafı
            ),
            onPressed: () {
              // Kullanıcı profili sayfasına geçiş
            },
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.green.shade800),
            onPressed: () {
              // Side Bar açma eylemi (İçerik butonu ile aynı işlevi görebilir)
            },
          ),
        ],
        // Arama Çubuğu
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Arkadaş Ara...",
                prefixIcon: Icon(Icons.search, color: Colors.blueGrey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
            ),
          ),
        ),
      ),
      body: _buildFriendList(filteredFriends),
    );
  }

  // ... (Geri kalan metodlar)
  Widget _buildFriendList(List<FriendModel> friends) {
    if (friends.isEmpty && _searchText.isNotEmpty) {
      return Center(
        child: Text(
          "Aradığınız kriterde arkadaşınız bulunamadı.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }
    if (friends.isEmpty && _searchText.isEmpty) {
      return Center(
        child: Text(
          "Henüz hiç arkadaşın yok. Yeni arkadaşlar eklemeye ne dersin?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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