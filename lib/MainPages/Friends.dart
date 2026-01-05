import 'package:flutter/material.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/core/network/api_client.dart';
import 'package:gobek_gone/core/constants/app_constants.dart'; 
import 'package:dio/dio.dart'; 
import '../features/friends/data/models/friend_response.dart';
import '../features/friends/data/services/friend_service.dart';


class AppColors {
  static const Color AI_color = Color(0xFF4DB6AC); 
  static const Color shadow_color = Color(0x33000000); 
  static const Color main_background = Color(0xFFF5F5F5);
}


class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FriendService _friendService = FriendService(ApiClient(baseUrl: AppConstants.apiBaseUrl));
  
  List<FriendResponse> _allUsers = []; // Stores all users fetched from backend
  List<FriendResponse> _searchResults = []; // Stores filtered results for display
  bool _isLoading = false;
  
  String _searchText = '';
  bool isHomeSelected = true; // Default to My Friends

  @override
  void initState() {
    super.initState();
    print("INIT FRIENDS PAGE - Calling _fetchAllUsers"); // DEBUG INIT
    _fetchAllUsers();
    
    // Listen to search input for real-time local filtering
    _searchController.addListener(() {
      _filterUsers(_searchController.text);
    });
  }

  Future<void> _fetchAllUsers() async {
    setState(() => _isLoading = true);
    try {
      // Assuming empty query returns all users. 
      final results = await _friendService.searchUsers(""); 
      
      // Sort alphabetically by name
      results.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      print("FETCHED USERS COUNT: ${results.length}"); // DEBUG
      if (mounted) {
        setState(() {
          _allUsers = results;
          _filterUsers(_searchController.text); // Apply filter immediately
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching users: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterUsers(String query) {
    final lowerQuery = query.toLowerCase();
    
    final filtered = _allUsers.where((user) {
      // Exclude already accepted friends from Search results
      if (user.status == "Accepted") return false; 
      
      if (query.isEmpty) return true;

      final nameMatches = user.name.toLowerCase().contains(lowerQuery);
      final usernameMatches = user.username?.toLowerCase().contains(lowerQuery) ?? false;
      return nameMatches || usernameMatches;
    }).toList();

    setState(() => _searchResults = filtered);
  }
  
  Future<void> _sendRequest(int friendId) async {
    final success = await _friendService.sendFriendRequest(friendId);
    if (success) {
      // Create a new list with updated status to modify local state without refetching everything
      final updatedList = _allUsers.map((user) {
        if (user.id == friendId) {
          // Return new object with updated status using a copyWith-like approach
          // Since FriendResponse is final, we create a new instance.
          // Ideally FriendResponse should have copyWith. For now, manual:
          return FriendResponse(
             id: user.id,
             name: user.name,
             username: user.username,
             photoUrl: user.photoUrl,
             level: user.level,
             steps: user.steps,
             status: "Pending"
          );
        }
        return user;
      }).toList();

      setState(() {
        _allUsers = updatedList;
        _filterUsers(_searchController.text); // Re-filter to update view
      });
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request sent!")));
    }
  }

  Future<void> _acceptRequest(int senderId) async {
    final success = await _friendService.acceptRequest(senderId);
    if (success) {
       final updatedList = _allUsers.map((user) {
        if (user.id == senderId) {
          return FriendResponse(
             id: user.id,
             name: user.name,
             username: user.username,
             photoUrl: user.photoUrl,
             level: user.level,
             steps: user.steps,
             status: "Accepted"
          );
        }
        return user;
      }).toList();

      setState(() {
        _allUsers = updatedList;
        _filterUsers(_searchController.text);
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Friend request accepted!")));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          _buildToggleButton("My Friends 🫂", true),
          _buildToggleButton("Find Friends 🔍", false),
        ],
      ),
    );
  }

  // 2. Tek bir butonu oluşturan ve setState() kullanan metot
  Widget _buildToggleButton(String label, bool home) {
    bool selected = isHomeSelected == home;

    return Expanded(
      child: GestureDetector(
        onTap: () {
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const UserSideBar(),
      backgroundColor: AppColors.main_background,
      body: Column(
        children: [
          gobekgAppbar(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: _buildLocationToggle(),
          ),

          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow_color,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey,),
                  hintText: "Search for users by username.", // Updated hint
                  border: InputBorder.none,
                ),
                // onSubmitted removed, we listen to changes now
                textInputAction: TextInputAction.search,
              ),
            ),
          ),

          // İçerik
          Expanded(
            child: isHomeSelected
                ? _buildMyFriendsTab() 
                : _buildSearchResults(), 
          ),
        ],
      ),
    );
  }

  // Placeholder for My Friends Tab (Static or Future Implementation)
  Widget _buildMyFriendsTab() {
    // Filter users based on status
    final incomingRequests = _allUsers.where((u) => u.status == "Incoming").toList();
    final friends = _allUsers.where((u) => u.status == "Accepted").toList();

    if (incomingRequests.isEmpty && friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_alt_outlined, size: 70, color: Colors.grey),
            const SizedBox(height: 10),
            Text("No friends yet.", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Friend Requests Section
        if (incomingRequests.isNotEmpty) ...[
          const Text(
            "Friend Requests",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          ...incomingRequests.map((user) => FriendCard(
                friend: user,
                onAction: () => _acceptRequest(user.id),
              )),
          const Divider(height: 30, thickness: 1),
        ],

        // My Friends Section
        if (friends.isNotEmpty) ...[
          const Text(
            "My Friends",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          ...friends.map((user) => FriendCard(
                friend: user,
                onAction: () {}, // No action for already accepted friends
              )),
        ],
      ],
    );
  }

  // Search Results List
  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
        // Since we show all users initially, if this is empty, it truly means no users found
        // or filter returned nothing.
        if (_searchController.text.isNotEmpty) {
           return Center(child: Text("User not found.", style: TextStyle(color: Colors.grey.shade600)));
        } else {
           // Should not happen if getAllUsers works and DB has users, but handle empty DB case
            return const Center(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.people_outline, size: 80, color: Colors.grey),
                   SizedBox(height: 20),
                   Text("No one here yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ));
        }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return FriendCard(
          friend: user,
          onAction: () {
             if (user.status == "None") _sendRequest(user.id);
             if (user.status == "Incoming") _acceptRequest(user.id);
          },
        );
      },
    );
  }
}

// 3. Her Bir Arkadaşı Temsil Eden Kart Widget'ı
class FriendCard extends StatelessWidget {
  final FriendResponse friend;
  final VoidCallback onAction;

  const FriendCard({
    Key? key,
    required this.friend,
    required this.onAction,
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
              backgroundImage: (friend.photoUrl != null && friend.photoUrl!.isNotEmpty) 
                  ? NetworkImage(friend.photoUrl!) 
                  : null,
              child: (friend.photoUrl == null || friend.photoUrl!.isEmpty) ? const Icon(Icons.person) : null,
              radius: 30,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          friend.name.isNotEmpty ? friend.name : (friend.username ?? "Unknown"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (friend.level != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                "Lvl ${friend.level}",
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (friend.username != null)
                    Text(
                      "@${friend.username}",
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    "${friend.steps} Steps",
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (friend.status == "Accepted") {
      return const Text("Friends ✅", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
    } else if (friend.status == "Pending") {
      return const Text("Request Sent ⏳", style: TextStyle(color: Colors.orange));
    } else if (friend.status == "Incoming") {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: onAction,
        child: const Text("Accept"),
      );
    } else {
      // Status == "None" or other
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.AI_color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: onAction,
        child: const Text("Add"),
      );
    }
  }
}