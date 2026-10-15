import 'package:flutter_test/flutter_test.dart';
import 'package:arrowpuzzle/main.dart';

void main() {
  testWidgets('ArrowFlow app loads and displays title', (WidgetTester tester) async {
    await tester.pumpWidget(const ArrowFlowApp());
    // Pump frames to initialize widgets without waiting on infinite pulse animation
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('ArrowFlow'), findsOneWidget);
    expect(find.text('One-Tap Minimal Puzzle'), findsOneWidget);
    expect(find.textContaining('Play Level'), findsOneWidget);
  });
}
