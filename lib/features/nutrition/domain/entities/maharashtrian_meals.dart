import 'package:flutter/foundation.dart';

enum MealTimeType { breakfast, lunch, dinner }

@immutable
class MaharashtrianMealOption {
  final String id;
  final String nameEn;
  final String nameMr;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final MealTimeType timeType;
  final String descriptionEn;
  final String descriptionMr;

  const MaharashtrianMealOption({
    required this.id,
    required this.nameEn,
    required this.nameMr,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.timeType,
    required this.descriptionEn,
    required this.descriptionMr,
  });
}

abstract class MaharashtrianMealData {
  static const List<MaharashtrianMealOption> options = [
    // Breakfast Options (नाश्ता)
    MaharashtrianMealOption(
      id: 'm_br_1',
      nameEn: 'Kanda Poha with Peanuts',
      nameMr: 'कांदा पोहे (शेंगदाण्यासह)',
      calories: 260,
      proteinGrams: 7,
      carbsGrams: 42,
      fatGrams: 8,
      timeType: MealTimeType.breakfast,
      descriptionEn: 'Flattened rice cooked with onions, turmeric, mustard seeds & roasted peanuts.',
      descriptionMr: 'कांदा, हळद आणि शेंगदाण्यासह बनवलेले खमंग पोहे.',
    ),
    MaharashtrianMealOption(
      id: 'm_br_2',
      nameEn: 'Thalipeeth with Curd',
      nameMr: 'थालीपीठ आणि दही',
      calories: 320,
      proteinGrams: 11,
      carbsGrams: 48,
      fatGrams: 10,
      timeType: MealTimeType.breakfast,
      descriptionEn: 'Multi-grain savory flatbread made with bhajani flour served with fresh curd.',
      descriptionMr: 'भाजणीच्या पिठाचे पौष्टिक थालीपीठ आणि ताजे दही.',
    ),
    MaharashtrianMealOption(
      id: 'm_br_3',
      nameEn: 'Sabudana Khichdi',
      nameMr: 'साबुदाणा खिचडी',
      calories: 340,
      proteinGrams: 6,
      carbsGrams: 55,
      fatGrams: 12,
      timeType: MealTimeType.breakfast,
      descriptionEn: 'Tapioca pearls sautéed with roasted peanut powder, green chilies & cumin.',
      descriptionMr: 'दाण्याच्या कूटात शिजवलेली साबुदाणा खिचडी.',
    ),
    MaharashtrianMealOption(
      id: 'm_br_4',
      nameEn: 'Upma with Sprouts',
      nameMr: 'मोड आलेल्या मूग उपमा',
      calories: 240,
      proteinGrams: 9,
      carbsGrams: 38,
      fatGrams: 6,
      timeType: MealTimeType.breakfast,
      descriptionEn: 'Semolina cooked with sprouted moong, curry leaves & mustard seeds.',
      descriptionMr: 'रवा आणि मोड आलेल्या मुगाचा खमंग उपमा.',
    ),
    MaharashtrianMealOption(
      id: 'm_br_5',
      nameEn: 'Misal Pav (Light Sprouts)',
      nameMr: 'मिसळ पाव',
      calories: 380,
      proteinGrams: 14,
      carbsGrams: 52,
      fatGrams: 13,
      timeType: MealTimeType.breakfast,
      descriptionEn: 'Spicy sprouted matki curry topped with farsan, onions & lemon.',
      descriptionMr: 'मोड आलेल्या मटकीची झणझणीत मिसळ आणि पाव.',
    ),
    MaharashtrianMealOption(
      id: 'm_br_6',
      nameEn: 'Ukadpeni (Rice Flour Porridge)',
      nameMr: 'उकडपेंडी',
      calories: 220,
      proteinGrams: 5,
      carbsGrams: 36,
      fatGrams: 6,
      timeType: MealTimeType.breakfast,
      descriptionEn: 'Traditional spiced rice flour breakfast porridge tempered with buttermilk.',
      descriptionMr: 'ताकातील सुगंधी आणि हलकी उकडपेंडी.',
    ),

    // Lunch Options (जेवण)
    MaharashtrianMealOption(
      id: 'm_lu_1',
      nameEn: 'Pithla Bhakri & Solkadhi',
      nameMr: 'पिठलं भाकरी आणि सोलकढी',
      calories: 420,
      proteinGrams: 16,
      carbsGrams: 64,
      fatGrams: 11,
      timeType: MealTimeType.lunch,
      descriptionEn: 'Gram flour pithla with Jowar Bhakri, green chili thecha & digestive Solkadhi.',
      descriptionMr: 'झुणका पिठलं, ज्वारीची भाकरी, ठेचा आणि सोलकढी.',
    ),
    MaharashtrianMealOption(
      id: 'm_lu_2',
      nameEn: 'Varan Bhaat with Toop',
      nameMr: 'वरण भात आणि तूप',
      calories: 380,
      proteinGrams: 12,
      carbsGrams: 68,
      fatGrams: 7,
      timeType: MealTimeType.lunch,
      descriptionEn: 'Comforting steamed rice with yellow tur dal varan, pure ghee & lemon.',
      descriptionMr: 'गरमागरम भात, तुरीचे वरण, साजूक तूप आणि लिंबू.',
    ),
    MaharashtrianMealOption(
      id: 'm_lu_3',
      nameEn: 'Bharli Vangi with Bajra Bhakri',
      nameMr: 'भरली वांगी आणि बाजरीची भाकरी',
      calories: 450,
      proteinGrams: 14,
      carbsGrams: 62,
      fatGrams: 16,
      timeType: MealTimeType.lunch,
      descriptionEn: 'Stuffed brinjal curry with roasted peanut sesame masala & pearl millet bhakri.',
      descriptionMr: 'मसालेदार भरली वांगी आणि गरमागरम बाजरीची भाकरी.',
    ),
    MaharashtrianMealOption(
      id: 'm_lu_4',
      nameEn: 'Matki Chi Usal & Chapati',
      nameMr: 'मटकीची उसळ आणि चपाती',
      calories: 390,
      proteinGrams: 18,
      carbsGrams: 58,
      fatGrams: 9,
      timeType: MealTimeType.lunch,
      descriptionEn: 'High-protein sprouted moth bean curry served with whole wheat chapatis.',
      descriptionMr: 'प्रोटिनयुक्त मटकीची उसळ आणि गव्हाची चपाती.',
    ),

    // Dinner Options (संध्याकाळचे जेवण)
    MaharashtrianMealOption(
      id: 'm_di_1',
      nameEn: 'Katachi Amti with Rice & Bhakri',
      nameMr: 'कटाची आमटी आणि भात',
      calories: 360,
      proteinGrams: 13,
      carbsGrams: 58,
      fatGrams: 8,
      timeType: MealTimeType.dinner,
      descriptionEn: 'Tangy chana dal extract amti served with steamed rice.',
      descriptionMr: 'चना डाळीची चवदार कटाची आमटी आणि भात.',
    ),
    MaharashtrianMealOption(
      id: 'm_di_2',
      nameEn: 'Methi Pithla with Nachni Bhakri',
      nameMr: 'मेथी पिठलं आणि नाचणीची भाकरी',
      calories: 340,
      proteinGrams: 15,
      carbsGrams: 52,
      fatGrams: 9,
      timeType: MealTimeType.dinner,
      descriptionEn: 'Fenugreek besan curry with calcium-rich ragi / nachni bhakri.',
      descriptionMr: 'मेथी घातलेले पिठलं आणि कॅल्शियमयुक्त नाचणीची भाकरी.',
    ),
    MaharashtrianMealOption(
      id: 'm_di_3',
      nameEn: 'Masale Bhaat with Cucumber Koshimbir',
      nameMr: 'मसाले भात आणि कोशिंबीर',
      calories: 370,
      proteinGrams: 10,
      carbsGrams: 64,
      fatGrams: 8,
      timeType: MealTimeType.dinner,
      descriptionEn: 'Spiced aromatic rice cooked with vegetables and served with yogurt koshimbir.',
      descriptionMr: 'सुगंधी मसाले भात आणि थंडगार काकडीची कोशिंबीर.',
    ),
  ];
}
