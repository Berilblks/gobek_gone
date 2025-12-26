import 'package:flutter/material.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
// Projenizin renklerini içeren dosyanın yeni adını kullanıyoruz.
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/General/contentBar.dart';

// Renklerin doğru çalışması için varsayılan AppThemeColors tanımı
// Gerçek projede bu kısmı silin ve import'u kullanın.
class AppThemeColors {
  static const Color main_background = Color(0xFFF0F4F8);
  static const Color primary_color = Color(0xFF4CAF50);
  static const Color icons_color = Color(0xFF388E3C);
}


class ProgressTracking extends StatefulWidget {
  const ProgressTracking({super.key});

  @override
  State<ProgressTracking> createState() => _ProgressTrackingState();
}

class _ProgressTrackingState extends State<ProgressTracking> {

  // --- MOCK DATA (Gerçek uygulamada veri tabanından gelecek) ---
  final double _mockUserHeightCm = 175.0; // Kullanıcının sabit boyu
  final int _consecutiveDays = 48; // Peş peşe girilen gün sayısı

  // Örnek: Son 6 haftalık kilo verileri
  final List<double> _weightData = [95.0, 94.5, 93.8, 93.0, 92.2, 91.7];

  // --- HESAPLANMIŞ METRİKLER ---
  late double _totalWeightChange;
  late double _totalBmiChange;
  late List<double> _bmiData;

  @override
  void initState() {
    super.initState();
    _calculateMetrics();
  }

  void _calculateMetrics() {
    // 1. Toplam Kilo Değişimi Hesaplama
    final double initialWeight = _weightData.first;
    final double currentWeight = _weightData.last;
    _totalWeightChange = currentWeight - initialWeight; // Pozitif: Aldı, Negatif: Verdi

    // 2. BMI Verilerini ve Toplam Değişimi Hesaplama
    _bmiData = _weightData.map((weight) => _calculateBmi(weight)).toList();

    final double initialBmi = _bmiData.first;
    final double currentBmi = _bmiData.last;
    _totalBmiChange = currentBmi - initialBmi;
  }

  double _calculateBmi(double weight) {
    // BMI = Kilo (kg) / Boy (m)^2
    final double heightInMeters = _mockUserHeightCm / 100.0;
    return double.parse((weight / (heightInMeters * heightInMeters)).toStringAsFixed(2));
  }

  // Metrikleri metin formatına dönüştürme (Örn: -3.3 kg / +1.2 kg)
  String _formatMetric(double value) {
    final String sign = value >= 0 ? "+" : "";
    return "$sign${value.toStringAsFixed(1)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main_background,
      appBar: contentBar(),
      endDrawer: const UserSideBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            // 1. PEŞ PEŞE KULLANIM GÜN SAYISI (STREAK) KUTUSU
            _buildStreakCard(),
            const SizedBox(height: 20),

            // 2. KİLO DEĞİŞİMİ GRAFİĞİ
            _buildWeightProgressCard(),
            const SizedBox(height: 20),

            // 3. VKİ DEĞİŞİMİ GRAFİĞİ
            _buildBmiProgressCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Yardımcı Widget Fonksiyonları ---

  Widget _buildStreakCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: AppThemeColors.icons_color, // Koyu tema rengi
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            const Text(
              'Consecutive Active Days',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.amber, size: 30),
                const SizedBox(width: 10),
                Text(
                  '$_consecutiveDays',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Days',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightProgressCard() {
    final bool isLoss = _totalWeightChange <= 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Köşe yuvarlatma
        side: BorderSide(
          color: Colors.green, // Kenarlık rengi
          width: 2,             // Kenarlık kalınlığı
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAŞLIK VE TOPLAM DEĞİŞİM
            const Text(
              "Weight Progression",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Total Change: ',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                Text(
                  '${_formatMetric(_totalWeightChange)} kg',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isLoss ? AppThemeColors.primary_color : Colors.red, // Kayıp yeşil, Kazanım kırmızı
                  ),
                ),
              ],
            ),
            const Divider(height: 25),

            // GRAFİK YER TUTUCU
            Center(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Kilo Değişimi Grafiği (Line Chart)\n\n[Buraya fl_chart gibi bir kütüphane ile\nhakiki grafik çizilmelidir]",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            // Ek Bilgi
            const SizedBox(height: 10),
            Text(
              "Start: ${_weightData.first} kg, Current: ${_weightData.last} kg",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBmiProgressCard() {
    final bool isDecrease = _totalBmiChange <= 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Köşe yuvarlatma
        side: BorderSide(
          color: Colors.green, // Kenarlık rengi
          width: 2,             // Kenarlık kalınlığı
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAŞLIK VE TOPLAM DEĞİŞİM
            const Text(
              "BMI Progression",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Total Change: ',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                Text(
                  '${_formatMetric(_totalBmiChange)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDecrease ? AppThemeColors.primary_color : Colors.red, // Azalma yeşil
                  ),
                ),
              ],
            ),
            const Divider(height: 25),

            // GRAFİK YER TUTUCU
            Center(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "BMI Değişimi Grafiği (Line Chart)\n\n[Buraya fl_chart gibi bir kütüphane ile\nhakiki grafik çizilmelidir]",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            // Ek Bilgi
            const SizedBox(height: 10),
            Text(
              "Start BMI: ${_bmiData.first}, Current BMI: ${_bmiData.last}",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}