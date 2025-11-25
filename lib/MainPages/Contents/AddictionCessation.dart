import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/AppBar.dart';
import 'package:gobek_gone/General/BottomBar.dart';
import 'package:gobek_gone/General/Fab.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/AI.dart';
import 'package:gobek_gone/MainPages/Badges.dart';
import 'package:gobek_gone/MainPages/ContentPage.dart';
import 'package:gobek_gone/MainPages/Friends.dart';
import 'package:gobek_gone/MainPages/HomeContent.dart';


class AddictioncessationScreen extends StatefulWidget {
  const AddictioncessationScreen({super.key});

  @override
  State<AddictioncessationScreen> createState() => _AddictioncessationScreenState();
}

class _AddictioncessationScreenState extends State<AddictioncessationScreen> {

  int _selectedIndex = 0;

  // Örnek Veriler (Gerçek uygulamada bir veri tabanından gelecektir)
  final DateTime _quitDate = DateTime(2025, 10, 20); // Bağımlılığı bırakma tarihi
  final String _motivationalQuote = "The greatest victory is the victory a person gains over her own self.";
  final String _warning = "If you can't overcome your addictions on your own, please don't hesitate to reach out for support.";

  Duration _timeElapsed = Duration();

  @override
  void initState() {
    super.initState();
    // Zamanı güncellemek için bir zamanlayıcı başlatırız (sadece örnek)
    _updateTime();
    // Gerçek uygulamada, bu zamanlayıcı her saniye veya dakika çalışmalıdır
    // Timer.periodic(const Duration(seconds: 1), (timer) {
    //   _updateTime();
    // });
  }

  void _updateTime() {
    setState(() {
      _timeElapsed = DateTime.now().difference(_quitDate);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Widget nextScreen;

    switch (index) {
      case 0:
        nextScreen = Homecontent();
        break;
      case 1:
        nextScreen = BadgesPage();
        break;
      case 2:
        nextScreen = AIpage();
        break;
      case 3:
        nextScreen = FriendsPage();
        break;
      case 4:
        nextScreen = ContentPage();
        break;
      default:
        nextScreen = Homecontent();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,
      appBar: gobekgAppbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. İlerleme Sayacı Kartı
            _buildProgressCard(context),
            const SizedBox(height: 20),

            // 2. Motive Edici Alıntı
            _buildQuoteCard(context),
            const SizedBox(height: 20),

            // 3. Yardımcı Araçlar ve Kaynaklar Başlığı
            Text(
              "Helpful Tools and Support",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.icons_color,
              ),
            ),
            const SizedBox(height: 10),

            // 4. Araçlar GridView (Örnek Kartlar)
            GridView.count(
              shrinkWrap: true, // ScrollView içinde GridView kullanırken zorunlu
              physics: const NeverScrollableScrollPhysics(), // Scroll'u devre dışı bırak
              crossAxisCount: 2,
              crossAxisSpacing: 15.0,
              mainAxisSpacing: 15.0,
              children: [
                _buildToolCard(context, Icons.self_improvement, "Breathing Exercise", Colors.green),
                _buildToolCard(context, Icons.phone, "Acil Destek", Colors.red),
              ],
            ),

            _buildWarning(context),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: Text(
                textAlign: TextAlign.center,
                  "We're always here for you.",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: gobekgBottombar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
      ),
      floatingActionButton: buildCenterFloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AIpage()));
        },
        backgroundColor: AppColors.AI_color,
        icon: CupertinoIcons.circle_grid_hex,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    );
  }

  // --- Yardımcı Widget Fonksiyonları ---

  Widget _buildProgressCard(BuildContext context) {
    String days = _timeElapsed.inDays.toString();
    String hours = (_timeElapsed.inHours % 24).toString();
    String minutes = (_timeElapsed.inMinutes % 60).toString();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: AppColors.bottombar_color.withOpacity(0.9), // Koyu arka plan
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            const Text(
              'Your Salvation Period',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              // Formatlanmış süre gösterimi
              '$days Day , $hours Hour , $minutes Minute',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Drop Date: ${_quitDate.day}.${_quitDate.month}.${_quitDate.year}',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.format_quote, size: 30, color: AppColors.icons_color),
            const SizedBox(height: 10),
            Text(
              _motivationalQuote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarning(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.warning_amber, size: 30, color: Colors.red),
            const SizedBox(height: 10),
            Text(
              _warning,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, IconData icon, String title, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          if (title == "Breathing Exercise") {
            _showBreathingDialog(context);
          }
          else if (title == "Acil Destek") {
            _showEmergencyDialog(context);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showBreathingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Take a Deep Breath",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Calm Down with the 4-7-8 Technique:',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 10),
                Text('1. Exhale all the air from your mouth.'),
                Text('2. Breathe in slowly through your nose (4 seconds).'),
                Text('3. Hold your breath (7 seconds).'),
                Text('4. Release it with a "shhh" sound from your mouth (8 seconds).'),
                SizedBox(height: 15),
                Text('Repeat this cycle 3 times'),
                SizedBox(height: 10),
                Divider(),
                Text(
                  'Tip: This helps calm the nervous system.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CLOSE'),
              onPressed: () {
                Navigator.of(context).pop(); // Mesaj kutusunu kapatır
              },
            ),
          ],
        );
      },
    );
  }
  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Emergency Support and Assistance Resources",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Don't hesitate to get help. You are not alone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
                ),
                SizedBox(height: 20),

                // Acil Arama Numarası
                Text(
                  'EMERGENCY SUPPORT LINE:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                Text(
                  '121',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                SizedBox(height: 20),

                // Web Sitesi Linki
                Text(
                  'Online Support Resource:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'bırakabilirsin.org',
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
                Text(
                  '(When you click on this link, you will be directed to an external browser.)',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CLOSE'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}