import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:gobek_gone/General/contentBar.dart';
import 'package:gobek_gone/General/app_colors.dart';

// Renkler (Varsayım)
class AppThemeColors {
  static const Color main_background = Color(0xFFF0F4F8);
  static const Color primary_color = Color(0xFF4CAF50);
  static const Color icons_color = Color(0xFF388E3C);
  // Eski taslaktan gelen varsayım (AppColors.bottombar_color)
  static const Color bottombar_color = Color(0xFF424242);
}

class AddictionCessation extends StatefulWidget {
  const AddictionCessation({super.key});

  @override
  State<AddictionCessation> createState() => _AddictionCessationState();
}

class _AddictionCessationState extends State<AddictionCessation> {

  // --- STATE DEĞİŞKENLERİ ---

  bool _isLoading = true;

  // Sigara
  DateTime? _quitDateCigarette;
  double _dailyConsumptionCigarette = 0.0;
  double _packPriceCigarette = 0.0;
  bool _hasEnteredDetailsCigarette = false;
  bool _isEditingCigarette = false;

  // Alkol
  DateTime? _quitDateAlcohol;
  double _dailyConsumptionAlcohol = 0.0;
  bool _hasEnteredDetailsAlcohol = false;
  bool _isEditingAlcohol = false;

  // Entegre Edilen Statik Veriler (Eski taslaktan)
  final String _motivationalQuote = "The greatest victory is the victory a person gains over her own self.";
  final String _warning = "If you can't overcome your addictions on your own, please don't hesitate to reach out for support.";

