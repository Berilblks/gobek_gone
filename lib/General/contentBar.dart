import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:intl/intl.dart';

class contentBar extends StatefulWidget implements PreferredSizeWidget {
  const contentBar({
    super.key,
    this.onSearch,
  });

  final Function(String query)? onSearch;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<contentBar> createState() => _contentBarState();
}

class _contentBarState extends State<contentBar> {

  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();

  void _toogleSearch(){
    setState(() {
      _isSearching = !_isSearching;
      if(!_isSearching){
        if (widget.onSearch != null) {
          widget.onSearch!('');
        }
        _searchController.clear();
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appbar_color,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: _isSearching ? _buildSearchBar() : _buildDefaultTitle(),
      leading: _isSearching ? null : _buildButton(),
      leadingWidth: _isSearching ? 0 : 80.0,
      actions: _buildActions(),
    );
  }

  Widget _buildButton(){
    return IconButton(
        onPressed: (){
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.black54,
        )
    );
  }

  Widget _buildDefaultTitle(){
    final String formattedDate = DateFormat('EEEE, MMM d').format(DateTime.now());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today : $formattedDate",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
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
        decoration: const InputDecoration(
          hintText: "Search in the App...",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        ),
        onChanged: (value) {
          if (widget.onSearch != null) {
            widget.onSearch!(value);
          }
        },
        onSubmitted: (value) {
          if (widget.onSearch != null) {
            widget.onSearch!(value);
          }
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
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
    ];
  }
}