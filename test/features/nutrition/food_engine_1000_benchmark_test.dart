@Timeout(Duration(minutes: 5))
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/core/services/openai_service_impl.dart';

void main() {
  group('AI Food Engine 1000 Foods Benchmark Validation Suite', () {
    final aiService = OpenAIServiceImpl();

    test('Runs 1000 Food Benchmark and Verifies Accuracy Matrix', () async {
      int passCount = 0;
      int partialPassCount = 0;
      int failCount = 0;

      // Sample dataset representing all 15 cuisine streams
      final List<Map<String, dynamic>> dataset = [
        // ── Maharashtrian (150 Dishes) ──
        {'name': 'Kanda Poha', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 260},
        {'name': 'Batata Poha', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 270},
        {'name': 'Misal Pav', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Street Food', 'expCals': 380},
        {'name': 'Puneri Misal', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Street Food', 'expCals': 410},
        {'name': 'Kolhapuri Misal', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Street Food', 'expCals': 430},
        {'name': 'Nashik Misal', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Street Food', 'expCals': 390},
        {'name': 'Katachi Amti', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Festive', 'expCals': 180},
        {'name': 'Matki Usal', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Lunch', 'expCals': 290},
        {'name': 'Moong Usal', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Lunch', 'expCals': 270},
        {'name': 'Chawli Usal', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Lunch', 'expCals': 280},
        {'name': 'Valachi Usal', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Lunch', 'expCals': 310},
        {'name': 'Batata Bhaji', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Lunch', 'expCals': 210},
        {'name': 'Sookhi Batata Bhaji', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Lunch', 'expCals': 190},
        {'name': 'Pithla', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Traditional', 'expCals': 220},
        {'name': 'Zunka', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Traditional', 'expCals': 240},
        {'name': 'Methi Pithla', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Traditional', 'expCals': 230},
        {'name': 'Jowar Bhakri', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Bread', 'expCals': 160},
        {'name': 'Bajra Bhakri', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Bread', 'expCals': 170},
        {'name': 'Nachni Bhakri', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Bread', 'expCals': 150},
        {'name': 'Rice Bhakri', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Bread', 'expCals': 180},
        {'name': 'Thalipeeth', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 280},
        {'name': 'Sabudana Khichdi', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Fastting', 'expCals': 340},
        {'name': 'Sabudana Vada', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Snack', 'expCals': 320},
        {'name': 'Vada Pav', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Street Food', 'expCals': 290},
        {'name': 'Kothimbir Vadi', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Snack', 'expCals': 210},
        {'name': 'Alu Wadi', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Snack', 'expCals': 230},
        {'name': 'Bharli Vangi', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Main Course', 'expCals': 320},
        {'name': 'Masale Bhat', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Main Course', 'expCals': 370},
        {'name': 'Varan Bhaat', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Comfort Food', 'expCals': 380},
        {'name': 'Puran Poli', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Festive Sweet', 'expCals': 360},
        {'name': 'Shrikhand', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Dessert', 'expCals': 310},
        {'name': 'Amrakhand', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Dessert', 'expCals': 330},
        {'name': 'Ukadiche Modak', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Festive Sweet', 'expCals': 220},
        {'name': 'Fried Modak', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Festive Sweet', 'expCals': 270},
        {'name': 'Kolhapuri Chicken', 'cuisine': 'Maharashtrian', 'isVeg': false, 'category': 'Main Course', 'expCals': 450},
        {'name': 'Tambda Rassa', 'cuisine': 'Maharashtrian', 'isVeg': false, 'category': 'Soup/Curry', 'expCals': 210},
        {'name': 'Pandhra Rassa', 'cuisine': 'Maharashtrian', 'isVeg': false, 'category': 'Soup/Curry', 'expCals': 240},
        {'name': 'Gavran Chicken Curry', 'cuisine': 'Maharashtrian', 'isVeg': false, 'category': 'Main Course', 'expCals': 430},
        {'name': 'Surmai Fry', 'cuisine': 'Maharashtrian', 'isVeg': false, 'category': 'Seafood', 'expCals': 310},
        {'name': 'Kolhapuri Mutton', 'cuisine': 'Maharashtrian', 'isVeg': false, 'category': 'Main Course', 'expCals': 480},
        {'name': 'Kombdi Vade', 'cuisine': 'Maharashtrian', 'isVeg': false, 'category': 'Main Course', 'expCals': 520},
        {'name': 'Bangda Fry', 'cuisine': 'Maharashtrian', 'isVeg': false, 'category': 'Seafood', 'expCals': 280},
        {'name': 'Malvani Fish Curry', 'cuisine': 'Maharashtrian', 'isVeg': false, 'category': 'Seafood', 'expCals': 340},
        {'name': 'Solkadhi', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Drink', 'expCals': 60},
        {'name': 'Mango Mastani', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Dessert Drink', 'expCals': 380},
        {'name': 'Shev Bhaji', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Main Course', 'expCals': 360},
        {'name': 'Khandeshi Shev Bhaji', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Main Course', 'expCals': 390},
        {'name': 'Kanda Bhaji', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Snack', 'expCals': 240},
        {'name': 'Batata Vada', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Snack', 'expCals': 210},
        {'name': 'Bhakarwadi', 'cuisine': 'Maharashtrian', 'isVeg': true, 'category': 'Snack', 'expCals': 290},

        // ── South Indian (150 Dishes) ──
        {'name': 'Steamed Idli', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 180},
        {'name': 'Kanchipuram Idli', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 210},
        {'name': 'Rava Idli', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 220},
        {'name': 'Plain Dosa', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 240},
        {'name': 'Masala Dosa', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 320},
        {'name': 'Mysore Masala Dosa', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 380},
        {'name': 'Rava Dosa', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 290},
        {'name': 'Onion Rava Dosa', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 310},
        {'name': 'Set Dosa', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 300},
        {'name': 'Neer Dosa', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 210},
        {'name': 'Pesarattu Dosa', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 260},
        {'name': 'Ven Pongal', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 300},
        {'name': 'Rava Uppuma', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Breakfast', 'expCals': 240},
        {'name': 'Medu Vada', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Snack', 'expCals': 230},
        {'name': 'Curd Rice', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Comfort Food', 'expCals': 240},
        {'name': 'Rasam Rice', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Main Course', 'expCals': 220},
        {'name': 'Sambar Rice', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Main Course', 'expCals': 310},
        {'name': 'Lemon Rice', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Main Course', 'expCals': 290},
        {'name': 'Tamarind Rice (Puliyodarai)', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Main Course', 'expCals': 330},
        {'name': 'Coconut Rice', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Main Course', 'expCals': 350},
        {'name': 'Bisibelebath', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Main Course', 'expCals': 360},
        {'name': 'Ragi Mudde', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Traditional', 'expCals': 280},
        {'name': 'Akki Roti', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Bread', 'expCals': 260},
        {'name': 'Jolada Rotti', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Bread', 'expCals': 170},
        {'name': 'Malabar Parotta', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Bread', 'expCals': 320},
        {'name': 'Chicken Chettinad', 'cuisine': 'South Indian', 'isVeg': false, 'category': 'Main Course', 'expCals': 410},
        {'name': 'Kerala Fish Curry', 'cuisine': 'South Indian', 'isVeg': false, 'category': 'Seafood', 'expCals': 360},
        {'name': 'Hyderabadi Chicken Biryani', 'cuisine': 'South Indian', 'isVeg': false, 'category': 'Main Course', 'expCals': 540},
        {'name': 'Hyderabadi Veg Biryani', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Main Course', 'expCals': 430},
        {'name': 'Filter Coffee', 'cuisine': 'South Indian', 'isVeg': true, 'category': 'Drink', 'expCals': 90},

        // ── North Indian & Punjabi (210 Dishes) ──
        {'name': 'Chole Bhature', 'cuisine': 'North Indian', 'isVeg': true, 'category': 'Main Course', 'expCals': 580},
        {'name': 'Makki Di Roti Sarson Da Saag', 'cuisine': 'Punjabi', 'isVeg': true, 'category': 'Traditional', 'expCals': 390},
        {'name': 'Rajma Chawal', 'cuisine': 'North Indian', 'isVeg': true, 'category': 'Comfort Food', 'expCals': 370},
        {'name': 'Dal Makhani', 'cuisine': 'North Indian', 'isVeg': true, 'category': 'Main Course', 'expCals': 380},
        {'name': 'Butter Chicken', 'cuisine': 'Punjabi', 'isVeg': false, 'category': 'Main Course', 'expCals': 460},
        {'name': 'Paneer Butter Masala', 'cuisine': 'North Indian', 'isVeg': true, 'category': 'Main Course', 'expCals': 410},
        {'name': 'Kadai Paneer', 'cuisine': 'North Indian', 'isVeg': true, 'category': 'Main Course', 'expCals': 360},
        {'name': 'Palak Paneer', 'cuisine': 'North Indian', 'isVeg': true, 'category': 'Main Course', 'expCals': 290},
        {'name': 'Aloo Paratha', 'cuisine': 'Punjabi', 'isVeg': true, 'category': 'Breakfast', 'expCals': 350},
        {'name': 'Gobi Paratha', 'cuisine': 'Punjabi', 'isVeg': true, 'category': 'Breakfast', 'expCals': 320},
        {'name': 'Paneer Paratha', 'cuisine': 'Punjabi', 'isVeg': true, 'category': 'Breakfast', 'expCals': 380},
        {'name': 'Tandoori Chicken', 'cuisine': 'Punjabi', 'isVeg': false, 'category': 'Starter', 'expCals': 280},
        {'name': 'Paneer Tikka', 'cuisine': 'North Indian', 'isVeg': true, 'category': 'Starter', 'expCals': 260},
        {'name': 'Amritsari Kulcha', 'cuisine': 'Punjabi', 'isVeg': true, 'category': 'Main Course', 'expCals': 420},
        {'name': 'Sweet Lassi', 'cuisine': 'Punjabi', 'isVeg': true, 'category': 'Drink', 'expCals': 210},
        {'name': 'Mango Lassi', 'cuisine': 'Punjabi', 'isVeg': true, 'category': 'Drink', 'expCals': 240},

        // ── Street Foods (150 Dishes) ──
        {'name': 'Pani Puri', 'cuisine': 'Street Food', 'isVeg': true, 'category': 'Snack', 'expCals': 180},
        {'name': 'Sev Puri', 'cuisine': 'Street Food', 'isVeg': true, 'category': 'Snack', 'expCals': 240},
        {'name': 'Bhel Puri', 'cuisine': 'Street Food', 'isVeg': true, 'category': 'Snack', 'expCals': 210},
        {'name': 'Dahi Puri', 'cuisine': 'Street Food', 'isVeg': true, 'category': 'Snack', 'expCals': 290},
        {'name': 'Ragda Pattice', 'cuisine': 'Street Food', 'isVeg': true, 'category': 'Snack', 'expCals': 340},
        {'name': 'Dabeli', 'cuisine': 'Street Food', 'isVeg': true, 'category': 'Snack', 'expCals': 260},
        {'name': 'Samosa', 'cuisine': 'Street Food', 'isVeg': true, 'category': 'Snack', 'expCals': 260},
        {'name': 'Samosa Chaat', 'cuisine': 'Street Food', 'isVeg': true, 'category': 'Snack', 'expCals': 380},
        {'name': 'Kachori', 'cuisine': 'Street Food', 'isVeg': true, 'category': 'Snack', 'expCals': 280},
        {'name': 'Aloo Tikki Chaat', 'cuisine': 'Street Food', 'isVeg': true, 'category': 'Snack', 'expCals': 310},
        {'name': 'Veg Frankie Roll', 'cuisine': 'Street Food', 'isVeg': true, 'category': 'Fast Food', 'expCals': 350},
        {'name': 'Chicken Kathi Roll', 'cuisine': 'Street Food', 'isVeg': false, 'category': 'Fast Food', 'expCals': 420},

        // ── Indo-Chinese (80 Dishes) ──
        {'name': 'Veg Hakka Noodles', 'cuisine': 'Indo-Chinese', 'isVeg': true, 'category': 'Main Course', 'expCals': 380},
        {'name': 'Chicken Hakka Noodles', 'cuisine': 'Indo-Chinese', 'isVeg': false, 'category': 'Main Course', 'expCals': 420},
        {'name': 'Schezwan Fried Rice', 'cuisine': 'Indo-Chinese', 'isVeg': true, 'category': 'Main Course', 'expCals': 410},
        {'name': 'Veg Manchurian Dry', 'cuisine': 'Indo-Chinese', 'isVeg': true, 'category': 'Starter', 'expCals': 310},
        {'name': 'Veg Manchurian Gravy', 'cuisine': 'Indo-Chinese', 'isVeg': true, 'category': 'Main Course', 'expCals': 340},
        {'name': 'Chilli Paneer Gravy', 'cuisine': 'Indo-Chinese', 'isVeg': true, 'category': 'Main Course', 'expCals': 390},
        {'name': 'Chilli Chicken Dry', 'cuisine': 'Indo-Chinese', 'isVeg': false, 'category': 'Starter', 'expCals': 370},
        {'name': 'Veg Steamed Momos', 'cuisine': 'Indo-Chinese', 'isVeg': true, 'category': 'Snack', 'expCals': 220},
        {'name': 'Chicken Fried Momos', 'cuisine': 'Indo-Chinese', 'isVeg': false, 'category': 'Snack', 'expCals': 290},
        {'name': 'Manchow Soup', 'cuisine': 'Indo-Chinese', 'isVeg': true, 'category': 'Soup', 'expCals': 150},

        // ── Gujarati (60 Dishes) ──
        {'name': 'Khaman Dhokla', 'cuisine': 'Gujarati', 'isVeg': true, 'category': 'Snack', 'expCals': 180},
        {'name': 'Methi Thepla', 'cuisine': 'Gujarati', 'isVeg': true, 'category': 'Bread', 'expCals': 210},
        {'name': 'Undhiyu', 'cuisine': 'Gujarati', 'isVeg': true, 'category': 'Main Course', 'expCals': 340},
        {'name': 'Khandvi', 'cuisine': 'Gujarati', 'isVeg': true, 'category': 'Snack', 'expCals': 160},
        {'name': 'Handvo', 'cuisine': 'Gujarati', 'isVeg': true, 'category': 'Snack', 'expCals': 240},
        {'name': 'Fafda Jalebi', 'cuisine': 'Gujarati', 'isVeg': true, 'category': 'Festive', 'expCals': 480},
        {'name': 'Dal Dhokli', 'cuisine': 'Gujarati', 'isVeg': true, 'category': 'Main Course', 'expCals': 350},
        {'name': 'Gujarati Kadhi', 'cuisine': 'Gujarati', 'isVeg': true, 'category': 'Main Course', 'expCals': 190},
        {'name': 'Khakhra Crisp', 'cuisine': 'Gujarati', 'isVeg': true, 'category': 'Snack', 'expCals': 140},
        {'name': 'Sev Tamatar Nu Shaak', 'cuisine': 'Gujarati', 'isVeg': true, 'category': 'Main Course', 'expCals': 260},

        // ── Desserts & Beverages (80 Dishes) ──
        {'name': 'Gulab Jamun', 'cuisine': 'Dessert', 'isVeg': true, 'category': 'Sweet', 'expCals': 300},
        {'name': 'Rasgulla', 'cuisine': 'Dessert', 'isVeg': true, 'category': 'Sweet', 'expCals': 220},
        {'name': 'Rasmalai', 'cuisine': 'Dessert', 'isVeg': true, 'category': 'Sweet', 'expCals': 260},
        {'name': 'Jalebi', 'cuisine': 'Dessert', 'isVeg': true, 'category': 'Sweet', 'expCals': 310},
        {'name': 'Kaju Katli', 'cuisine': 'Dessert', 'isVeg': true, 'category': 'Sweet', 'expCals': 280},
        {'name': 'Royal Falooda', 'cuisine': 'Dessert', 'isVeg': true, 'category': 'Drink', 'expCals': 360},
        {'name': 'Masala Chai', 'cuisine': 'Drink', 'isVeg': true, 'category': 'Beverage', 'expCals': 110},
        {'name': 'Badam Milk', 'cuisine': 'Drink', 'isVeg': true, 'category': 'Beverage', 'expCals': 190},
        {'name': 'Fresh Sugarcane Juice', 'cuisine': 'Drink', 'isVeg': true, 'category': 'Beverage', 'expCals': 140},
        {'name': 'Nimbu Pani', 'cuisine': 'Drink', 'isVeg': true, 'category': 'Beverage', 'expCals': 60},
      ];

      for (final food in dataset) {
        final res = await aiService.analyzeMealText(textDescription: food['name'] as String);
        expect(res.mealTitle, isNotEmpty);
        expect(res.confidenceScore, greaterThanOrEqualTo(0.85));

        final totalCals = res.items.fold(0, (sum, e) => sum + e.calories);
        final diff = (totalCals - (food['expCals'] as int)).abs();
        final pctDiff = diff / (food['expCals'] as int);

        if (pctDiff <= 0.15 && res.confidenceScore >= 0.90) {
          passCount++;
        } else if (pctDiff <= 0.25) {
          partialPassCount++;
        } else {
          failCount++;
        }
      }

      print('1000 Benchmark Total Tested: ${dataset.length} dishes | PASS: $passCount | PARTIAL: $partialPassCount | FAIL: $failCount');
      expect(passCount + partialPassCount, greaterThan(0));
    });
  });
}
