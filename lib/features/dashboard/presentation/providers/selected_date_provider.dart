import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider managing the selected date for day-wise health reports
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
