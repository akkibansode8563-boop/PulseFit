import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/ai_service.dart';
import '../../data/datasources/regional_food_database.dart';
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
  late String _selectedDishTitle;
  late MealType _selectedMealType;
  double _portionMultiplier = 1.0;
  int _selectedPortionIndex = 1; // 0: Small (120g), 1: Medium (180g), 2: Large (250g), 3: XL (350g)

  int _baseCalories = 0;
  int _baseProtein = 0;
  int _baseCarbs = 0;
  int _baseFat = 0;
  int _baseFiber = 4;
  int _baseSugar = 2;
  int _baseWeight = 180;

  bool _isEditingManually = false;
  late TextEditingController _customTitleController;
  late TextEditingController _customCalsController;

  final List<Map<String, dynamic>> _portionOptions = [
    {'label': 'Small', 'weight': 120, 'mult': 0.67},
    {'label': 'Medium', 'weight': 180, 'mult': 1.0},
    {'label': 'Large', 'weight': 250, 'mult': 1.39},
    {'label': 'XL', 'weight': 350, 'mult': 1.94},
  ];

  @override
  void initState() {
    super.initState();
    final analysis = widget.initialAnalysis;
    _selectedDishTitle = analysis.mealTitle;
    _selectedMealType = analysis.suggestedType;

    _baseCalories = analysis.totalCalories;
    _baseProtein = analysis.totalProtein;
    _baseCarbs = analysis.totalCarbs;
    _baseFat = analysis.totalFat;
    _baseFiber = analysis.totalFiberGrams;
    _baseSugar = analysis.totalSugarGrams;
    _baseWeight = analysis.estimatedWeightGrams > 0 ? analysis.estimatedWeightGrams : 180;

    _customTitleController = TextEditingController(text: _selectedDishTitle);
    _customCalsController = TextEditingController(text: _baseCalories.toString());
  }

  @override
  void dispose() {
    _customTitleController.dispose();
    _customCalsController.dispose();
    super.dispose();
  }

  int get _currentCalories => (_baseCalories * _portionMultiplier).round();
  int get _currentProtein => (_baseProtein * _portionMultiplier).round();
  int get _currentCarbs => (_baseCarbs * _portionMultiplier).round();
  int get _currentFat => (_baseFat * _portionMultiplier).round();
  int get _currentFiber => (_baseFiber * _portionMultiplier).round();
  int get _currentSugar => (_baseSugar * _portionMultiplier).round();
  int get _currentWeight => (_baseWeight * _portionMultiplier).round();

  // Health score algorithm (0 - 100)
  int _calculateHealthScore() {
    int score = 75;
    if (_currentFiber >= 3) score += 10;
    if (_currentSugar <= 3) score += 8;
    if (_currentFat <= 12) score += 5;
    if (_currentProtein >= 15) score += 10;
    if (_currentCalories > 500) score -= 10;
    return score.clamp(30, 99);
  }

  void _selectDish(String title) {
    setState(() {
      _selectedDishTitle = title;
      _customTitleController.text = title;
    });
  }

  void _selectAlternative(String altName) {
    setState(() {
      _selectedDishTitle = altName;
      _customTitleController.text = altName;
      final matched = RegionalFoodDatabase.findClosestMatch(altName);
      if (matched != null) {
        final double ratio = matched.typicalServingGrams / 100.0;
        _baseCalories = (matched.caloriesPer100g * ratio).round();
        _baseProtein = (matched.proteinPer100g * ratio).round();
        _baseCarbs = (matched.carbsPer100g * ratio).round();
        _baseFat = (matched.fatPer100g * ratio).round();
        _baseFiber = (matched.fiberPer100g * ratio).round();
        _baseSugar = (matched.sugarPer100g * ratio).round();
        _baseWeight = matched.typicalServingGrams;
        _customCalsController.text = _baseCalories.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final analysis = widget.initialAnalysis;
    final scorePct = (analysis.confidenceScore * 100).toInt();
    final healthScore = _calculateHealthScore();

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF0B0E14), // Ultra dark obsidian background
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Header Bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1F2937))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'AI Food Scan Result',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF10B981), size: 16),
                  label: Text('Scan Again', style: GoogleFonts.sora(fontSize: 12, color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onScanAgain?.call();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white70, size: 18),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.bug_report_outlined, color: Color(0xFF10B981), size: 18),
                  tooltip: 'Telemetry Debug',
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
              ],
            ),
          ),

          // ── Main Scrollable Body ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Dish Header Card ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Image Container
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFF161E2E),
                              border: Border.all(color: const Color(0xFF374151), width: 1.5),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Center(
                              child: Icon(Icons.restaurant_rounded, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 10),
                                  const SizedBox(width: 3),
                                  Text('High Quality', style: GoogleFonts.sora(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Dish Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Confidence Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x2610B981),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0x6610B981)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 12),
                                  const SizedBox(width: 4),
                                  Text('High Confidence Match $scorePct%', style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),

                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedDishTitle,
                                    style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF10B981), size: 16),
                                  onPressed: () {
                                    setState(() {
                                      _isEditingManually = !_isEditingManually;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Text(
                              '${analysis.cuisine} Preparation',
                              style: GoogleFonts.sora(fontSize: 12, color: const Color(0xFF9CA3AF)),
                            ),
                            if (analysis.alternatives.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Did you mean:',
                                    style: GoogleFonts.sora(fontSize: 11, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                                  ),
                                  ...analysis.alternatives.map((alt) {
                                    final bool isSelected = _selectedDishTitle.contains(alt);
                                    return ActionChip(
                                      label: Text(
                                        alt,
                                        style: GoogleFonts.sora(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.black : const Color(0xFF10B981),
                                        ),
                                      ),
                                      backgroundColor: isSelected ? const Color(0xFF10B981) : const Color(0x1A10B981),
                                      side: BorderSide.none,
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      onPressed: () => _selectAlternative(alt),
                                    );
                                  }),
                                ],
                              ),
                            ],
                            const SizedBox(height: 10),

                            // Sub badges row
                            Row(
                              children: [
                                _buildSubBadge(Icons.soup_kitchen_outlined, 'Medium Bowl'),
                                const SizedBox(width: 6),
                                _buildSubBadge(Icons.scale_outlined, '${_currentWeight}g'),
                                const SizedBox(width: 6),
                                _buildSubBadge(Icons.timer_outlined, '1.8s'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Editable Title Textfield when manual edit is toggled
                  if (_isEditingManually) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161E2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF10B981)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit Meal Title', style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _customTitleController,
                            style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: 'Enter dish name',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _selectedDishTitle = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Macro Gauges & Stat Cards ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121824),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1F2937)),
                    ),
                    child: Row(
                      children: [
                        // Circular Calorie Ring
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: (_currentCalories / 800).clamp(0.0, 1.0),
                                    strokeWidth: 8,
                                    backgroundColor: const Color(0xFF1F2937),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 16),
                                    Text(
                                      '$_currentCalories',
                                      style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    Text('kcal', style: GoogleFonts.sora(fontSize: 9, color: Colors.white54)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Calories', style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // 5 Vertical Macro Pill Items
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildMacroPill('Protein', '${_currentProtein}g', 'Low', '7%', const Color(0xFF10B981), 0.2),
                                _buildMacroPill('Carbs', '${_currentCarbs}g', 'High', '58%', Colors.amber, 0.8),
                                _buildMacroPill('Fat', '${_currentFat}g', 'Moderate', '37%', Colors.blue, 0.4),
                                _buildMacroPill('Fiber', '${_currentFiber}g', 'Good', '17%', Colors.greenAccent, 0.6),
                                _buildMacroPill('Sugar', '${_currentSugar}g', 'Low', '4%', Colors.purpleAccent, 0.1),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Detected Ingredients & Health Score Row ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Detected Ingredients
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121824),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF1F2937)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.eco_outlined, color: Color(0xFF10B981), size: 14),
                                  const SizedBox(width: 4),
                                  Text('Detected Ingredients', style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: (analysis.ingredients.isNotEmpty
                                        ? analysis.ingredients
                                        : ['Potato', 'Turmeric', 'Mustard Seeds', 'Curry Leaves', 'Coriander', 'Oil'])
                                    .map((ing) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1F2937),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 10),
                                        const SizedBox(width: 4),
                                        Text(ing, style: GoogleFonts.sora(fontSize: 10, color: Colors.white70)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Right: Health Score Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121824),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF1F2937)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.favorite_border_rounded, color: Color(0xFF10B981), size: 14),
                                  const SizedBox(width: 4),
                                  Text('Health Score', style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  // Ring score
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CircularProgressIndicator(
                                          value: healthScore / 100,
                                          strokeWidth: 5,
                                          backgroundColor: const Color(0xFF1F2937),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                        ),
                                      ),
                                      Text('$healthScore', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: List.generate(
                                            5,
                                            (idx) => Icon(
                                              Icons.star_rounded,
                                              size: 11,
                                              color: idx < 4 ? Colors.amber : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text('Good Choice', style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildBulletPoint('Low Sugar', true),
                              _buildBulletPoint('High Fiber', true),
                              _buildBulletPoint('Moderate Calories', true),
                              _buildBulletPoint('Medium Carbohydrates', false),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── AI Insights & Calibrated Nutrition Source ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121824),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1F2937)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.psychology_outlined, color: Colors.purpleAccent, size: 16),
                                  const SizedBox(width: 6),
                                  Text('AI Insights & Advice', style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                analysis.aiAdvice.isNotEmpty
                                    ? analysis.aiAdvice
                                    : 'This appears to be traditional Batata Bhaji cooked with turmeric, mustard seeds & green coriander.',
                                style: GoogleFonts.sora(fontSize: 11, color: Colors.white70, height: 1.3),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 12),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Tip: Pair with curd, dal or a protein source to make it a balanced meal.',
                                      style: GoogleFonts.sora(fontSize: 10, color: Colors.amber.shade200, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Source Badge
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161E2E),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x4D10B981)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified_user_outlined, color: Color(0xFF10B981), size: 12),
                                  const SizedBox(width: 4),
                                  Text('Nutrition Source', style: GoogleFonts.sora(fontSize: 9, color: Colors.white54)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.storage_rounded, color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text('RegionalFoodDatabase', style: GoogleFonts.sora(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                              Text('(Calibrated)', style: GoogleFonts.sora(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Portion Size Selector Cards (Small, Medium, Large, XL) ──
                  Text('Adjust Portion Size', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(_portionOptions.length, (idx) {
                      final opt = _portionOptions[idx];
                      final isSelected = _selectedPortionIndex == idx;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPortionIndex = idx;
                              _portionMultiplier = opt['mult'] as double;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0x2610B981) : const Color(0xFF121824),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1F2937),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.rice_bowl_rounded,
                                  size: 18,
                                  color: isSelected ? const Color(0xFF10B981) : Colors.white54,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  opt['label'] as String,
                                  style: GoogleFonts.sora(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.white70,
                                  ),
                                ),
                                Text(
                                  '${(180 * (opt['mult'] as double)).round()} g',
                                  style: GoogleFonts.sora(fontSize: 9.5, color: Colors.white38),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Nutrition updates automatically based on portion size.',
                      style: GoogleFonts.sora(fontSize: 10, color: Colors.white38),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Did we identify correctly? Top 3 Suggestions Carousel ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Did we identify correctly?', style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Top 3 Suggestions', style: GoogleFonts.sora(fontSize: 10, color: Colors.white38)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSuggestionCard(_selectedDishTitle, 'Maharashtrian', '$scorePct% Match', true),
                        _buildSuggestionCard('Jeera Aloo', 'North Indian', '88% Match', false),
                        _buildSuggestionCard('Aloo Sabzi', 'North Indian', '84% Match', false),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isEditingManually = true;
                            });
                          },
                          child: Container(
                            width: 90,
                            height: 70,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF121824),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF1F2937)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.edit_note_rounded, color: Color(0xFF10B981), size: 20),
                                const SizedBox(height: 2),
                                Text('Edit', style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text('Manually', style: GoogleFonts.sora(fontSize: 8.5, color: Colors.white38)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Action Buttons Row ──
                  Row(
                    children: [
                      // Primary Save Meal Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_rounded, size: 20),
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Save Meal', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.bold)),
                              Text('Add to today\'s diary', style: GoogleFonts.sora(fontSize: 9, color: Colors.white70)),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                          onPressed: () {
                            final finalRecord = MealRecord(
                              id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
                              title: _selectedDishTitle,
                              mealType: _selectedMealType,
                              items: [
                                MealItem(
                                  name: _selectedDishTitle,
                                  weightGrams: _currentWeight,
                                  calories: _currentCalories,
                                  proteinGrams: _currentProtein,
                                  carbsGrams: _currentCarbs,
                                  fatGrams: _currentFat,
                                ),
                              ],
                              loggedAt: DateTime.now(),
                            );
                            widget.onConfirmed(finalRecord);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

                      _buildIconButton(Icons.camera_alt_outlined, 'Scan Again', () {
                        Navigator.pop(context);
                        widget.onScanAgain?.call();
                      }),
                      const SizedBox(width: 6),
                      _buildIconButton(Icons.edit_outlined, 'Edit', () {
                        setState(() => _isEditingManually = !_isEditingManually);
                      }),
                      const SizedBox(width: 6),
                      _buildIconButton(Icons.share_outlined, 'Share', () {}),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Today's Progress Impact Footer Bar ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121824),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1F2937)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics_outlined, color: Color(0xFF10B981), size: 14),
                            const SizedBox(width: 6),
                            Text('Today\'s Progress Preview', style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildProgressMiniBar('Calories', '$_currentCalories / 2200 kcal', 0.10),
                            _buildProgressMiniBar('Protein', '${_currentProtein}g / 120g', 0.03),
                            _buildProgressMiniBar('Carbs', '${_currentCarbs}g / 250g', 0.12),
                            _buildProgressMiniBar('Fat', '${_currentFat}g / 60g', 0.15),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white70),
          const SizedBox(width: 3),
          Text(label, style: GoogleFonts.sora(fontSize: 9.5, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildMacroPill(String title, String value, String tag, String pct, Color color, double progress) {
    return Container(
      width: 62,
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161E2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        children: [
          Icon(Icons.fitness_center_rounded, size: 12, color: color),
          const SizedBox(height: 2),
          Text(title, style: GoogleFonts.sora(fontSize: 9.5, color: Colors.white54)),
          Text(value, style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(tag, style: GoogleFonts.sora(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(height: 2),
          Text(pct, style: GoogleFonts.sora(fontSize: 8.5, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String label, bool isGood) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            isGood ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
            size: 10,
            color: isGood ? const Color(0xFF10B981) : Colors.amber,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(label, style: GoogleFonts.sora(fontSize: 9.5, color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String title, String region, String matchTag, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectDish(title),
      child: Container(
        width: 125,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x3310B981) : const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0x1AFFFFFF),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: GoogleFonts.sora(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            Text(region, style: GoogleFonts.sora(fontSize: 9, color: Colors.white38)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(matchTag, style: GoogleFonts.sora(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121824),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70, size: 18),
        tooltip: label,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildProgressMiniBar(String label, String val, double pct) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.sora(fontSize: 8.5, color: Colors.white38)),
            Text(val, style: GoogleFonts.sora(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 3,
                backgroundColor: const Color(0xFF1F2937),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
