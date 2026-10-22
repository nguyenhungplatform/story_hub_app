import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Cấu hình Firebase lấy từ `android/app/google-services.json` và `ios/GoogleService-Info.plist`.
abstract final class DefaultFirebaseOptions {
  /// OAuth client loại Web (client_type 3) — Google Sign-In cần nó để cấp idToken dùng cho Firebase.
  static const webClientId = '74532496545-eu475ujg1s3i1aa1nplad3q9ap42cu1f.apps.googleusercontent.com';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Firebase chưa được cấu hình cho web.');
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      _ => throw UnsupportedError('Firebase chưa được cấu hình cho $defaultTargetPlatform.'),
    };
  }

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyB9TZzvGPuiXMfzPrKfWgq5LsSUunbouus',
    appId: '1:74532496545:android:42b370dc840a4471eebce0',
    messagingSenderId: '74532496545',
    projectId: 'storyhub-b9609',
    storageBucket: 'storyhub-b9609.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: 'AIzaSyC6QyCbQbLjN2vf0B8f6_FNJZK590zlHqk',
    appId: '1:74532496545:ios:a45be3712e51eebbeebce0',
    messagingSenderId: '74532496545',
    projectId: 'storyhub-b9609',
    storageBucket: 'storyhub-b9609.firebasestorage.app',
    iosClientId: '74532496545-1eqllu9fkj5ld9rir2itikdpu7mib93e.apps.googleusercontent.com',
    iosBundleId: 'com.storyhub.truyencuamay',
  );
}
