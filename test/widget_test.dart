import 'package:flutter_test/flutter_test.dart';
import 'package:v2ray_vpn/app.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const V2RayVpnApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('V2Ray VPN'), findsWidgets);
  });
}
