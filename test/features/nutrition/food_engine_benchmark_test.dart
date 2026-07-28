@Timeout(Duration(minutes: 5))
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/core/services/openai_service_impl.dart';

void main() {
  group('AI Food Engine 100 Foods Benchmark Test Suite', () {
    final aiService = OpenAIServiceImpl();

    final List<Map<String, dynamic>> hundredTestFoods = [
      // ── Maharashtra (30 Dishes) ──
      {'query': 'Kanda Poha', 'category': 'Maharashtra Breakfast', 'expectedCals': 260},
      {'query': 'Thalipeeth with Curd', 'category': 'Maharashtra Breakfast', 'expectedCals': 280},
      {'query': 'Sabudana Khichdi', 'category': 'Maharashtra Breakfast', 'expectedCals': 340},
      {'query': 'Misal Pav', 'category': 'Maharashtra Street Food', 'expectedCals': 380},
      {'query': 'Upma Sprouts', 'category': 'Maharashtra Breakfast', 'expectedCals': 240},
      {'query': 'Ukadpendi', 'category': 'Maharashtra Traditional', 'expectedCals': 220},
      {'query': 'Sheera Kesari', 'category': 'Maharashtra Sweet', 'expectedCals': 310},
      {'query': 'Pithla Bhakri', 'category': 'Maharashtra Lunch', 'expectedCals': 380},
      {'query': 'Varan Bhaat with Toop', 'category': 'Maharashtra Lunch', 'expectedCals': 380},
      {'query': 'Bharli Vangi', 'category': 'Maharashtra Lunch', 'expectedCals': 320},
      {'query': 'Matki Usal', 'category': 'Maharashtra High Protein', 'expectedCals': 290},
      {'query': 'Zunka Bhakri', 'category': 'Maharashtra Traditional', 'expectedCals': 360},
      {'query': 'Amti Bhaat', 'category': 'Maharashtra Lunch', 'expectedCals': 350},
      {'query': 'Katachi Amti', 'category': 'Maharashtra Festive', 'expectedCals': 180},
      {'query': 'Masale Bhaat', 'category': 'Maharashtra Festive', 'expectedCals': 370},
      {'query': 'Methi Pithla Nachni Bhakri', 'category': 'Maharashtra Healthy', 'expectedCals': 340},
      {'query': 'Gavran Chicken Rassa', 'category': 'Maharashtra Non-Veg', 'expectedCals': 420},
      {'query': 'Kolhapuri Mutton Rassa', 'category': 'Maharashtra Non-Veg', 'expectedCals': 480},
      {'query': 'Kombdi Vade', 'category': 'Maharashtra Non-Veg', 'expectedCals': 520},
      {'query': 'Surmai Fish Fry', 'category': 'Maharashtra Seafood', 'expectedCals': 310},
      {'query': 'Batata Vada', 'category': 'Maharashtra Snack', 'expectedCals': 210},
      {'query': 'Kanda Bhaji', 'category': 'Maharashtra Snack', 'expectedCals': 240},
      {'query': 'Sabudana Vada', 'category': 'Maharashtra Snack', 'expectedCals': 320},
      {'query': 'Bhakarwadi', 'category': 'Maharashtra Snack', 'expectedCals': 290},
      {'query': 'Puran Poli with Ghee', 'category': 'Maharashtra Sweet', 'expectedCals': 360},
      {'query': 'Ukdiche Modak', 'category': 'Maharashtra Festive Sweet', 'expectedCals': 220},
      {'query': 'Shrikhand Puri', 'category': 'Maharashtra Sweet', 'expectedCals': 450},
      {'query': 'Vada Pav', 'category': 'Maharashtra Street Food', 'expectedCals': 290},
      {'query': 'Pav Bhaji', 'category': 'Maharashtra Street Food', 'expectedCals': 410},
      {'query': 'Solkadhi', 'category': 'Maharashtra Digestive Drink', 'expectedCals': 60},

      // ── South India (15 Dishes) ──
      {'query': 'Steamed Idli with Sambar', 'category': 'South India Breakfast', 'expectedCals': 210},
      {'query': 'Crispy Masala Dosa', 'category': 'South India Breakfast', 'expectedCals': 320},
      {'query': 'Ven Pongal with Chutney', 'category': 'South India Breakfast', 'expectedCals': 300},
      {'query': 'Curd Rice with Pomegranate', 'category': 'South India Comfort', 'expectedCals': 240},
      {'query': 'Rasam Rice', 'category': 'South India Light', 'expectedCals': 220},
      {'query': 'Bisibelebath', 'category': 'Karnataka Specialty', 'expectedCals': 360},
      {'query': 'Ragi Mudde with Saaru', 'category': 'Karnataka Superfood', 'expectedCals': 280},
      {'query': 'Akki Roti', 'category': 'Karnataka Specialty', 'expectedCals': 260},
      {'query': 'Neer Dosa with Coconut Chutney', 'category': 'Karnataka Light', 'expectedCals': 210},
      {'query': 'Mysore Masala Dosa', 'category': 'South India Classic', 'expectedCals': 380},
      {'query': 'Malabar Parotta with Chicken Curry', 'category': 'Kerala Specialty', 'expectedCals': 550},
      {'query': 'Chicken Chettinad', 'category': 'Tamil Nadu Spicy', 'expectedCals': 410},
      {'query': 'Meda Vada', 'category': 'South India Snack', 'expectedCals': 230},
      {'query': 'Filter Coffee', 'category': 'South India Beverage', 'expectedCals': 90},
      {'query': 'Hyderabadi Veg Biryani', 'category': 'Telangana/AP Specialty', 'expectedCals': 430},

      // ── North India & Punjab (15 Dishes) ──
      {'query': 'Chole Bhature', 'category': 'North India Classic', 'expectedCals': 580},
      {'query': 'Makki Ki Roti Sarson Ka Saag', 'category': 'Punjab Winter Classic', 'expectedCals': 390},
      {'query': 'Rajma Chawal', 'category': 'North India Comfort', 'expectedCals': 370},
      {'query': 'Dal Makhani with Naan', 'category': 'North India Rich', 'expectedCals': 520},
      {'query': 'Butter Chicken', 'category': 'North India Non-Veg', 'expectedCals': 460},
      {'query': 'Paneer Butter Masala', 'category': 'North India Veg', 'expectedCals': 410},
      {'query': 'Aloo Paratha with Butter', 'category': 'Punjab Breakfast', 'expectedCals': 350},
      {'query': 'Kadai Paneer', 'category': 'North India Veg', 'expectedCals': 360},
      {'query': 'Kadhi Pakora', 'category': 'North India Comfort', 'expectedCals': 310},
      {'query': 'Tandoori Chicken', 'category': 'North India Grilled', 'expectedCals': 280},
      {'query': 'Paneer Tikka', 'category': 'North India Starter', 'expectedCals': 260},
      {'query': 'Palak Paneer', 'category': 'North India Healthy', 'expectedCals': 290},
      {'query': 'Sweet Lassi', 'category': 'Punjab Beverage', 'expectedCals': 210},
      {'query': 'Gulab Jamun (2 pcs)', 'category': 'Indian Dessert', 'expectedCals': 300},
      {'query': 'Rasgulla (2 pcs)', 'category': 'Indian Dessert', 'expectedCals': 220},

      // ── Gujarat (10 Dishes) ──
      {'query': 'Khaman Dhokla', 'category': 'Gujarat Breakfast', 'expectedCals': 180},
      {'query': 'Methi Thepla', 'category': 'Gujarat Breakfast', 'expectedCals': 210},
      {'query': 'Undhiyu', 'category': 'Gujarat Winter Specialty', 'expectedCals': 340},
      {'query': 'Khandvi', 'category': 'Gujarat Snack', 'expectedCals': 160},
      {'query': 'Handvo', 'category': 'Gujarat Snack', 'expectedCals': 240},
      {'query': 'Fafda Jalebi', 'category': 'Gujarat Festive', 'expectedCals': 480},
      {'query': 'Dal Dhokli', 'category': 'Gujarat One-Pot Meal', 'expectedCals': 350},
      {'query': 'Gujarati Kadhi with Khichdi', 'category': 'Gujarat Comfort', 'expectedCals': 290},
      {'query': 'Khakhra Crisp', 'category': 'Gujarat Healthy Snack', 'expectedCals': 140},
      {'query': 'Sev Tamatar Nu Shaak', 'category': 'Gujarat Curry', 'expectedCals': 260},

      // ── Global, Fast Food & Healthy Fitness Meals (30 Dishes) ──
      {'query': 'Grilled Chicken Breast with Steamed Rice', 'category': 'Fitness High Protein', 'expectedCals': 420},
      {'query': 'Scrambled Eggs with Whole Wheat Toast', 'category': 'Fitness Breakfast', 'expectedCals': 330},
      {'query': 'Oatmeal Porridge with Banana & Almonds', 'category': 'Fitness Fiber Rich', 'expectedCals': 290},
      {'query': 'Greek Yogurt Parfait with Berries', 'category': 'Fitness High Protein', 'expectedCals': 210},
      {'query': 'Whey Protein Smoothie Shake', 'category': 'Fitness Recovery', 'expectedCals': 220},
      {'query': 'Boiled Eggs (3 Large)', 'category': 'Fitness High Protein', 'expectedCals': 230},
      {'query': 'Avocado Toast with Poached Egg', 'category': 'Global Healthy', 'expectedCals': 340},
      {'query': 'Quinoa Veggie Salad bowl', 'category': 'Global Healthy', 'expectedCals': 260},
      {'query': 'Grilled Salmon Filet with Broccoli', 'category': 'Global High Protein', 'expectedCals': 380},
      {'query': 'Tofu Veg Stir-Fry Noodles', 'category': 'Asian Vegan', 'expectedCals': 360},
      {'query': 'Classic Margherita Pizza (2 Slices)', 'category': 'Italian Classic', 'expectedCals': 440},
      {'query': 'Penne Pasta in Creamy White Sauce', 'category': 'Italian Classic', 'expectedCals': 490},
      {'query': 'Chicken Veggie Burger', 'category': 'Fast Food', 'expectedCals': 430},
      {'query': 'French Fries (Medium)', 'category': 'Fast Food Side', 'expectedCals': 360},
      {'query': 'Veg Steamed Momos with Spicy Chutney', 'category': 'Street Food', 'expectedCals': 220},
      {'query': 'Chicken Hakka Noodles', 'category': 'Indo-Chinese', 'expectedCals': 420},
      {'query': 'Veg Manchurian Gravy with Fried Rice', 'category': 'Indo-Chinese', 'expectedCals': 480},
      {'query': 'Caesar Salad with Grilled Chicken', 'category': 'Global Healthy', 'expectedCals': 310},
      {'query': 'Spaghetti Bolognese', 'category': 'Italian Classic', 'expectedCals': 460},
      {'query': 'Sushi Rolls (6 pcs Salmon)', 'category': 'Japanese Classic', 'expectedCals': 320},
      {'query': 'Mexican Burrito Bowl with Guacamole', 'category': 'Mexican Classic', 'expectedCals': 510},
      {'query': 'Fruit Salad Bowl (Apple, Banana, Papaya)', 'category': 'Fresh Fruit', 'expectedCals': 140},
      {'query': 'Sprouted Moong Salad', 'category': 'High Fiber Snack', 'expectedCals': 160},
      {'query': 'Mixed Nuts & Dried Figs Handful', 'category': 'Healthy Fats Snack', 'expectedCals': 190},
      {'query': 'Green Tea with Honey', 'category': 'Detox Drink', 'expectedCals': 25},
      {'query': 'Fresh Watermelon Juice', 'category': 'Hydration Drink', 'expectedCals': 90},
      {'query': 'Dark Chocolate (2 Squares 85%)', 'category': 'Healthy Snack', 'expectedCals': 110},
      {'query': 'Peanut Butter Whole Wheat Toast', 'category': 'Fitness Snack', 'expectedCals': 240},
      {'query': 'Protein Bar (20g Protein)', 'category': 'Fitness On-the-go', 'expectedCals': 210},
      {'query': 'Chai (Indian Tea with Milk & Ginger)', 'category': 'Indian Beverage', 'expectedCals': 110},
    ];

    test('100 Foods Benchmark: Verifies AI Food & Macro Scanner Output across 100 dishes', () async {
      int successCount = 0;

      for (int i = 0; i < hundredTestFoods.length; i++) {
        final item = hundredTestFoods[i];
        final query = item['query'] as String;
        final result = await aiService.analyzeMealText(textDescription: query);

        expect(result.mealTitle, isNotEmpty);
        expect(result.items, isNotEmpty);
        expect(result.confidenceScore, greaterThanOrEqualTo(0.85));

        final totalCals = result.items.fold(0, (sum, elem) => sum + elem.calories);
        final totalProtein = result.items.fold(0, (sum, elem) => sum + elem.proteinGrams);
        final totalCarbs = result.items.fold(0, (sum, elem) => sum + elem.carbsGrams);
        final totalFat = result.items.fold(0, (sum, elem) => sum + elem.fatGrams);

        expect(totalCals, greaterThan(0));
        expect(totalProtein + totalCarbs + totalFat, greaterThan(0));

        successCount++;
      }

      expect(successCount, equals(100));
    });
  });
}
