import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Branding Assets & Android Metadata Tests', () {
    test('Branding assets exist in mobile/assets/branding', () {
      final iconFile = File('assets/branding/app_icon.png');
      final logoFile = File('assets/branding/logo.png');

      expect(iconFile.existsSync(), isTrue, reason: 'app_icon.png should exist');
      expect(logoFile.existsSync(), isTrue, reason: 'logo.png should exist');
      expect(iconFile.lengthSync(), greaterThan(10000), reason: 'Icon should be full res');
    });

    test('Android launcher icon has been updated with branded asset', () {
      final mipmapHdpi = File('android/app/src/main/res/mipmap-hdpi/ic_launcher.png');
      expect(mipmapHdpi.existsSync(), isTrue);
      // Default flutter icon was 544 bytes, branded is > 1000 bytes
      expect(mipmapHdpi.lengthSync(), greaterThan(1000));
    });

    test('AndroidManifest contains ACCESS_NETWORK_STATE and INTERNET', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml');
      expect(manifest.existsSync(), isTrue);
      final content = manifest.readAsStringSync();

      expect(content.contains('android.permission.INTERNET'), isTrue);
      expect(content.contains('android.permission.ACCESS_NETWORK_STATE'), isTrue);
    });

    test('Launch background has eggshell background and logo bitmap', () {
      final launchBg = File('android/app/src/main/res/drawable/launch_background.xml');
      expect(launchBg.existsSync(), isTrue);
      final content = launchBg.readAsStringSync();

      expect(content.contains('@color/splash_background'), isTrue);
      expect(content.contains('@mipmap/ic_launcher'), isTrue);
    });
  });
}
