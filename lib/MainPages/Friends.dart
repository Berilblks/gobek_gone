import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/features/friends/logic/friends_bloc.dart';
import '../features/friends/data/models/friend_response.dart';

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
  bool isHomeSelected = true;

  @override
  void initState() {
    super.initState();
    context.read<FriendsBloc>().add(const LoadFriendsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                color: selected 
                    ? Colors.white 
                    : Colors.black54,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<FriendsBloc, FriendsState>(
        listener: (context, state) {
           if (state is FriendsLoaded && state.actionMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(state.actionMessage!))
              );
           }
           if (state is FriendsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text("Error: ${state.message}"))
              );
           }
        },
        builder: (context, state) {
          return Column(
            children: [
              gobekgAppbar(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: _buildLocationToggle(),
              ),

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
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                       context.read<FriendsBloc>().add(SearchFriendsEvent(value));
                    },
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search, color: Colors.grey,),
                      hintText: "Search for users by username.",
                      hintStyle: TextStyle(color: Colors.grey[600]), 
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),

              Expanded(
                child: state is FriendsLoading 
                    ? const Center(child: CircularProgressIndicator()) 
                    : (state is FriendsLoaded) 
                        ? (isHomeSelected ? _buildMyFriendsTab(state) : _buildSearchResults(state))
                        : const SizedBox(), 
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMyFriendsTab(FriendsLoaded state) {
    final allUsers = state.allUsers;
    final incomingRequests = allUsers.where((u) => u.status == "Incoming").toList();
    final friends = allUsers.where((u) => u.status == "Accepted").toList();

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
        if (incomingRequests.isNotEmpty) ...[
          const Text(
            "Friend Requests",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          ...incomingRequests.map((user) => FriendCard(
                friend: user,
                onAction: () {
                   context.read<FriendsBloc>().add(AcceptFriendRequestEvent(user.id));
                },
              )),
          const Divider(height: 30, thickness: 1),
        ],

        if (friends.isNotEmpty) ...[
          const Text(
            "My Friends",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          ...friends.map((user) => FriendCard(
                friend: user,
                onAction: () {},
              )),
        ],
      ],
    );
  }

  Widget _buildSearchResults(FriendsLoaded state) {
    final results = state.searchResults;
    
    if (results.isEmpty) {
        if (state.currentQuery.isNotEmpty) {
           return Center(child: Text("User not found.", style: TextStyle(color: Colors.grey.shade600)));
        } else {
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
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        return FriendCard(
          friend: user,
          onAction: () {
             if (user.status == "None") {
               context.read<FriendsBloc>().add(SendFriendRequestEvent(user.id));
             }
             if (user.status == "Incoming") {
               context.read<FriendsBloc>().add(AcceptFriendRequestEvent(user.id));
             }
          },
        );
      },
    );
  }
}

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
      color: Colors.white,
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