  final DateTime _now = DateTime.now();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  TextEditingController? _priceControllerCigarette;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _priceControllerCigarette?.dispose();
    super.dispose();
  }

  // --- VERİ YÜKLEME VE İNİTIALIZATION (Aynı) ---

  Future<void> _initializeData() async {
    await _loadData();
    _priceControllerCigarette = TextEditingController(text: _packPriceCigarette == 0.0 ? '' : _packPriceCigarette.toStringAsFixed(2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final quitDateCig = prefs.getInt('quitDateCigarette');
    _quitDateCigarette = quitDateCig != null ? DateTime.fromMillisecondsSinceEpoch(quitDateCig) : null;
    _dailyConsumptionCigarette = prefs.getDouble('dailyConsumptionCigarette') ?? 0.0;
    _packPriceCigarette = prefs.getDouble('packPriceCigarette') ?? 0.0;
    _hasEnteredDetailsCigarette = prefs.getBool('hasEnteredDetailsCigarette') ?? false;

    final quitDateAlc = prefs.getInt('quitDateAlcohol');
    _quitDateAlcohol = quitDateAlc != null ? DateTime.fromMillisecondsSinceEpoch(quitDateAlc) : null;
    _dailyConsumptionAlcohol = prefs.getDouble('dailyConsumptionAlcohol') ?? 0.0;
    _hasEnteredDetailsAlcohol = prefs.getBool('hasEnteredDetailsAlcohol') ?? false;
  }

  Future<void> _saveData(String type) async {
    final prefs = await SharedPreferences.getInstance();
    if (type == 'Cigarette') {
      if (_quitDateCigarette != null) {
        prefs.setInt('quitDateCigarette', _quitDateCigarette!.millisecondsSinceEpoch);
      } else {
        prefs.remove('quitDateCigarette');
      }
      prefs.setDouble('dailyConsumptionCigarette', _dailyConsumptionCigarette);
      prefs.setDouble('packPriceCigarette', _packPriceCigarette);
      prefs.setBool('hasEnteredDetailsCigarette', _hasEnteredDetailsCigarette);
    } else if (type == 'Alcohol') {
      if (_quitDateAlcohol != null) {
        prefs.setInt('quitDateAlcohol', _quitDateAlcohol!.millisecondsSinceEpoch);
      } else {
        prefs.remove('quitDateAlcohol');
      }
      prefs.setDouble('dailyConsumptionAlcohol', _dailyConsumptionAlcohol);
      prefs.setBool('hasEnteredDetailsAlcohol', _hasEnteredDetailsAlcohol);
    }
  }

  // --- HESAPLAMALAR VE FORMATLAR (Aynı) ---

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppThemeColors.primary_color,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "Start your journey!";

    final int days = duration.inDays;
    final int hours = duration.inHours % 24;
    final int minutes = duration.inMinutes % 60;

    final String dayString = days > 0 ? "$days Days, " : "";
    final String hourString = hours > 0 ? "$hours Hours, " : "";

    return "${dayString}${hourString}${minutes} Minutes";
  }

  String _calculateSavings(DateTime? quitDate, double dailyConsumption, double unitPrice, String type) {
    if (type != 'Cigarette' || quitDate == null || dailyConsumption == 0 || unitPrice == 0) {
      return "";
    }

    final Duration duration = _now.difference(quitDate);
    final double daysElapsed = duration.inDays.toDouble();

    final double totalSaved = daysElapsed * dailyConsumption * unitPrice;

    return _currencyFormat.format(totalSaved);
  }

  void _confirmReset(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Are you sure you want to reset?",
            style: TextStyle(color: Colors.red.shade700),
          ),
          content: Text(
            "If you reset the counter, it means you have relapsed and all your progress for $type will be lost.",
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("NO, I'M SAFE", style: TextStyle(color: AppThemeColors.primary_color)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade400,
                foregroundColor: Colors.black87,
              ),
              child: const Text("YES, RESET"),
              onPressed: () {
                setState(() {
                  if (type == 'Cigarette') {
                    _quitDateCigarette = null;
                    _hasEnteredDetailsCigarette = false;
                    _isEditingCigarette = false;
                    _priceControllerCigarette?.text = '';
                  } else if (type == 'Alcohol') {
                    _quitDateAlcohol = null;
                    _hasEnteredDetailsAlcohol = false;
                    _isEditingAlcohol = false;
                  }
                });
                _saveData(type);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- WIDGET YAPILANDIRMASI (MAIN BUILD) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.main_background,
      appBar: contentBar(),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemeColors.icons_color))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            // 1. BAĞIMLILIK TAKİP KUTULARI
            _buildTrackerTile(context, type: "Cigarette"),
            const SizedBox(height: 20),
            _buildTrackerTile(context, type: "Alcohol"),
            const SizedBox(height: 20),

            // 2. MOTİVASYON ALINTISI (ENTEGRE EDİLDİ)
            _buildQuoteCard(context),
            const SizedBox(height: 20),

            // 3. YARDIMCI ARAÇLAR BAŞLIĞI (ENTEGRE EDİLDİ)
            Text(
              "Helpful Tools and Support",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppThemeColors.icons_color,
              ),
            ),
            const SizedBox(height: 10),

            // 4. ARAÇLAR GRIDVIEW (ENTEGRE EDİLDİ)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15.0,
              mainAxisSpacing: 15.0,
              children: [
                _buildToolCard(context, Icons.self_improvement, "Breathing Exercise", Colors.green),
                _buildToolCard(context, Icons.phone, "Emergency Support", Colors.red),
              ],
            ),

            // 5. UYARI VE NOT (ENTEGRE EDİLDİ)
            _buildWarning(context),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                textAlign: TextAlign.center,
                "We're always here for you.",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ENTEGRE EDİLEN YARDIMCI WIDGET'LAR VE METOTLAR ---

  Widget _buildQuoteCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.format_quote, size: 30, color: AppThemeColors.icons_color),
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
          else if (title == "Emergency Support") {
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
                Navigator.of(context).pop();
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
                  'Call: 112',
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

  // --- BAĞIMLILIK TAKİP METOTLARI (Aynı) ---

  Widget _buildTrackerTile(BuildContext context, {required String type}) {
    // Verileri doğrudan State'ten çekme
    final bool isCigarette = type == 'Cigarette';

    // Verileri tipe göre çekme
    final DateTime? quitDate = isCigarette ? _quitDateCigarette : _quitDateAlcohol;
    final double dailyConsumption = isCigarette ? _dailyConsumptionCigarette : _dailyConsumptionAlcohol;
    final double unitPrice = isCigarette ? _packPriceCigarette : 0.0;
    final bool hasEnteredDetails = isCigarette ? _hasEnteredDetailsCigarette : _hasEnteredDetailsAlcohol;
    final bool isEditing = isCigarette ? _isEditingCigarette : _isEditingAlcohol;
    final TextEditingController? priceController = isCigarette ? _priceControllerCigarette : null;

    // Etiketler
    final String title = isCigarette ? "Cigarette Cessation" : "Alcohol Cessation";
    final IconData icon = isCigarette ? Icons.smoking_rooms_outlined : Icons.local_bar_outlined;
    final String consumptionLabel = isCigarette ? "Daily Packs" : "Daily Alcohol Units";
    final String priceLabel = isCigarette ? "Pack Price (\$)" : "Unit Price (\$)" ;

    // Kontroller
    final bool inputsValid = isCigarette
        ? (quitDate != null && dailyConsumption > 0 && unitPrice > 0)
        : (quitDate != null && dailyConsumption > 0);
    final bool isTracking = quitDate != null && hasEnteredDetails;
    final Duration elapsed = isTracking ? _now.difference(quitDate!) : Duration.zero;
    final String totalSavings = _calculateSavings(quitDate, dailyConsumption, unitPrice, type);

    final String initialText = isCigarette
        ? "No Smoking Addiction."
        : "No Alcohol Addiction";

    // --- Aksiyon Metotları ---

    void onDateSelected(DateTime date) {
      setState(() {
        if (isCigarette) { _quitDateCigarette = date; } else { _quitDateAlcohol = date; }
      });
      _saveData(type);
    }

    void onConsumptionChanged(double newValue) {
      setState(() {
        if (isCigarette) { _dailyConsumptionCigarette = newValue; } else { _dailyConsumptionAlcohol = newValue; }
      });
      _saveData(type);
    }

    void onPriceChanged(double newPrice) {
      if (isCigarette) {
        setState(() { _packPriceCigarette = newPrice; });
        _saveData(type);
      }
    }

    void onToggleEdit(bool value) {
      setState(() {
        if (isCigarette) { _isEditingCigarette = value; } else { _isEditingAlcohol = value; }
        if (value && isCigarette) { priceController?.text = unitPrice.toStringAsFixed(2); }
      });
    }

    void onSaveDetails() {
      if (inputsValid) {
        setState(() {
          if (isCigarette) {
            _hasEnteredDetailsCigarette = true;
            _isEditingCigarette = false;
          } else {
            _hasEnteredDetailsAlcohol = true;
            _isEditingAlcohol = false;
          }
        });
        _saveData(type);
      }
    }

    // --- Widget Yapısı ---

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isEditing || !hasEnteredDetails && quitDate == null,

          collapsedIconColor: AppThemeColors.icons_color,
          iconColor: AppThemeColors.primary_color,

          leading: Icon(icon, color: AppThemeColors.icons_color, size: 30),

          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppThemeColors.icons_color,
            ),
          ),

          subtitle: isTracking
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  _formatDuration(elapsed),
                  style: TextStyle(color: AppThemeColors.primary_color, fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              if (totalSavings.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Saved: $totalSavings",
                    style: TextStyle(color: AppThemeColors.icons_color, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
            ],
          )
              : Text(
            quitDate == null
                ? initialText
                : "Tap to enter details",
            style: const TextStyle(color: Colors.red),
          ),

          // Children listesi
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // --- 1. DÜZENLEME MODU / VERİ GÖSTERİMİ ---
                  if (!isEditing && isTracking)
                    _buildTrackingSummary(
                      quitDate: quitDate!,
                      dailyConsumption: dailyConsumption,
                      unitPrice: unitPrice,
                      consumptionLabel: consumptionLabel,
                      priceLabel: priceLabel,
                      type: type,
                    )
                  else if (quitDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            "Quit Date: ${DateFormat('dd/MM/yyyy').format(quitDate)} (Fixed)",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),

                        // Tüketim Girişi
                        _buildConsumptionInput(
                          label: consumptionLabel,
                          value: dailyConsumption,
                          onChanged: onConsumptionChanged,
                        ),
                        const SizedBox(height: 15),

                        // Fiyat Girişi (Sadece Sigara için)
                        if (isCigarette) ...[
                          _buildPriceInput(
                            label: priceLabel,
                            value: unitPrice,
                            onChanged: onPriceChanged,
                            controller: priceController!,
                          ),
                          const SizedBox(height: 25),
                        ],

                        // KAYDET BUTONU
                        ElevatedButton(
                          onPressed: inputsValid ? onSaveDetails : null,
                          child: Text(isTracking ? "SAVE CHANGES" : "SAVE DETAILS / START TRACKING"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: inputsValid ? AppThemeColors.icons_color : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ],
                    ),

                  // --- 2. TARİH SEÇİM BUTONU (Sadece tarih seçilmediyse göster) ---
                  if (quitDate == null)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final selectedDate = await _selectDate(context);
                        if (selectedDate != null) {
                          onDateSelected(selectedDate);
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text("Select Quit Date"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeColors.primary_color,
                        foregroundColor: Colors.white,
                      ),
                    ),

                  // --- 3. DÜZENLE / SIFIRLA BUTONLARI ---
                  if (isTracking && !isEditing) ...[
                    const SizedBox(height: 25),

                    // Düzenle Butonu
                    ElevatedButton.icon(
                      onPressed: () => onToggleEdit(true),
                      icon: const Icon(Icons.edit_note),
                      label: const Text("EDIT DETAILS"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Sıfırla Butonu
                    ElevatedButton.icon(
                      onPressed: () => _confirmReset(context, type),
                      icon: const Icon(Icons.refresh),
                      label: const Text("I RELAPSED / RESET PROGRESS"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Veri Kaydedildikten Sonra Gösterilen Özet Widget'ı (Aynı)
  Widget _buildTrackingSummary({
    required DateTime quitDate,
    required double dailyConsumption,
    required String consumptionLabel,
    required String priceLabel,
    required String type,
    double unitPrice = 0.0,
  }) {
    final bool isCigarette = type == 'Cigarette';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quit Date:",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        Text(
          DateFormat('dd MMMM yyyy').format(quitDate),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppThemeColors.icons_color),
        ),
        const Divider(height: 20),

        Text(
          consumptionLabel,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        Text(
          "${dailyConsumption.toStringAsFixed(1)} $consumptionLabel",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Divider(height: 20),

        // Sadece Sigara için Fiyat Özeti gösteriliyor
        if (isCigarette) ...[
          Text(
            priceLabel,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          Text(
            "\$${unitPrice.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 25),
        ],
      ],
    );
  }

  // Tüketim Girişi (Arttırma/Azaltma) - (Aynı)
  Widget _buildConsumptionInput({
    required String label,
    required double value,
    required Function(double) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle, color: AppThemeColors.icons_color),
              onPressed: () {
                if (value > 0) {
                  onChanged(value - 0.5);
                }
              },
            ),

            SizedBox(
              width: 50,
              child: Text(
                value.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            IconButton(
                icon: Icon(Icons.add_circle, color: AppThemeColors.icons_color),
                onPressed: () {
                  onChanged(value + 0.5);
                }
            ),
          ],
        ),
      ],
    );
  }

  // Fiyat Girişi (TextField) - (Aynı)
  Widget _buildPriceInput({
    required String label,
    required double value,
    required Function(double) onChanged,
    required TextEditingController controller,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        SizedBox(
          width: 120,
          child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "0.00",
                prefixText: '\$',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (text) {
                final double? newPrice = double.tryParse(text);
                if (newPrice != null) {
                  onChanged(newPrice);
                } else if (text.isEmpty) {
                  onChanged(0.0);
                }
              },
              onTapOutside: (event) {
                final double? price = double.tryParse(controller.text);
                if (price != null) {
                  controller.text = price.toStringAsFixed(2);
                } else if (controller.text.isNotEmpty) {
                  controller.text = '0.00';
                }
                FocusManager.instance.primaryFocus?.unfocus();
              }
          ),
        ),
      ],
    );
  }
}