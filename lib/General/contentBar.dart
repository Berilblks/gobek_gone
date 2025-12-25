import 'package:flutter/material.dart';
// import 'package:gobek_gone/General/UsersSideBar.dart'; // Bu import AppBar içinde kullanılmıyorsa gerek yok.
// import 'package:gobek_gone/MainPages/ContentPage.dart'; // Bu import da burada gerekli değil.

import 'app_colors.dart';

// contentBar sınıfı artık PreferredSizeWidget arayüzünü uyguluyor.
class contentBar extends StatefulWidget implements PreferredSizeWidget {
  const contentBar({
    super.key,
    // ✨ YENİ: Arama metnini ana sayfaya iletecek callback eklendi.
    this.onSearch,
  });

  // Aranacak metni iletmek için kullanılan fonksiyon tipi
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
        // Arama kapatıldığında arama sonuçlarını temizlemek için boş bir sorgu gönderilebilir.
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

  // geri buton yap
  Widget _buildButton(){
    return IconButton(
        onPressed: (){
          Navigator.pop(context);
        },
        icon: const Icon( // const eklendi
          Icons.arrow_back,
          color: Colors.black54,
        )
    );
  }

  Widget _buildDefaultTitle(){
    return const Row( // const eklendi
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today : Tuesday, Sep 12",
          style: TextStyle(
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
        decoration: const InputDecoration( // const eklendi
          hintText: "Search in the App...",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        ),
        // ✨ GÜNCELLENDİ: Metin her değiştiğinde arama sorgusunu ana sayfaya gönder
        onChanged: (value) {
          if (widget.onSearch != null) {
            widget.onSearch!(value);
          }
        },
        // ✨ GÜNCELLENDİ: Klavye "Gönder" tuşuna basıldığında da sorguyu gönder
        onSubmitted: (value) {
          if (widget.onSearch != null) {
            widget.onSearch!(value);
          }
          // Arama çubuğunu kapatma isteğe bağlıdır, arama sonuçlarını görmek için açık bırakılabilir.
          // _toogleSearch();
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
              // ✅ TAMAM: endDrawer'ı açma komutu doğru yerde ve çalışır durumda.
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
    ];
  }
}