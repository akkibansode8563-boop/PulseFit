import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/ai_service.dart';
import '../../domain/entities/meal_record.dart';

class FoodVerificationSheet extends StatefulWidget {
  final MealAnalysisResult initialAnalysis;
  final Function(MealRecord finalMeal) onConfirmed;

  const FoodVerificationSheet({
    super.key,
    required this.initialAnalysis,
    required this.onConfirmed,
  });

  @override
  State<FoodVerificationSheet> createState() => _FoodVerificationSheetState();
}

class _FoodVerificationSheetState extends State<FoodVerificationSheet> {
  late TextEditingController _titleController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late MealType _selectedMealType;

  @override
  void initState() {
    super.initState();
    final analysis = widget.initialAnalysis;
    _titleController = TextEditingController(text: analysis.mealTitle);
    
    final totalCals = analysis.items.fold(0, (sum, i) => sum + i.calories);
    final totalProtein = analysis.items.fold(0, (sum, i) => sum + i.proteinGrams);
    final totalCarbs = analysis.items.fold(0, (sum, i) => sum + i.carbsGrams);
    final totalFat = analysis.items.fold(0, (sum, i) => sum + i.fatGrams);

    _caloriesController = TextEditingController(text: totalCals.toString());
    _proteinController = TextEditingController(text: totalProtein.toString());
    _carbsController = TextEditingController(text: totalCarbs.toString());
    _fatController = TextEditingController(text: totalFat.toString());
    _selectedMealType = analysis.suggestedType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confidencePct = (widget.initialAnalysis.confidenceScore * 100).toInt();

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header & Confidence Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Scan Detected 🍽️',
                      style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Verify dish name and macros below',
                      style: GoogleFonts.sora(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.primaryDark, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$confidencePct% Match',
                        style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Dish Name Field (Editable)
            Text(
              'Food Dish Name',
              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Kanda Poha',
                prefixIcon: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primaryDark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: AppColors.background,
              ),
              style: GoogleFonts.sora(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Meal Type Selector
            Text(
              'Meal Category',
              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Row(
              children: MealType.values.map((type) {
                final selected = _selectedMealType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMealType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryDark : AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppColors.primaryDark : AppColors.border,
                        ),
                      ),
                      child: Text(
                        type.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sora(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: selected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Macros Grid (Editable)
            Row(
              children: [
                Expanded(child: _buildMacroInput('Calories (kcal)', _caloriesController, Icons.local_fire_department_rounded, Colors.orange)),
                const SizedBox(width: 10),
                Expanded(child: _buildMacroInput('Protein (g)', _proteinController, Icons.fitness_center_rounded, AppColors.primaryDark)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildMacroInput('Carbs (g)', _carbsController, Icons.grain_rounded, Colors.amber.shade700)),
                const SizedBox(width: 10),
                Expanded(child: _buildMacroInput('Fat (g)', _fatController, Icons.opacity_rounded, Colors.blue.shade600)),
              ],
            ),
            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_rounded, size: 22),
                label: Text(
                  'Confirm & Log Meal',
                  style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: () {
                  final mealName = _titleController.text.trim();
                  final calories = int.tryParse(_caloriesController.text.trim()) ?? 250;
                  final protein = int.tryParse(_proteinController.text.trim()) ?? 8;
                  final carbs = int.tryParse(_carbsController.text.trim()) ?? 35;
                  final fat = int.tryParse(_fatController.text.trim()) ?? 7;

                  final finalRecord = MealRecord(
                    id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
                    title: mealName.isNotEmpty ? mealName : 'Scanned Meal',
                    mealType: _selectedMealType,
                    items: [
                      MealItem(
                        name: mealName.isNotEmpty ? mealName : 'Scanned Dish',
                        weightGrams: 200,
                        calories: calories,
                        proteinGrams: protein,
                        carbsGrams: carbs,
                        fatGrams: fat,
                      ),
                    ],
                    loggedAt: DateTime.now(),
                  );

                  widget.onConfirmed(finalRecord);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInput(String label, TextEditingController controller, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sora(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: color, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }
}
