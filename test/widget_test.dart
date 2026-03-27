import 'package:flutter_test/flutter_test.dart';
import 'package:gamebooking/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const GameBookingApp());
    await tester.pump();
  });
}
