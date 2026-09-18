import 'package:flutter_test/flutter_test.dart';

import 'package:story_hub_app/app/app.dart';

void main() {
  testWidgets('renders the Story Hub home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StoryHubApp());
    await tester.pumpAndSettle();

    expect(find.text('story hub'), findsOneWidget);
    expect(find.text('Mùa hè có gió'), findsOneWidget);
  });
}
