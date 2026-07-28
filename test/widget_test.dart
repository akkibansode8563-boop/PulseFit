import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_health_manager/main.dart';

void main() {
  testWidgets('PulseFit App instantiates correctly', (WidgetTester tester) async {
    const widget = ProviderScope(child: PulseFitApp());
    expect(widget, isNotNull);
  });
}
