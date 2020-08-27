import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xmpp_rock/xmpp_rock.dart';

void main() {
  const MethodChannel channel = MethodChannel('xmpp_rock');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return  true;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('initialize', () async {
    expect(await XmppRock.initialize, true);
  });
}
