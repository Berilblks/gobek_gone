import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✨ Bunu eklemeyi unutma

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Constructor: Uygulama ilk açıldığında kayıtlı ayarı yükle
  ThemeProvider() {
    _loadTheme();
  }

  // ✨ Temayı değiştiren ve telefona kaydeden fonksiyon
  // Eski toggleTheme'in yerine bunu koyduk
  void toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners(); // Arayüzü hemen güncelle

    // Ayarı telefona kalıcı olarak kaydet
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  // ✨ Telefon belleğinden kayıtlı ayarı okuyan fonksiyon
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Eğer daha önce kaydedilmemişse varsayılan olarak 'false' (light mode) al
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Uygulamanın kullanacağı Tema Verileri
  ThemeData get currentTheme {
    return _isDarkMode
        ? ThemeData.dark().copyWith(
      // Buraya istersen koyu mod için özel renkler ekleyebilirsin
    )
        : ThemeData.light().copyWith(
      // Buraya istersen açık mod için özel renkler ekleyebilirsin
    );
  }
}