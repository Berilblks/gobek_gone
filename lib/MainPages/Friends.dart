import 'package:flutter/material.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';

// ----- YEREL RENK SİMÜLASYONU (AppColors yerine) -----
class AppColors {
  static const Color AI_color = Color(0xFF4DB6AC); // Toggle seçili rengi (Teal)
  static const Color shadow_color = Color(0x33000000); // Gölge rengi
  static const Color main_background = Color(0xFFF5F5F5);
}
// --------------------------------------------------

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
  FriendModel(id: 'user1', name: "Ahmet Yılmaz", avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg', level: "143", steps: 1924),
  FriendModel(id: 'user2', name: "Ayşe Can", avatarUrl: 'https://randomuser.me/api/portraits/women/2.jpg', level: "149", steps: 3500),
  FriendModel(id: 'user3', name: "Mehmet Kaya", avatarUrl: 'https://randomuser.me/api/portraits/men/3.jpg', level: "145", steps: 2800),
  FriendModel(id: 'user4', name: "Zeynep Demir", avatarUrl: 'https://randomuser.me/api/portraits/women/4.jpg', level: "150", steps: 2100),
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

  // HATA ALDIĞINIZ DEĞİŞKEN BURADA TANIMLI
  bool isHomeSelected = true;

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

  // -----------------------------------------------------------------------------
  // HATA DÜZELTME: isHomeSelected ve setState kullanan metodlar buraya taşındı
  // -----------------------------------------------------------------------------

  // 1. Konum Kutularını Oluşturma Metodu
  Widget _buildLocationToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [

          // Evde butonu (home: true) - Seçili iken: Arkadaşlarım
          _buildToggleButton("Arkadaşlarım 🫂", true),
          // Spor Salonunda butonu (home: false) - Seçili iken: Arkadaş Ara
          _buildToggleButton("Arkadaş Ara 🔍", false),
        ],
      ),
    );
  }

  // 2. Tek bir butonu oluşturan ve setState() kullanan metot
  Widget _buildToggleButton(String label, bool home) {
    // isHomeSelected'a erişim, sınıfın üyesi olduğu için doğrudur
    bool selected = isHomeSelected == home;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // setState() kullanımı, State sınıfı içinde olduğu için doğrudur
          setState(() => isHomeSelected = home);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.AI_color : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // isHomeSelected true ise arkadaş listesi, false ise arama sonuçları gösterilir.
    final List<FriendModel> displayList = isHomeSelected ? _filterFriends(mockMyFriends) : [];

    return Scaffold(
      endDrawer: const UserSideBar(),// Sayfanın tam görünmesi için Scaffold ekledim
      backgroundColor: AppColors.main_background,
      body: Column(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: gobekgAppbar(),
          ),
          // 1. Konum Seçme Butonları
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: _buildLocationToggle(),
          ),

          // 2. Arama Çubuğu (Her iki modda da görünebilir, ancak listeye göre filtreler)
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow_color,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey,),
                  hintText: "Arkadaş ara...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // 3. İçerik (isHomeSelected'a göre dinamik)
          Expanded(
            child: SingleChildScrollView(
              child: isHomeSelected
                  ? _buildFriendList(displayList) // Arkadaşlarım listesi
                  : _buildFindFriendContent(),    // Arkadaş Ara ekranı
            ),
          ),
        ],
      ),
    );
  }

  // Arkadaş Listesi (isHomeSelected == true iken gösterilir)
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Henüz hiç arkadaşın yok. Yeni arkadaşlar eklemeye ne dersin?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return FriendCard(
          friend: friend,
          onMessage: () {
            // Mesaj gönderme eylemi
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${friend.name} kişisine mesaj gönderiliyor...")),
            );
          },
        );
      },
    );
  }

  // Arkadaş Ara İçeriği (isHomeSelected == false iken gösterilir)
  Widget _buildFindFriendContent() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_alt_1, size: 80, color: Colors.teal),
            SizedBox(height: 20),
            Text(
              "Arkadaşını Davet Et",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 10),
            Text(
              "Arkadaşının kullanıcı adını yukarıdaki arama kutusuna yazarak bulabilir veya onları uygulamaya davet edebilirsin.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. Her Bir Arkadaşı Temsil Eden Kart Widget'ı
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