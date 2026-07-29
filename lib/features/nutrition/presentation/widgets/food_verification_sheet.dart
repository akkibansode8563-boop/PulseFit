import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/meal_record.dart';
import 'developer_debug_sheet.dart';

class FoodVerificationSheet extends StatefulWidget {
  final MealAnalysisResult initialAnalysis;
  final Function(MealRecord finalMeal) onConfirmed;
  final VoidCallback? onScanAgain;

  const FoodVerificationSheet({
    super.key,
    required this.initialAnalysis,
    required this.onConfirmed,
    this.onScanAgain,
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
  late TextEditingController _fiberController;
  late TextEditingController _sugarController;
  late MealType _selectedMealType;
  double _portionMultiplier = 1.0;

  int _baseCalories = 0;
  int _baseProtein = 0;
  int _baseCarbs = 0;
  int _baseFat = 0;
  int _baseFiber = 4;
  int _baseSugar = 2;

  @override
  void initState() {
    super.initState();
    final analysis = widget.initialAnalysis;
    _titleController = TextEditingController(text: analysis.mealTitle);

    _baseCalories = analysis.totalCalories;
    _baseProtein = analysis.totalProtein;
    _baseCarbs = analysis.totalCarbs;
    _baseFat = analysis.totalFat;
    _baseFiber = analysis.totalFiberGrams;
    _baseSugar = analysis.totalSugarGrams;

    _caloriesController = TextEditingController(text: _baseCalories.toString());
    _proteinController = TextEditingController(text: _baseProtein.toString());
    _carbsController = TextEditingController(text: _baseCarbs.toString());
    _fatController = TextEditingController(text: _baseFat.toString());
    _fiberController = TextEditingController(text: _baseFiber.toString());
    _sugarController = TextEditingController(text: _baseSugar.toString());
    _selectedMealType = analysis.suggestedType;
  }

  void _updatePortion(double mult) {
    setState(() {
      _portionMultiplier = mult;
      _caloriesController.text = (_baseCalories * mult).round().toString();
      _proteinController.text = (_baseProtein * mult).round().toString();
      _carbsController.text = (_baseCarbs * mult).round().toString();
      _fatController.text = (_baseFat * mult).round().toString();
      _fiberController.text = (_baseFiber * mult).round().toString();
      _sugarController.text = (_baseSugar * mult).round().toString();
    });
  }

  void _selectAlternative(String altName) {
    setState(() {
      _titleController.text = altName;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysis = widget.initialAnalysis;
    final score = analysis.confidenceScore;
    final confidencePct = (score * 100).toInt();

    // ── 4-Tier Confidence Validation Tiers ──
    final Color badgeBg;
    final Color badgeText;
    final String tierLabel;

    if (score >= 0.95) {
      badgeBg = AppColors.primary.withValues(alpha: 0.15);
      badgeText = AppColors.primaryDark;
      tierLabel = '$confidencePct% High Match';
    } else if (score >= 0.90) {
      badgeBg = Colors.blue.shade50;
      badgeText = Colors.blue.shade800;
      tierLabel = '$confidencePct% Match';
    } else if (score >= 0.75) {
      badgeBg = Colors.orange.shade50;
      badgeText = Colors.orange.shade800;
      tierLabel = '$confidencePct% Suggested Match';
    } else {
      badgeBg = Colors.red.shade50;
      badgeText = Colors.red.shade800;
      tierLabel = 'Low Match ($confidencePct%)';
    }

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
            // Handle bar & Telemetry Icon
            Stack(
              alignment: Alignment.center,
              children: [
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
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.bug_report_rounded, color: AppColors.primaryDark),
                    tooltip: 'Developer Debug Telemetry',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => DeveloperDebugSheet(
                          telemetry: analysis.telemetry,
                          analysis: analysis,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Header & Tiered Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Cloud AI Scan Result 🍽️',
                            style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              analysis.cuisine,
                              style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Verify dish name, portion & macros',
                        style: GoogleFonts.sora(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeText.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_rounded, color: badgeText, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        tierLabel,
                        style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.bold, color: badgeText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Food Dish Name (Editable)
            Text(
              'Food Dish Name',
              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Batata Bhaji',
                prefixIcon: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primaryDark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: AppColors.background,
              ),
              style: GoogleFonts.sora(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // ── Tier 75-89%: Dish Alternatives Chips ──
            if (analysis.alternatives.isNotEmpty) ...[
              Text(
                'Top Dish Alternatives (Tap to select):',
                style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: analysis.alternatives.map((alt) {
                  final selected = _titleController.text.toLowerCase() == alt.toLowerCase();
                  return ActionChip(
                    avatar: Icon(
                      selected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                      size: 14,
                      color: selected ? Colors.white : AppColors.primaryDark,
                    ),
                    label: Text(
                      alt,
                      style: GoogleFonts.sora(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                    backgroundColor: selected ? AppColors.primaryDark : AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onPressed: () => _selectAlternative(alt),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],

            // Ingredients List
            if (analysis.ingredients.isNotEmpty) ...[
              Text(
                'Detected Ingredients:',
                style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: analysis.ingredients.map((ing) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      ing,
                      style: GoogleFonts.sora(fontSize: 10.5, color: Colors.black87),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],

            // Portion Size Selector (0.5x, 1.0x, 1.5x, 2.0x)
            Text(
              'Portion Size Multiplier',
              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPortionChip('0.5x Small', 0.5),
                const SizedBox(width: 6),
                _buildPortionChip('1.0x Regular', 1.0),
                const SizedBox(width: 6),
                _buildPortionChip('1.5x Large', 1.5),
                const SizedBox(width: 6),
                _buildPortionChip('2.0x Feast', 2.0),
              ],
            ),
            const SizedBox(height: 16),

            // Meal Category
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
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryDark : AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: selected ? AppColors.primaryDark : AppColors.border),
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

            // 6 Macros Grid (Calories, Protein, Carbs, Fat, Fiber, Sugar)
            Text(
              'Nutritional Macros Breakdown',
              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMacroInput('Calories (kcal)', _caloriesController, Icons.local_fire_department_rounded, Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroInput('Protein (g)', _proteinController, Icons.fitness_center_rounded, AppColors.primaryDark)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMacroInput('Carbs (g)', _carbsController, Icons.grain_rounded, Colors.amber.shade700)),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroInput('Fat (g)', _fatController, Icons.opacity_rounded, Colors.blue.shade600)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMacroInput('Fiber (g)', _fiberController, Icons.eco_rounded, Colors.green.shade700)),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroInput('Sugar (g)', _sugarController, Icons.cookie_rounded, Colors.purple.shade600)),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_rounded, size: 22),
                label: Text('Confirm & Log Meal', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: () {
                  final mealName = _titleController.text.trim();
                  final calories = int.tryParse(_caloriesController.text.trim()) ?? 200;
                  final protein = int.tryParse(_proteinController.text.trim()) ?? 5;
                  final carbs = int.tryParse(_carbsController.text.trim()) ?? 30;
                  final fat = int.tryParse(_fatController.text.trim()) ?? 6;

                  final finalRecord = MealRecord(
                    id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
                    title: mealName.isNotEmpty ? mealName : 'Scanned Meal',
                    mealType: _selectedMealType,
                    items: [
                      MealItem(
                        name: mealName.isNotEmpty ? mealName : 'Scanned Dish',
                        weightGrams: (analysis.estimatedWeightGrams * _portionMultiplier).round(),
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
            const SizedBox(height: 10),

            if (widget.onScanAgain != null)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined, size: 20),
                  label: Text('Scan Different Meal', style: GoogleFonts.sora(color: AppColors.textSecondary)),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onScanAgain?.call();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortionChip(String label, double mult) {
    final selected = _portionMultiplier == mult;
    return Expanded(
      child: GestureDetector(
        onTap: () => _updatePortion(mult),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.secondary : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.secondary : AppColors.border),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacroInput(String label, TextEditingController controller, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.sora(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: color, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }
}
