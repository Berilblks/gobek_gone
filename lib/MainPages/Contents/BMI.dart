import 'package:flutter/material.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';

// Projenizin renklerini içeren dosyanın yeni adını kullanıyoruz.
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/General/contentBar.dart';

// Renklerin doğru çalışması için, projenizde AppThemeColors sınıfının aşağıdaki gibi tanımlı olduğunu varsayıyoruz.
// Eğer AppThemeColors sınıfınız farklı renk kodlarına sahipse, onları kullanacaktır.
class AppThemeColors {
  static const Color main_background = Color(0xFFF0F4F8); // Açık arka plan
  static const Color primary_color = Color(0xFF4CAF50);    // Ana yeşil
  static const Color icons_color = Color(0xFF388E3C);     // Koyu yeşil
}


class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _gender;

  double _bmiResult = 0.0;
  String _resultText = "";
  Color _resultColor = AppThemeColors.icons_color;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  void _calculateBMI() {
    final double? height = double.tryParse(_heightController.text);
    final double? weight = double.tryParse(_weightController.text);
    final int? age = int.tryParse(_ageController.text);

    // Tüm zorunlu alanların kontrolü
    if (height == null || weight == null || age == null || height <= 0 || weight <= 0) {
      setState(() {
        _resultText = "Please enter valid Height, Weight, and Age.";
        _bmiResult = 0.0;
        _resultColor = Colors.red;
      });
      return;
    }

    // Boyu santimetreden metreye çevir (BMI Formülü: Weight / Height(m)^2)
    final double heightInMeters = height / 100.0;
    final double bmi = weight / (heightInMeters * heightInMeters);

    _bmiResult = double.parse(bmi.toStringAsFixed(2));
    _resultText = _getBMIStatus(_bmiResult);

    setState(() {
      if (_bmiResult < 18.5) {
        _resultColor = Colors.blue;      // Underweight
      } else if (_bmiResult >= 18.5 && _bmiResult < 24.9) {
        _resultColor = AppThemeColors.primary_color; // Normal (Proje ana rengi)
      } else if (_bmiResult >= 25 && _bmiResult < 29.9) {
        _resultColor = Colors.orange;    // Overweight
      } else {
        _resultColor = Colors.red;       // Obese
      }
    });

    FocusScope.of(context).unfocus();
  }

  String _getBMIStatus(double bmi) {
    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return "Normal Weight";
    } else if (bmi >= 25 && bmi < 29.9) {
      return "Overweight";
    } else if (bmi >= 30 && bmi < 34.9) {
      return "Obesity Class I";
    } else if (bmi >= 35 && bmi < 39.9) {
      return "Obesity Class II";
    } else {
      return "Obesity Class III (Morbid)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.main_background, // Arka plan rengi
      appBar: contentBar(),
      endDrawer: const UserSideBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- AGE INPUT (Yaş Girişi) ---
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Age",
                  hintText: "E.g.: 30",
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: AppThemeColors.icons_color),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- GENDER DROPDOWN (Cinsiyet Seçimi) ---
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Gender',
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: AppThemeColors.icons_color),
              ),
              value: _gender,
              hint: const Text('Select Gender'),
              items: _genders.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue;
                });
              },
            ),
            const SizedBox(height: 15),

            // --- HEIGHT INPUT (Boy Girişi) ---
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Height (cm)",
                hintText: "E.g.: 175",
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: AppThemeColors.icons_color),
              ),
            ),
            const SizedBox(height: 15),

            // --- WEIGHT INPUT (Kilo Girişi) ---
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Weight (kg)",
                hintText: "E.g.: 70",
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: AppThemeColors.icons_color),
              ),
            ),
            const SizedBox(height: 30),

            // --- CALCULATE BUTTON (Hesapla Butonu) ---
            ElevatedButton(
              onPressed: _calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeColors.icons_color, // Buton rengi
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "CALCULATE BMI",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),

            // --- RESULT DISPLAY (Sonuç Gösterimi) ---
            if (_bmiResult > 0)
              Column(
                children: [
                  const Text(
                    "Your BMI Result:",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _bmiResult.toString(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: _resultColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _resultText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: _resultColor,
                    ),
                  ),
                ],
              )
            else if (_resultText.isNotEmpty)
              Text(
                _resultText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: _resultColor),
              ),

            const SizedBox(height: 40),

            // --- BMI CATEGORIES TABLE (Kategoriler Tablosu) ---
            _buildBmiTable(context),
          ],
        ),
      ),
    );
  }

  // --- Yardımcı Widget Fonksiyonları ---

  Widget _buildBmiTable(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Köşe yuvarlatma
        side: BorderSide(
          color: Colors.green, // Kenarlık rengi
          width: 3,             // Kenarlık kalınlığı
        ),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "BMI Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                _buildTableRow("BMI", "Status", isHeader: true),
                _buildTableRow("< 18.5", "Underweight", color: Colors.blue),
                _buildTableRow("18.5 - 24.9", "Normal Weight", color: AppThemeColors.primary_color),
                _buildTableRow("25.0 - 29.9", "Overweight", color: Colors.orange),
                _buildTableRow("30.0 - 34.9", "Obesity Class I", color: Colors.red.shade400),
                _buildTableRow("35.0 - 39.9", "Obesity Class II", color: Colors.red.shade600),
                _buildTableRow(">= 40.0", "Obesity Class III", color: Colors.red.shade800),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TableRow metodu isimli parametrelerle hatasız hale getirildi.
  TableRow _buildTableRow(String range, String status, {Color? color, bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey.shade200 : null,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            range,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: color != null && !isHeader ? color : Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            status,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: color != null && !isHeader ? color : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}