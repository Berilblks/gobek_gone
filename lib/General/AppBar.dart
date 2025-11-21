import 'package:flutter/material.dart';
import 'package:gobek_gone/General/app_colors.dart';


class gobekgAppbar extends StatefulWidget implements PreferredSizeWidget{
  const gobekgAppbar({super.key});

  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<gobekgAppbar> createState() => _gobekgAppbarState();
}

class _gobekgAppbarState extends State<gobekgAppbar> {

  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  void _toogleSearch(){
    setState(() {
      _isSearching = !_isSearching;
      if(!_isSearching){
        _searchController.clear();
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appbar_color,
      elevation: 0,                                             // AppBar'ın yüksekliği üzerindeki gölgeyi kaldırır.

      title: _isSearching ? _buildSearchBar() : _buildDefaultTitle(),

      leading: _isSearching ? null : _buildLogo(),
      leadingWidth: _isSearching ? 0 : 100,
      actions: _buildActions(),
    );
  }

  Widget _buildLogo(){
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow_color,
              blurRadius: 55,
            ),
          ],
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          image: const DecorationImage(
              image: AssetImage('images/logo-Photoroom.png'),
              fit: BoxFit.cover,
          ),
        ),
      )
    );
  }

  Widget _buildDefaultTitle(){
    return  Text(
      "Today : Tuesday, Sep 12",
      style: TextStyle(
        fontSize: 16,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildSearchBar(){
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Search in the App...",
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        ),
        onSubmitted: (value) {
          print("Search : $value");
          _toogleSearch();
        },
      ),
    );
  }

  List<Widget> _buildActions(){
    return [
      IconButton(
        icon: Icon(
          _isSearching ? Icons.close : Icons.search,
          color: Colors.black54,
          size: 28,
        ),
        onPressed: _toogleSearch,
      ),

      if(! _isSearching)
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.black54,
              size: 30,
            ),
            onPressed: (){
              // KUllanıcı profil sayfasına gidiş
            },
          ),
        ),
    ];
  }
}


