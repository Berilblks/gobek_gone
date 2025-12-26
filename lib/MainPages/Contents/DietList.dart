import 'package:flutter/material.dart';
import 'package:gobek_gone/General/UsersSideBar.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/General/contentBar.dart';

// Renklerin doğru çalışması için varsayılan AppThemeColors tanımı
class AppThemeColors {
  static const Color main_background = Color(0xFFF0F4F8);
  static const Color primary_color = Color(0xFF4CAF50);
  static const Color icons_color = Color(0xFF388E3C);
}

class DietList extends StatefulWidget {
  const DietList({super.key});

  @override
  State<DietList> createState() => _DietListState();
}

class _DietListState extends State<DietList> {

  // Haftanın günleri için farklı öğün planları
  final Map<String, Map<String, List<String>>> _weeklyDietPlan = const {
    'Monday': {
      'Breakfast': ['Oatmeal (1/2 cup) with berries and nuts', 'Green Tea (1 cup)'],
      'Morning Snack': ['1 small banana', '5 almonds'],
      'Lunch': ['Grilled Chicken Salad with vinaigrette', 'Small bowl of vegetable soup'],
      'Afternoon Snack': ['Cottage Cheese (1/2 cup)', 'Cherry Tomatoes'],
      'Dinner': ['Baked Salmon (150g)', 'Steamed asparagus', 'Quinoa (1/2 cup)'],
    },
    'Tuesday': {
      'Breakfast': ['2 Scrambled Eggs with spinach', 'Whole-wheat toast (1 slice)'],
      'Morning Snack': ['Protein bar (low sugar)'],
      'Lunch': ['Turkey and whole grain sandwich', 'Carrot sticks'],
      'Afternoon Snack': ['Plain Greek yogurt (1 cup)'],
      'Dinner': ['Lean Beef Stir-fry with bell peppers and onion', 'Brown rice (1/2 cup)'],
    },
    'Wednesday': {
      'Breakfast': ['Smoothie (Spinach, banana, almond milk)', 'A scoop of protein powder'],
      'Morning Snack': ['A handful of walnuts'],
      'Lunch': ['Leftover Beef Stir-fry', 'Side salad'],
      'Afternoon Snack': ['Hard-boiled egg (1)', 'Orange (1)'],
      'Dinner': ['Lentil soup (2 cups)', 'Whole-wheat pita bread (1)'],
    },
    'Thursday': {
      'Breakfast': ['Whole-wheat pancakes (2) with fruit', 'Small amount of maple syrup'],
      'Morning Snack': ['Apple slices with peanut butter'],
      'Lunch': ['Tuna salad (no mayo) on lettuce cups', 'A small cucumber'],
      'Afternoon Snack': ['Edamame (shelled, 1/2 cup)'],
      'Dinner': ['Chicken breast with sweet potato and green beans'],
    },
    'Friday': {
      'Breakfast': ['Greek yogurt with honey and granola', 'Coffee (black)'],
      'Morning Snack': ['Grapes (small bunch)'],
      'Lunch': ['Vegetarian Chili (bean-based)', 'Cornbread (small piece)'],
      'Afternoon Snack': ['Small piece of dark chocolate (70%+)'],
      'Dinner': ['Homemade Pizza on cauliflower crust (moderate cheese)'],
    },
    'Saturday': {
      'Breakfast': ['3 Egg white omelet with vegetables', 'Avocado (1/4)'],
      'Morning Snack': ['Small fruit salad'],
      'Lunch': ['Leftover Pizza (1-2 slices)', 'Large mixed salad'],
      'Afternoon Snack': ['Protein shake'],
      'Dinner': ['Sushi (sashimi or simple rolls)', 'Miso soup'],
    },
    'Sunday': {
      'Breakfast': ['Smoked salmon and cream cheese on whole-grain bagel', 'Decaf coffee'],
      'Morning Snack': ['Pear (1)'],
      'Lunch': ['Large bowl of chicken noodle soup', 'Side of whole-wheat crackers'],
      'Afternoon Snack': ['Carrot cake protein ball'],
      'Dinner': ['Grilled steak (lean cut)', 'Baked potato', 'Steamed spinach'],
    },
  };

  // Haftalık Alışveriş Listesi ve Durumları
  final Map<String, bool> _shoppingList = {
    'Chicken Breast (500g)': false,
    'Salmon Fillets (300g)': false,
    'Lean Steak (300g)': false,
    'Eggs (1 dozen)': false,
    'Oatmeal (1 box)': false,
    'Spinach and Mushrooms': false,
    'Mixed Nuts (Almonds, Walnuts)': false,
    'Fresh Berries (Blueberries, Strawberries)': false,
    'Greek Yogurt (large tub)': false,
    'Whole Wheat Bread/Toast': false,
    'Sweet Potatoes (2 pcs)': false,
    'Broccoli and Asparagus': false,
    'Quinoa (small bag)': false,
    'Lentils (1 bag)': false,
    'Apples and Bananas': false,
  };

  @override
  Widget build(BuildContext context) {
    final List<String> weekDays = _weeklyDietPlan.keys.toList();

    return Scaffold(
      backgroundColor: AppThemeColors.main_background,
      appBar: contentBar(),
      endDrawer: const UserSideBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- 1. HAFTALIK DİYET LİSTESİ ---
            Text(
              "Your 7-Day Meal Breakdown",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppThemeColors.icons_color,
              ),
            ),
            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weekDays.length,
              itemBuilder: (context, index) {
                final day = weekDays[index];
                final dailyMeals = _weeklyDietPlan[day]!;

                return _buildDailyMealTile(day, dailyMeals);
              },
            ),
            const SizedBox(height: 40),

            // --- 2. HAFTALIK ALIŞVERİŞ LİSTESİ ---
            Text(
              "Weekly Shopping List",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppThemeColors.icons_color,
              ),
            ),
            const SizedBox(height: 15),

            _buildShoppingList(),
          ],
        ),
      ),
    );
  }

  // Günlük öğünleri listeleyen ExpansionTile
  Widget _buildDailyMealTile(String day, Map<String, List<String>> meals) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: AppThemeColors.icons_color,
          iconColor: AppThemeColors.primary_color,

          title: Text(
            day,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppThemeColors.icons_color,
            ),
          ),

          // Günün tüm öğünlerini alt alta listeler
          children: meals.entries.map((mealEntry) {
            return ListTile(
              title: Text(
                mealEntry.key, // Öğün Adı (Breakfast, Lunch, Dinner)
                style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeColors.primary_color),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mealEntry.value.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4),
                    child: Text('• $item', style: TextStyle(fontSize: 15)),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // İnteraktif Alışveriş Listesi
  Widget _buildShoppingList() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _shoppingList.keys.map((item) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            title: Text(
              item,
              style: TextStyle(
                color: _shoppingList[item]! ? Colors.grey : Colors.black,
                decoration: _shoppingList[item]! ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            value: _shoppingList[item],
            activeColor: AppThemeColors.primary_color,
            onChanged: (bool? newValue) {
              setState(() {
                _shoppingList[item] = newValue!;
              });
            },
          ),
        );
      }).toList(),
    );
  }
}